#!/bin/bash
set -e

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Essentials Egypt Team — Deploy to Vercel ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Check Vercel CLI
if ! command -v vercel &> /dev/null; then
  echo "Installing Vercel CLI..."
  npm install -g vercel
fi

echo "→ Deploying to Vercel (production)..."
vercel --prod \
  --yes \
  --name essentials-egypt-team \
  --env NEXT_PUBLIC_SUPABASE_URL="https://dvtkkhiimgwxuxisxlzw.supabase.co" \
  --env NEXT_PUBLIC_SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR2dGtraGlpbWd3eHV4aXN4bHp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1OTY0OTAsImV4cCI6MjA5MTE3MjQ5MH0.DH8KDoOkAkcqpGDEtLuMMwiayjW5D5xqJdSKuwxGJzY" \
  --env NEXT_PUBLIC_APP_URL="https://essentials-egypt-team.vercel.app"

echo ""
echo "✓ Deployed! Visit: https://essentials-egypt-team.vercel.app"
