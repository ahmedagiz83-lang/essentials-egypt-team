-- ============================================================
-- ESSENTIALS EGYPT TEAM — COMPLETE DATABASE SCHEMA
-- Project: dvtkkhiimgwxuxisxlzw
-- All 12 migrations combined in order
-- Run this in Supabase SQL Editor to recreate from scratch
-- ============================================================

-- ── MIGRATION 01: Extensions ─────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── MIGRATION 02: Profiles ───────────────────────────────────
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  avatar_initials TEXT NOT NULL DEFAULT 'XX',
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'manager', 'member')),
  department TEXT NOT NULL DEFAULT 'General',
  email TEXT NOT NULL,
  performance_score INTEGER NOT NULL DEFAULT 100,
  joined_at DATE NOT NULL DEFAULT CURRENT_DATE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql SET search_path = '';

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── MIGRATION 03: Tasks ──────────────────────────────────────
CREATE TABLE public.tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  assigned_to UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  department TEXT NOT NULL DEFAULT 'General',
  priority TEXT NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
  status TEXT NOT NULL DEFAULT 'todo' CHECK (status IN ('todo', 'in_progress', 'review', 'done', 'cancelled')),
  deadline DATE NOT NULL,
  links TEXT[] DEFAULT '{}',
  proof_of_work TEXT,
  approval_required BOOLEAN NOT NULL DEFAULT FALSE,
  approved_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  approved_at TIMESTAMPTZ,
  approval_status TEXT CHECK (approval_status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER tasks_updated_at
  BEFORE UPDATE ON public.tasks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE INDEX idx_tasks_assigned_to ON public.tasks(assigned_to);
CREATE INDEX idx_tasks_status ON public.tasks(status);
CREATE INDEX idx_tasks_deadline ON public.tasks(deadline);
CREATE INDEX idx_tasks_department ON public.tasks(department);

-- ── MIGRATION 04: Comments ───────────────────────────────────
CREATE TABLE public.comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_comments_task_id ON public.comments(task_id);

-- ── MIGRATION 05: Activity Log ───────────────────────────────
CREATE TABLE public.activity_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL DEFAULT 'task' CHECK (entity_type IN ('task','profile','system','approval','comment')),
  entity_id UUID,
  entity_title TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_activity_log_user_id ON public.activity_log(user_id);
CREATE INDEX idx_activity_log_created_at ON public.activity_log(created_at DESC);

-- ── MIGRATION 06: Notifications ──────────────────────────────
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('overdue','due_soon','approval_request','approved','rejected','assigned','comment','system')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);

-- ── MIGRATION 07: Email Logs ─────────────────────────────────
CREATE TABLE public.email_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipient_email TEXT NOT NULL,
  recipient_name TEXT,
  subject TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('daily_summary','overdue_alert','task_assigned','approval_request','approved','rejected')),
  status TEXT NOT NULL DEFAULT 'sent' CHECK (status IN ('sent','failed','pending')),
  sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── MIGRATION 08: Performance Score Functions ────────────────
