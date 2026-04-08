# Essentials Egypt Team — V1

Internal team management portal built with Next.js 14, TypeScript, Tailwind CSS, and Supabase.

## Quick Start

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

## Environment Variables

Copy `.env.local` — already pre-filled with your Supabase credentials:

```
NEXT_PUBLIC_SUPABASE_URL=https://dvtkkhiimgwxuxisxlzw.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
RESEND_API_KEY=re_your_key_here  ← Add this for emails
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

## First Steps After Install

1. Go to your Supabase project → Authentication → Users → Add user
2. Set email + password for your admin account
3. In SQL Editor run:
   ```sql
   UPDATE profiles SET role = 'admin' WHERE email = 'your@email.com';
   ```
4. Log in at /auth/login

## Project Structure

```
src/
├── app/
│   ├── auth/login/        → Login page
│   ├── dashboard/         → Main dashboard
│   ├── tasks/             → All Tasks, My Tasks, Create Task
│   ├── task/[id]/         → Task detail + approval + comments
│   ├── team/              → Team roster
│   ├── member/[id]/       → Member profile + performance
│   ├── activity/          → Audit log
│   ├── alerts/            → Overdue + approvals center
│   ├── settings/          → Admin settings
│   └── api/emails/        → Email API routes
├── components/
│   ├── layout/            → AppShell, Sidebar, Header
│   ├── ui/                → Avatar, Badge, ScoreRing, StatCard
│   └── tasks/             → TaskRow, TaskFilters
├── lib/
│   ├── supabase/          → Client, Server, Middleware
│   ├── actions/tasks.ts   → All server actions
│   ├── emails.ts          → Email templates
│   └── utils.ts           → Helpers
└── types/index.ts         → All TypeScript types

## Roles & Permissions

| Feature            | Admin | Manager | Member |
|--------------------|-------|---------|--------|
| View all tasks     | ✓     | ✓       | ✓      |
| Create tasks       | ✓     | ✓       | ✓*     |
| Update own tasks   | ✓     | ✓       | ✓      |
| Approve tasks      | ✓     | ✓       | ✗      |
| Delete tasks       | ✓     | ✗       | ✗      |
| View team          | ✓     | ✓       | ✓      |
| Settings           | ✓     | ✗       | ✗      |

## Performance Score Formula

Score = (completed/total × 70) + (on-time/completed × 20) + overdue bonus (10)
- 80–100: Excellent
- 60–79: Good  
- 40–59: Needs Improvement
- 0–39: Critical

Recalculated automatically via PostgreSQL trigger on every task status change.

## Database Schema

Tables: profiles, tasks, comments, activity_log, notifications, email_logs
Views: task_stats, member_performance, tasks_full

## Deploy to Vercel

```bash
npx vercel
```
Set all environment variables in Vercel dashboard.

## Add Email (Resend)

1. Sign up at resend.com
2. Add your domain
3. Set RESEND_API_KEY in .env.local
4. Email templates are in src/lib/emails.ts
