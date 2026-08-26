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

New-Item -ItemType Directory -Path $ZombiesScriptsDir -Force | Out-Null

foreach ($OldCopy in $OldScriptTargets) {
    if (Test-Path $OldCopy) {
        Remove-Item $OldCopy -Force
        Write-Host "[T5ZR] Ancienne copie supprimee -> $OldCopy"
    }
}

Copy-Item -Path $SourceScript -Destination $ScriptTarget -Force
Write-Host "[T5ZR] GSC installe -> $ScriptTarget"

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
Write-Host "[T5ZR] Fichier attendu :"
Write-Host "       $ScriptTarget"
Write-Host ""
Write-Host "[T5ZR] Lance Kino. A l'apparition du joueur, tu dois voir a l'ecran :"
Write-Host "       T5ZR 0.2.1-native-test actif"
Write-Host ""
Write-Host "[T5ZR] Test manuel : ouvre la VRAIE console en jeu (pas le chat) puis tape :"
Write-Host "       set zr_status 1"
Write-Host "       set zr_save_now 1"
Write-Host ""
Write-Host "[T5ZR] En fin de manche, l'autosave surveille maintenant directement level.round_number."
Write-Host "[T5ZR] Un message 'sauvegarde OK' doit apparaitre a l'ecran."
