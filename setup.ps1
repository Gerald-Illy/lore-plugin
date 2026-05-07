# Lore — One-time setup (Windows PowerShell)
# Agentic intelligence graph and delivery engine
#
# Clones the Lore framework to ~/.lore and installs the /lore plugin globally.
# After setup, connect a project with: /lore:setup <repo-url> <alias>

$repo = "https://github.com/Gerald-Illy/lore.git"
$target = "$HOME\.lore"

# Step 1 — Clone or update Lore framework
if (Test-Path "$target\.git") {
    Write-Host "Lore already exists at $target — pulling latest..."
    git -C $target pull
} else {
    Write-Host "Cloning Lore to $target..."
    git clone $repo $target
}

# Step 2 — Install /lore plugin globally in Claude Code
Write-Host ""
Write-Host "Installing /lore plugin in Claude Code..."
try {
    claude plugin install "$target" --global
    Write-Host "✅ Plugin installed."
} catch {
    Write-Host "⚠ Automatic install failed. Install manually:"
    Write-Host "   claude plugin install $target --global"
}

Write-Host ""
Write-Host "Done. Open Claude Code and run:"
Write-Host "  /lore:setup github:<Owner>/<Repo> <alias>"
Write-Host ""
Write-Host "Example:"
Write-Host "  /lore:setup github:YourOrg/YourProject myproject"
