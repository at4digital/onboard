#!/usr/bin/env bash
# AT4 Digital — partner onboarding bootstrap
# Handles GitHub auth, then fetches and runs the full onboarding script
# from the private at4digital/claude-biz-brain repo.
#
# Run: bash <(curl -s https://raw.githubusercontent.com/at4digital/onboard/main/setup.sh)

set -euo pipefail

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           AT4 Digital — Onboarding Bootstrap                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# [1] Homebrew
if ! command -v brew &>/dev/null; then
  echo "→ Installing Homebrew (may take a few minutes)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo "✓ Homebrew ready"
else
  echo "✓ Homebrew already installed"
fi

# [2] GitHub CLI
if ! command -v gh &>/dev/null; then
  echo "→ Installing GitHub CLI..."
  brew install gh
  echo "✓ gh installed"
else
  echo "✓ gh already installed"
fi

# [3] GitHub auth
echo ""
echo "→ Log in with your AT4 GitHub account (mehes.pal@at4digital.com)"
echo "  A browser window will open — sign in and approve."
echo ""
if ! gh auth status &>/dev/null; then
  gh auth login --web --git-protocol https
fi
echo "✓ GitHub authenticated"

# [4] Fetch full onboarding script into a temp file, then run it interactively
#     (temp file instead of pipe so stdin stays connected to terminal for prompts)
TMPFILE=$(mktemp /tmp/at4-onboard-XXXXXX.sh)
trap 'rm -f "$TMPFILE"' EXIT

echo ""
echo "→ Fetching onboarding script from AT4 private repo..."
gh api repos/at4digital/claude-biz-brain/contents/onboard_partner.sh \
  --jq '.content' | base64 -d > "$TMPFILE"

echo "→ Running full onboarding script..."
echo ""
bash "$TMPFILE"
