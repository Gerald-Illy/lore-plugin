# Lore — One-time setup (Windows PowerShell)
# Agentic intelligence graph and delivery engine
#
# Clones the Lore framework to ~/.lore/.plugin/ and installs the /lore commands.
# After setup, connect a project with: /lore:setup <repo-url> <alias>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$repo   = "https://github.com/Gerald-Illy/lore-plugin.git"
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

Write-Host @'

  ██╗      ██████╗ ██████╗ ███████╗
  ██║     ██╔═══██╗██╔══██╗██╔════╝
  ██║     ██║   ██║██████╔╝█████╗
  ██║     ██║   ██║██╔══██╗██╔══╝
  ███████╗╚██████╔╝██║  ██║███████╗
  ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

  Agentic intelligence graph & delivery engine
  ══════════════════════════════════════════════

  ✅  Plugin    →  ~/.lore/.plugin/
  ✅  Commands  →  ~/.claude/commands/lore/

  Open Claude Code and run:
    /lore:setup github:YourOrg/YourProject <alias>

  /lore for help

'@
