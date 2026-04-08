#!/bin/bash
clear
echo ""
echo "  ╔════════════════════════════════════╗"
echo "  ║  Essentials Egypt Team — Deploy    ║"
echo "  ╚════════════════════════════════════╝"
echo ""
echo "  Step 1/3 — Installing tools..."
npm install -g vercel --silent
echo "  ✓ Done"
echo ""
echo "  Step 2/3 — Logging into Vercel..."
echo "  (A browser window will open — sign in with Google or email)"
echo ""
vercel login
echo ""
echo "  Step 3/3 — Deploying your app..."
vercel deploy --prod \
  --yes \
  --name essentials-egypt-team \
  --build-env NEXT_PUBLIC_SUPABASE_URL="https://dvtkkhiimgwxuxisxlzw.supabase.co" \
  --build-env NEXT_PUBLIC_SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR2dGtraGlpbWd3eHV4aXN4bHp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1OTY0OTAsImV4cCI6MjA5MTE3MjQ5MH0.DH8KDoOkAkcqpGDEtLuMMwiayjW5D5xqJdSKuwxGJzY" \
  --env NEXT_PUBLIC_SUPABASE_URL="https://dvtkkhiimgwxuxisxlzw.supabase.co" \
  --env NEXT_PUBLIC_SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR2dGtraGlpbWd3eHV4aXN4bHp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1OTY0OTAsImV4cCI6MjA5MTE3MjQ5MH0.DH8KDoOkAkcqpGDEtLuMMwiayjW5D5xqJdSKuwxGJzY" \
  --env NEXT_PUBLIC_APP_URL="https://essentials-egypt-team.vercel.app"

echo ""
echo "  ✅ YOUR APP IS LIVE!"
echo "  👉 Visit: https://essentials-egypt-team.vercel.app"
echo ""