CREATE OR REPLACE FUNCTION public.calculate_performance_score(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  total_tasks INTEGER; done_tasks INTEGER; overdue_tasks INTEGER; on_time_done INTEGER; score NUMERIC;
BEGIN
  SELECT COUNT(*) INTO total_tasks FROM public.tasks WHERE assigned_to = p_user_id AND status != 'cancelled';
  IF total_tasks = 0 THEN RETURN 100; END IF;
  SELECT COUNT(*) INTO done_tasks FROM public.tasks WHERE assigned_to = p_user_id AND status = 'done';
  SELECT COUNT(*) INTO overdue_tasks FROM public.tasks WHERE assigned_to = p_user_id AND status NOT IN ('done','cancelled') AND deadline < CURRENT_DATE;
  SELECT COUNT(*) INTO on_time_done FROM public.tasks WHERE assigned_to = p_user_id AND status = 'done' AND (updated_at::DATE <= deadline OR proof_of_work IS NOT NULL);
  score := (done_tasks::NUMERIC / total_tasks) * 70
         + (CASE WHEN done_tasks > 0 THEN (on_time_done::NUMERIC / done_tasks) * 20 ELSE 0 END)
         + (CASE WHEN overdue_tasks = 0 THEN 10 ELSE GREATEST(0, 10 - overdue_tasks * 3) END);
  RETURN LEAST(100, GREATEST(0, ROUND(score)));
END;
$$ LANGUAGE plpgsql SET search_path = '';

CREATE OR REPLACE FUNCTION public.sync_performance_score()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.assigned_to IS NOT NULL THEN
    UPDATE public.profiles SET performance_score = public.calculate_performance_score(NEW.assigned_to) WHERE id = NEW.assigned_to;
  END IF;
  IF OLD.assigned_to IS NOT NULL AND OLD.assigned_to != NEW.assigned_to THEN
    UPDATE public.profiles SET performance_score = public.calculate_performance_score(OLD.assigned_to) WHERE id = OLD.assigned_to;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = '';

CREATE TRIGGER tasks_sync_performance
  AFTER INSERT OR UPDATE OF status, deadline, assigned_to ON public.tasks
  FOR EACH ROW EXECUTE FUNCTION sync_performance_score();

-- ── MIGRATION 09: RLS Policies ───────────────────────────────
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.email_logs ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE SET search_path = '';

-- Profiles
CREATE POLICY "profiles_select_all" ON public.profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE TO authenticated USING (id = auth.uid());
CREATE POLICY "profiles_update_admin" ON public.profiles FOR UPDATE TO authenticated USING (public.get_my_role() = 'admin');
CREATE POLICY "profiles_insert_admin" ON public.profiles FOR INSERT TO authenticated WITH CHECK (public.get_my_role() = 'admin');

-- Tasks
CREATE POLICY "tasks_select_all" ON public.tasks FOR SELECT TO authenticated USING (true);
CREATE POLICY "tasks_insert_any" ON public.tasks FOR INSERT TO authenticated WITH CHECK (public.get_my_role() IN ('admin','manager') OR created_by = auth.uid());
CREATE POLICY "tasks_update_own_or_manager" ON public.tasks FOR UPDATE TO authenticated USING (assigned_to = auth.uid() OR created_by = auth.uid() OR public.get_my_role() IN ('admin','manager'));
CREATE POLICY "tasks_delete_admin" ON public.tasks FOR DELETE TO authenticated USING (public.get_my_role() = 'admin');

-- Comments
CREATE POLICY "comments_select_all" ON public.comments FOR SELECT TO authenticated USING (true);
CREATE POLICY "comments_insert" ON public.comments FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "comments_delete_own_or_admin" ON public.comments FOR DELETE TO authenticated USING (user_id = auth.uid() OR public.get_my_role() = 'admin');

-- Activity Log
CREATE POLICY "activity_log_select_all" ON public.activity_log FOR SELECT TO authenticated USING (true);
CREATE POLICY "activity_log_insert_own" ON public.activity_log FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid() OR user_id IS NULL);

-- Notifications
CREATE POLICY "notifications_select" ON public.notifications FOR SELECT TO authenticated USING (user_id = auth.uid() OR public.get_my_role() IN ('admin','manager'));
CREATE POLICY "notifications_update_own" ON public.notifications FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "notifications_insert" ON public.notifications FOR INSERT TO authenticated WITH CHECK (auth.uid() IS NOT NULL);

-- Email Logs
CREATE POLICY "email_logs_select_admin" ON public.email_logs FOR SELECT TO authenticated USING (public.get_my_role() = 'admin');
CREATE POLICY "email_logs_insert_admin" ON public.email_logs FOR INSERT TO authenticated WITH CHECK (public.get_my_role() = 'admin');

