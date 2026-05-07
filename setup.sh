#!/bin/bash
# Lore — One-time setup
# Agentic intelligence graph and delivery engine
#
# Clones the Lore framework to ~/.lore and installs the /lore plugin globally.
# After setup, connect a project with: /lore:setup <repo-url> <alias>

set -e

REPO="https://github.com/Gerald-Illy/lore.git"
TARGET="$HOME/.lore"

# Step 1 — Clone or update Lore framework
if [ -d "$TARGET/.git" ]; then
  echo "Lore already exists at $TARGET — pulling latest..."
  git -C "$TARGET" pull
else
  echo "Cloning Lore to $TARGET..."
  git clone "$REPO" "$TARGET"
fi

# Step 2 — Install /lore plugin globally in Claude Code
echo ""
echo "Installing /lore plugin in Claude Code..."
if claude plugin install "$TARGET" --global 2>/dev/null; then
  echo "✅ Plugin installed."
else
  echo "⚠ Automatic install failed. Install manually:"
  echo "   claude plugin install $TARGET --global"
fi

echo ""
echo "Done. Open Claude Code and run:"
echo "  /lore:setup github:<Owner>/<Repo> <alias>"
echo ""
echo "Example:"
echo "  /lore:setup github:YourOrg/YourProject myproject"
