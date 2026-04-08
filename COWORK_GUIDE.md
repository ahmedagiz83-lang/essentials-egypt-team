# Essentials Egypt Team — Claude Cowork Guide

This guide tells Claude Cowork exactly how to interact with the Essentials Egypt Team portal.

## App URL
https://essentials-egypt-team.vercel.app

## Login
- Go to: https://essentials-egypt-team.vercel.app/auth/login
- Enter email and password for your admin account
- You will be redirected to the Dashboard after login

---

## REST API Reference

All API endpoints are at: `https://essentials-egypt-team.vercel.app/api/v1/`

Authentication: Cookie-based (handled automatically after browser login).

### Dashboard Summary
```
GET /api/v1/stats
```
Returns: total tasks, overdue tasks, pending approvals, recent activity.

### List Tasks
```
GET /api/v1/tasks
GET /api/v1/tasks?status=in_progress
GET /api/v1/tasks?priority=critical
GET /api/v1/tasks?mine=true
GET /api/v1/tasks?overdue=true
GET /api/v1/tasks?department=Marketing
```

### Get Single Task
```
GET /api/v1/tasks/{task_id}
```
Returns task details + all comments.

### Create Task
```
POST /api/v1/tasks
{
  "title": "Task title",
  "description": "Details",
  "assigned_to": "user-uuid",
  "department": "Marketing",
  "priority": "high",
  "deadline": "2026-04-30",
  "approval_required": false
}
```

### Update Task Status
```
PATCH /api/v1/tasks/{task_id}
{ "status": "in_progress" }
```
Valid statuses: `todo`, `in_progress`, `review`, `done`, `cancelled`

### Add Comment
```
POST /api/v1/tasks/{task_id}/comment
{ "content": "Your comment here" }
```

### Approve / Reject Task
```
POST /api/v1/tasks/{task_id}/approve
{ "approved": true }
```

### List Team Members
```
GET /api/v1/team
```
Returns all members with performance scores, task counts.

### My Profile + Tasks
```
GET /api/v1/me
```

---

## Browser Navigation Guide (Claude in Chrome)

### Create a Task
1. Go to: https://essentials-egypt-team.vercel.app/tasks/create
2. Fill in the "Task Title" field
3. Fill in "Description"
4. Select "Assign To" from the dropdown
5. Choose "Department", "Priority", "Deadline"
6. Click "Create Task" button

### Update a Task Status
1. Go to: https://essentials-egypt-team.vercel.app/tasks
2. Click on the task row
3. In the "Update Status" section, click the desired status button
4. If submitting for review, paste proof of work link
5. Click "Save Update"

### Approve a Task
1. Go to: https://essentials-egypt-team.vercel.app/alerts
2. Find the task in "Pending Approvals"
3. Click "Approve" or "Reject"

### View Team Performance
1. Go to: https://essentials-egypt-team.vercel.app/team
2. Each card shows member score, tasks done, overdue count

### View Activity Log
1. Go to: https://essentials-egypt-team.vercel.app/activity

---

## Example Cowork Tasks You Can Give Claude

- "Show me all overdue tasks"
- "Create a task for Nour to design the new product banner, due April 30"
- "Who has the lowest performance score?"
- "Approve all pending tasks"
- "Add a comment to the Q2 campaign task saying the deadline is extended"
- "Show me a summary of what happened today"
- "Mark the checkout bug task as in progress"
- "List all critical priority tasks assigned to the tech department"
- "How many tasks does Sara have overdue?"
- "Generate a daily summary report"

---

## Page URLs Reference

| Page | URL |
|------|-----|
| Dashboard | /dashboard |
| My Tasks | /tasks/my |
| All Tasks | /tasks |
| Create Task | /tasks/create |
| Task Detail | /task/{id} |
| Team | /team |
| Member Profile | /member/{id} |
| Activity Log | /activity |
| Alerts | /alerts |
| Settings | /settings |