-- ── MIGRATION 10: Auto Profile on Signup ─────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_initials, role, department)
  VALUES (
    NEW.id, NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    UPPER(LEFT(COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)), 2)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'member'),
    COALESCE(NEW.raw_user_meta_data->>'department', 'General')
  ) ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

CREATE OR REPLACE FUNCTION public.log_activity(
  p_user_id UUID, p_action TEXT, p_entity_type TEXT,
  p_entity_id UUID DEFAULT NULL, p_entity_title TEXT DEFAULT NULL, p_metadata JSONB DEFAULT '{}'
) RETURNS void AS $$
BEGIN
  INSERT INTO public.activity_log (user_id, action, entity_type, entity_id, entity_title, metadata)
  VALUES (p_user_id, p_action, p_entity_type, p_entity_id, p_entity_title, p_metadata);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- ── MIGRATION 11 + 12: Views (security_invoker) ──────────────
CREATE VIEW public.task_stats WITH (security_invoker = true) AS
SELECT
  COUNT(*) FILTER (WHERE status != 'cancelled') AS total_tasks,
  COUNT(*) FILTER (WHERE status = 'done') AS done_tasks,
  COUNT(*) FILTER (WHERE status = 'in_progress') AS in_progress_tasks,
  COUNT(*) FILTER (WHERE status = 'todo') AS todo_tasks,
  COUNT(*) FILTER (WHERE status = 'review') AS review_tasks,
  COUNT(*) FILTER (WHERE status NOT IN ('done','cancelled') AND deadline < CURRENT_DATE) AS overdue_tasks,
  COUNT(*) FILTER (WHERE status NOT IN ('done','cancelled') AND deadline >= CURRENT_DATE AND deadline <= CURRENT_DATE + 2) AS due_soon_tasks,
  COUNT(*) FILTER (WHERE approval_required = TRUE AND approval_status = 'pending' AND status = 'review') AS pending_approvals
FROM public.tasks;

CREATE VIEW public.tasks_full WITH (security_invoker = true) AS
SELECT
  t.*, p.full_name AS assignee_name, p.avatar_initials AS assignee_avatar,
  p.department AS assignee_department, c.full_name AS creator_name,
  CASE WHEN t.status NOT IN ('done','cancelled') AND t.deadline < CURRENT_DATE THEN TRUE ELSE FALSE END AS is_overdue,
  CASE WHEN t.status NOT IN ('done','cancelled') AND t.deadline >= CURRENT_DATE AND t.deadline <= CURRENT_DATE + 2 THEN TRUE ELSE FALSE END AS is_due_soon
FROM public.tasks t
LEFT JOIN public.profiles p ON p.id = t.assigned_to
LEFT JOIN public.profiles c ON c.id = t.created_by;

CREATE VIEW public.member_performance WITH (security_invoker = true) AS
SELECT
  p.id, p.full_name, p.avatar_initials, p.role, p.department, p.email,
  p.performance_score, p.joined_at, p.is_active,
  COUNT(t.id) FILTER (WHERE t.status != 'cancelled') AS total_tasks,
  COUNT(t.id) FILTER (WHERE t.status = 'done') AS done_tasks,
  COUNT(t.id) FILTER (WHERE t.status = 'in_progress') AS active_tasks,
  COUNT(t.id) FILTER (WHERE t.status NOT IN ('done','cancelled') AND t.deadline < CURRENT_DATE) AS overdue_tasks
FROM public.profiles p
LEFT JOIN public.tasks t ON t.assigned_to = p.id
GROUP BY p.id, p.full_name, p.avatar_initials, p.role, p.department, p.email, p.performance_score, p.joined_at, p.is_active;

-- ── POST-DEPLOY: Set your first admin ────────────────────────
-- Run this AFTER creating your user in Supabase Auth:
-- UPDATE profiles SET role = 'admin', full_name = 'Your Name', department = 'Management'
-- WHERE email = 'your@email.com';
