$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceScript = Join-Path $RepoRoot "src\zombie_resume.gsc"

if (-not (Test-Path $SourceScript)) {
    Write-Error "Impossible de trouver src\zombie_resume.gsc. Lance install.ps1 depuis le depot complet."
}

$PlutoniumRoot = Join-Path $env:LOCALAPPDATA "Plutonium"
$PluginDir = Join-Path $PlutoniumRoot "plugins"
$T5Root = Join-Path $PlutoniumRoot "storage\t5"
$SpScriptsDir = Join-Path $T5Root "scripts\sp"

$MapFolders = @(
    "zombie_theater",        # Kino der Toten
    "zombie_pentagon",      # Five
    "zombie_cosmodrome",    # Ascension
    "zombie_coast",         # Call of the Dead
    "zombie_temple",        # Shangri-La
    "zombie_moon",          # Moon
    "zombie_cod5_prototype",# Nacht der Untoten
    "zombie_cod5_asylum",   # Verruckt
    "zombie_cod5_sumpf",    # Shi No Numa
    "zombie_cod5_factory"   # Der Riese
)

Write-Host "[T5ZR] Plutonium root: $PlutoniumRoot"

New-Item -ItemType Directory -Path $PluginDir -Force | Out-Null
New-Item -ItemType Directory -Path $SpScriptsDir -Force | Out-Null

foreach ($MapFolder in $MapFolders) {
    $TargetDir = Join-Path $SpScriptsDir $MapFolder
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    Copy-Item -Path $SourceScript -Destination (Join-Path $TargetDir "zombie_resume.gsc") -Force
    Write-Host "[T5ZR] Installed GSC -> $TargetDir"
}

Write-Host ""
Write-Host "[T5ZR] Installation des dossiers terminee."
Write-Host "[T5ZR] Il reste a installer t5-gsc-utils.dll manuellement ici :"
Write-Host "       $PluginDir\t5-gsc-utils.dll"
Write-Host ""
Write-Host "[T5ZR] t5-gsc-utils: https://github.com/alicealys/t5-gsc-utils"
Write-Host "[T5ZR] Premier test recommande: Kino der Toten (zombie_theater)."
