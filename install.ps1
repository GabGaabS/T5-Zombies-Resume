$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceScript = Join-Path $RepoRoot "src\zombie_resume.gsc"

if (-not (Test-Path $SourceScript)) {
    Write-Error "Impossible de trouver src\zombie_resume.gsc. Lance install.ps1 depuis le depot complet."
}

$PlutoniumRoot = Join-Path $env:LOCALAPPDATA "Plutonium"
$PluginDir = Join-Path $PlutoniumRoot "plugins"
$PluginPath = Join-Path $PluginDir "t5-gsc-utils.dll"
$DisabledPluginPath = Join-Path $PluginDir "t5-gsc-utils.dll.disabled"

$T5Root = Join-Path $PlutoniumRoot "storage\t5"
$PlayersDir = Join-Path $T5Root "players"
$ConfigPath = Join-Path $PlayersDir "config.cfg"
$ConfigBackupPath = Join-Path $PlayersDir "config.cfg.t5zr.bak"
$SpScriptsDir = Join-Path $T5Root "scripts\sp"
$ZombiesScriptsDir = Join-Path $SpScriptsDir "zom"
$ScriptTarget = Join-Path $ZombiesScriptsDir "zombie_resume.gsc"

# T5 r5346 loads generic scripts/sp scripts in the frontend as well.
# Keep T5 Zombies Resume under scripts\sp\zom so it only loads for Zombies.
$OldScriptTargets = @(
    (Join-Path $SpScriptsDir "zombie_resume.gsc"),
    (Join-Path (Join-Path $SpScriptsDir "zombie_theater") "zombie_resume.gsc"),
    (Join-Path (Join-Path $SpScriptsDir "zombie_pentagon") "zombie_resume.gsc"),
    (Join-Path (Join-Path $SpScriptsDir "zombie_cosmodrome") "zombie_resume.gsc"),
    (Join-Path (Join-Path $SpScriptsDir "zombie_coast") "zombie_resume.gsc"),
    (Join-Path (Join-Path $SpScriptsDir "zombie_temple") "zombie_resume.gsc"),
    (Join-Path (Join-Path $SpScriptsDir "zombie_moon") "zombie_resume.gsc"),
    (Join-Path (Join-Path $SpScriptsDir "zombie_cod5_prototype") "zombie_resume.gsc"),
    (Join-Path (Join-Path $SpScriptsDir "zombie_cod5_asylum") "zombie_resume.gsc"),
    (Join-Path (Join-Path $SpScriptsDir "zombie_cod5_sumpf") "zombie_resume.gsc"),
    (Join-Path (Join-Path $SpScriptsDir "zombie_cod5_factory") "zombie_resume.gsc")
)

Write-Host "[T5ZR] Plutonium root: $PlutoniumRoot"
Write-Host "[T5ZR] IMPORTANT : ferme completement Plutonium avant d'executer cet installateur."

New-Item -ItemType Directory -Path $ZombiesScriptsDir -Force | Out-Null
New-Item -ItemType Directory -Path $PlayersDir -Force | Out-Null

foreach ($OldCopy in $OldScriptTargets) {
    if (Test-Path $OldCopy) {
        Remove-Item $OldCopy -Force
        Write-Host "[T5ZR] Ancienne copie supprimee -> $OldCopy"
    }
}

Copy-Item -Path $SourceScript -Destination $ScriptTarget -Force
Write-Host "[T5ZR] GSC installe -> $ScriptTarget"

# BO1/T5 does not persist arbitrary script-created dvars across a full process
# exit. Registering them with `seta` in the T5SP/ZM config gives them the
# archive flag. The GSC can then update them with SetDvar and T5 writes the
# latest values back to config.cfg on a normal game exit.
if (-not (Test-Path $ConfigPath)) {
    New-Item -ItemType File -Path $ConfigPath -Force | Out-Null
    Write-Host "[T5ZR] config.cfg cree -> $ConfigPath"
}

if (-not (Test-Path $ConfigBackupPath)) {
    Copy-Item -Path $ConfigPath -Destination $ConfigBackupPath -Force
    Write-Host "[T5ZR] Backup config cree -> $ConfigBackupPath"
}

