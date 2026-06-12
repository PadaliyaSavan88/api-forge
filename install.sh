#!/bin/bash
# api-forge installer (curl fallback — prefer: npx skills add PadaliyaSavan88/api-forge)
# Usage: ./install.sh backend
#        ./install.sh all
#
# One-liner (no clone needed):
#   curl -fsSL https://raw.githubusercontent.com/PadaliyaSavan88/api-forge/main/install.sh | bash -s backend

set -e

SKILLS_DIR="$HOME/.claude/commands"
REPO_RAW="https://raw.githubusercontent.com/PadaliyaSavan88/api-forge/main/skills"
AVAILABLE_SKILLS=("backend")

install_skill() {
  local skill=$1
  echo "Installing /$skill skill..."
  mkdir -p "$SKILLS_DIR"
  curl -fsSL "$REPO_RAW/$skill/SKILL.md" -o "$SKILLS_DIR/$skill.md"
  echo "✓ /$skill installed → $SKILLS_DIR/$skill.md"
  echo "  Restart Claude Code or open a new session to use it."
}

if [ "$1" = "all" ]; then
  for skill in "${AVAILABLE_SKILLS[@]}"; do
    install_skill "$skill"
  done
elif [ -n "$1" ]; then
  install_skill "$1"
else
  echo ""
  echo "Usage: ./install.sh <skill-name|all>"
  echo ""
  echo "Available skills:"
  for skill in "${AVAILABLE_SKILLS[@]}"; do
    echo "  • $skill"
  done
  echo ""
fi
