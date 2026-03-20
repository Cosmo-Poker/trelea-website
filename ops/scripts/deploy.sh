#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# Deploy Trelea Website — Trigger App Platform deployment
#
# Usage: ./ops/scripts/deploy.sh
# ──────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load ops env for DO credentials
if [ -f "$PROJECT_ROOT/ops/.env.ops" ]; then
  source "$PROJECT_ROOT/ops/.env.ops"
fi

APP_NAME="trelea-website"

echo "╔══════════════════════════════════════════╗"
echo "║  Trelea Website Deploy                   ║"
echo "║  Target: App Platform ($APP_NAME)        ║"
echo "╚══════════════════════════════════════════╝"

# Find the app ID
APP_ID=$(doctl apps list --format ID,Spec.Name --no-header 2>/dev/null | grep "$APP_NAME" | awk '{print $1}')

if [ -z "$APP_ID" ]; then
  echo "✗ App '$APP_NAME' not found. Is doctl authenticated?"
  exit 1
fi

echo ""
echo "► App ID: $APP_ID"
echo "► Triggering deployment..."

doctl apps create-deployment "$APP_ID" --force-rebuild --wait

echo ""
echo "✅ Trelea website deployed to https://trelea.com"