$script:ConfigText = Get-Content -Path $ConfigPath -Raw -ErrorAction SilentlyContinue
if ($null -eq $script:ConfigText) {
    $script:ConfigText = ""
}

$script:ArchivedAdded = 0

function Ensure-ArchivedDvar {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$DefaultValue
    )

    $escapedName = [Regex]::Escape($Name)
    $pattern = "(?mi)^\s*seta\s+" + $escapedName + "(?:\s+|$)"

    if ($script:ConfigText -notmatch $pattern) {
        $line = 'seta ' + $Name + ' "' + $DefaultValue + '"'
        Add-Content -Path $ConfigPath -Value $line
        $script:ConfigText += "`r`n" + $line
        $script:ArchivedAdded++
    }
}

# Save metadata.
Ensure-ArchivedDvar "zr_sv_valid" "0"
Ensure-ArchivedDvar "zr_sv_format" "2"
Ensure-ArchivedDvar "zr_sv_map" ""
Ensure-ArchivedDvar "zr_sv_round" "0"
Ensure-ArchivedDvar "zr_sv_reason" ""
Ensure-ArchivedDvar "zr_sv_player_count" "0"

# Up to four co-op players, each with up to three primary weapons.
for ($p = 0; $p -lt 4; $p++) {
    Ensure-ArchivedDvar "zr_sv_p${p}_name" ""
    Ensure-ArchivedDvar "zr_sv_p${p}_score" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_score_total" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_current_weapon" "none"
    Ensure-ArchivedDvar "zr_sv_p${p}_weapon_count" "0"

    for ($w = 0; $w -lt 3; $w++) {
        Ensure-ArchivedDvar "zr_sv_p${p}_w${w}_name" ""
        Ensure-ArchivedDvar "zr_sv_p${p}_w${w}_clip" "0"
        Ensure-ArchivedDvar "zr_sv_p${p}_w${w}_stock" "0"
    }
}

Write-Host "[T5ZR] Dvars de sauvegarde archives dans : $ConfigPath"
if ($script:ArchivedAdded -gt 0) {
    Write-Host "[T5ZR] $($script:ArchivedAdded) entree(s) seta ajoutee(s)."
} else {
    Write-Host "[T5ZR] Les entrees seta existaient deja ; aucune sauvegarde existante n'a ete ecrasee."
}

Write-Host ""
Write-Host "[T5ZR] IMPORTANT r5346 : aucune DLL n'est requise pour cette version."

if (Test-Path $PluginPath) {
    Write-Warning "t5-gsc-utils.dll est encore actif ici : $PluginPath"
    Write-Warning "Sur la configuration r5346 testee, cette DLL provoque un crash au demarrage sur ddl/stats.ddl."
    Write-Host "[T5ZR] Ferme Plutonium puis desactive-la avec :"
    Write-Host "       Rename-Item `"$PluginPath`" `"t5-gsc-utils.dll.disabled`""
}
elseif (Test-Path $DisabledPluginPath) {
    Write-Host "[T5ZR] t5-gsc-utils est deja desactive : $DisabledPluginPath"
}
else {
    Write-Host "[T5ZR] Aucun t5-gsc-utils actif detecte. C'est correct pour la version native."
}

Write-Host ""
Write-Host "[T5ZR] Installation terminee."
Write-Host "[T5ZR] GSC : $ScriptTarget"
Write-Host "[T5ZR] Persistance : $ConfigPath"
Write-Host ""
Write-Host "[T5ZR] TEST PERSISTANCE :"
Write-Host "  1. Lance Kino et termine une manche jusqu'au message 'sauvegarde OK'."
Write-Host "  2. Quitte BO1/Plutonium normalement par le menu."
Write-Host "  3. Relance Plutonium, lance Kino, puis console : set zr_status 1"
Write-Host "  4. Le message doit encore afficher le numero de save precedent."
Write-Host "  5. Pour reprendre : set zr_resume 1 puis map_restart"
