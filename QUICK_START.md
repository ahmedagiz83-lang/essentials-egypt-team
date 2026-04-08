# Essentials Egypt Team — Quick Start Guide

## Your Project Details (keep these safe)

| Item | Value |
|------|-------|
| Supabase Project | dvtkkhiimgwxuxisxlzw |
| Supabase URL | https://dvtkkhiimgwxuxisxlzw.supabase.co |
| Supabase Anon Key | eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR2dGtraGlpbWd3eHV4aXN4bHp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1OTY0OTAsImV4cCI6MjA5MTE3MjQ5MH0.DH8KDoOkAkcqpGDEtLuMMwiayjW5D5xqJdSKuwxGJzY |
| Vercel Team | ahmedagiz83-langs-projects |
| Vercel Team ID | team_VtFJHD6sDO8ejqfx2vB9VKaH |
| Database | 12 migrations applied ✓ |

---

## Step 1 — Deploy to Vercel (2 minutes)

```bash
# Install Vercel CLI
npm install -g vercel

# From inside this folder:
vercel --prod --yes --name essentials-egypt-team
```

Or just run:
```bash
bash deploy.sh
```

---

## Step 2 — Create your Admin account (1 minute)

1. Go to: https://supabase.com/dashboard/project/dvtkkhiimgwxuxisxlzw/auth/users
2. Click **Add user** → set your email and a strong password
3. Go to: https://supabase.com/dashboard/project/dvtkkhiimgwxuxisxlzw/sql
4. Run:
```sql
UPDATE profiles
SET role = 'admin',
    full_name = 'Your Full Name',
    department = 'Management'
WHERE email = 'your@email.com';
```

---

## Step 3 — Add team members

In Supabase → Auth → Users → Add user for each team member.

Then update their profiles:
```sql
UPDATE profiles
SET role = 'manager', full_name = 'Omar Khalil', department = 'Marketing'
WHERE email = 'omar@essentials-egypt.com';
```

Roles: `admin` | `manager` | `member`

---

## Step 4 — Add email notifications (optional)

1. Sign up at https://resend.com (free tier: 3,000 emails/month)
2. Add your domain
3. Add to Vercel env vars: `RESEND_API_KEY=re_xxxx`

---

## Database Tables

| Table | Purpose |
|-------|---------|
| `profiles` | Team members (extends Supabase Auth) |
| `tasks` | All tasks with full fields |
| `comments` | Per-task threaded comments |
| `activity_log` | Full audit trail of every action |
| `notifications` | In-app alerts |
| `email_logs` | Tracks all emails sent |

## Database Views (pre-joined, read-optimized)

| View | Purpose |
|------|---------|
| `task_stats` | Dashboard stats (totals, overdue, due soon) |
| `tasks_full` | Tasks with assignee + creator names joined |
| `member_performance` | Team roster with task counts + score |

## Performance Score Formula

```
Score = (done/total × 70) + (on_time/done × 20) + overdue_bonus(10)
```
- Recalculates automatically via PostgreSQL trigger on every task change
- 80–100 = Excellent · 60–79 = Good · 40–59 = Needs Improvement · 0–39 = Critical

## Roles & Permissions

| Feature | Admin | Manager | Member |
|---------|-------|---------|--------|
| View all tasks | ✓ | ✓ | ✓ |
| Create tasks | ✓ | ✓ | ✓ |
| Update own tasks | ✓ | ✓ | ✓ |
| Update any task | ✓ | ✓ | ✗ |
| Approve tasks | ✓ | ✓ | ✗ |
| Delete tasks | ✓ | ✗ | ✗ |
| View team | ✓ | ✓ | ✓ |
| Settings page | ✓ | ✗ | ✗ |

---

## Pages

| Route | Page |
|-------|------|
| `/auth/login` | Login |
| `/dashboard` | Main dashboard |
| `/tasks` | All tasks with filters |
| `/tasks/my` | My tasks |
| `/tasks/create` | Create new task |
| `/task/[id]` | Task detail + comments + approval |
| `/team` | Team roster with scores |
| `/member/[id]` | Member profile + history |
| `/activity` | Full activity log |
| `/alerts` | Overdue + approvals center |
| `/settings` | Admin settings |

---

## Local Development

```bash
npm install
npm run dev
# → http://localhost:3000
```

## Environment Variables

Already in `.env.local`:
```
NEXT_PUBLIC_SUPABASE_URL=https://dvtkkhiimgwxuxisxlzw.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbG...
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

Add when ready:
```
RESEND_API_KEY=re_your_key_here
```
