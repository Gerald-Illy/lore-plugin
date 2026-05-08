# Lore — One-time setup (Windows PowerShell)
# Agentic intelligence graph and delivery engine
#
# Clones the Lore framework to ~/.lore/.plugin/ and installs the /lore commands.
# After setup, connect a project with: /lore:setup <repo-url> <alias>

$repo   = "https://github.com/Gerald-Illy/lore.git"
$target = "$HOME\.lore\.plugin"
$cmds   = "$HOME\.claude\commands\lore"

# Step 1 — Clone or update Lore framework
if (Test-Path "$target\.git") {
    Write-Host "Lore already exists at $target — pulling latest..."
    git -C $target pull
} else {
    Write-Host "Cloning Lore to $target..."
    New-Item -ItemType Directory -Path "$HOME\.lore" -Force | Out-Null
    git clone $repo $target
}

# Step 2 — Copy /lore commands into Claude Code's global commands directory
Write-Host ""
Write-Host "Installing /lore commands in Claude Code..."

if (-not (Test-Path $cmds)) {
    New-Item -ItemType Directory -Path $cmds -Force | Out-Null
}

Copy-Item -Path "$target\commands\*" -Destination $cmds -Force
Write-Host "✅ Commands installed at $cmds"

Write-Host ""
Write-Host "Done. Open Claude Code and run:"
Write-Host "  /lore:setup github:<Owner>/<Repo> <alias>"
Write-Host ""
Write-Host "Example:"
Write-Host "  /lore:setup github:YourOrg/YourProject myproject"
