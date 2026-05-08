#!/bin/bash
# Lore — One-time setup
# Agentic intelligence graph and delivery engine
#
# Clones the Lore framework to ~/.lore/.plugin/ and installs the /lore commands.
# After setup, connect a project with: /lore:setup <repo-url> <alias>

set -e

REPO="https://github.com/Gerald-Illy/lore.git"
TARGET="$HOME/.lore/.plugin"
CMDS="$HOME/.claude/commands/lore"

# Step 1 — Clone or update Lore framework
if [ -d "$TARGET/.git" ]; then
  echo "Lore already exists at $TARGET — pulling latest..."
  git -C "$TARGET" pull
else
  echo "Cloning Lore to $TARGET..."
  mkdir -p "$HOME/.lore"
  git clone "$REPO" "$TARGET"
fi

# Step 2 — Copy /lore commands into Claude Code's global commands directory
echo ""
echo "Installing /lore commands in Claude Code..."

mkdir -p "$CMDS"
cp "$TARGET/commands/"* "$CMDS/"

echo "✅ Commands installed at $CMDS"

echo ""
echo "Done. Open Claude Code and run:"
echo "  /lore:setup github:<Owner>/<Repo> <alias>"
echo ""
echo "Example:"
echo "  /lore:setup github:YourOrg/YourProject myproject"
