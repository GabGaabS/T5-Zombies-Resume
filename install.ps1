param(
    [switch]$InstallMenu,
    [switch]$RemoveMenu
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceScript = Join-Path $RepoRoot "src\zombie_resume.gsc"

# Menu integration is generated locally from Plutonium's public raw asset.
# The full upstream menu is intentionally not redistributed by this repository.
$MenuUpstreamCommit = "7a6614b183c4b432ca9babcc045b554a4cbb710a"
$MenuUpstreamUrl = "https://raw.githubusercontent.com/plutoniummod/client-raw-assets/$MenuUpstreamCommit/t5/ui/xboxlive_privatelobby.menu"

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
$UiDir = Join-Path $T5Root "ui"
$LegacyMenuTarget = Join-Path $UiDir "xboxlive_privatelobby.menu"
$LegacyMenuBackupPath = Join-Path $UiDir "xboxlive_privatelobby.menu.t5zr.preexisting.bak"

# r5340+ loads T5 .menu overrides through a loaded fs_game mod using ui/mod.txt.
$ModsDir = Join-Path $T5Root "mods"
$MenuModName = "t5zr_resume_menu"
$MenuModDir = Join-Path $ModsDir $MenuModName
$MenuModUiDir = Join-Path $MenuModDir "ui"
$MenuTarget = Join-Path $MenuModUiDir "xboxlive_privatelobby.menu"
$MenuListTarget = Join-Path $MenuModUiDir "mod.txt"
$MenuDescriptionTarget = Join-Path $MenuModDir "description.txt"

$Version = "0.8.0-beta.23"
$SaveFormat = "8"

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

Write-Host "[T5ZR] T5 Zombies Resume $Version"
Write-Host "[T5ZR] Plutonium root: $PlutoniumRoot"
Write-Host "[T5ZR] IMPORTANT : ferme completement Plutonium avant d'executer cet installateur."

if ($InstallMenu -and $RemoveMenu) {
    Write-Error "Utilise soit -InstallMenu, soit -RemoveMenu, pas les deux."
}

if ($RemoveMenu) {
    if (Test-Path $MenuModDir) {
        $currentMenuText = ""
        if (Test-Path $MenuTarget) {
            $currentMenuText = Get-Content -Path $MenuTarget -Raw -ErrorAction SilentlyContinue
            if ($null -eq $currentMenuText) { $currentMenuText = "" }
        }

        if ($currentMenuText -match "T5ZR_MENU_OVERRIDE") {
            Remove-Item $MenuModDir -Recurse -Force
            Write-Host "[T5ZR] Mod menu T5ZR supprime -> $MenuModDir"
        }
        else {
            Write-Warning "Le dossier $MenuModDir existe mais ne ressemble pas au mod menu T5ZR ; aucune suppression automatique."
        }
    }

    # Clean up the obsolete pre-r5340 loose-menu install if it was created by T5ZR.
    if (Test-Path $LegacyMenuTarget) {
        $legacyText = Get-Content -Path $LegacyMenuTarget -Raw -ErrorAction SilentlyContinue
        if ($null -eq $legacyText) { $legacyText = "" }

        if ($legacyText -match "T5ZR_MENU_OVERRIDE") {
            Remove-Item $LegacyMenuTarget -Force
            Write-Host "[T5ZR] Ancien menu loose T5ZR supprime -> $LegacyMenuTarget"

            if (Test-Path $LegacyMenuBackupPath) {
                Move-Item -Path $LegacyMenuBackupPath -Destination $LegacyMenuTarget -Force
                Write-Host "[T5ZR] Menu loose precedent restaure -> $LegacyMenuTarget"
            }
        }
    }

    Write-Host "[T5ZR] Suppression du menu terminee. Le runtime GSC n'a pas ete desinstalle."
    exit 0
}

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

function Build-T5ZRMenuOverride {
    param(
        [Parameter(Mandatory = $true)][string]$BaseMenu
    )

    $menu = $BaseMenu -replace "`r`n", "`n"

    $startMacro = @'
#define SETUP_ACTION_STARTMATCH_CHEATS \
				exec "xpartygo";
'@

    $startReplacement = @'
#define SETUP_ACTION_STARTMATCH_CHEATS \
				exec "set zr_resume 0"; \
				exec "xpartygo";

		#define SETUP_ACTION_T5ZR_RESUME \
				if( T5ZR_CAN_RESUME ) { \
				if( dvarString( zr_sv_map ) == "zombie_theater" ) { setdvar ui_mapname "zombie_theater"; } \
				if( dvarString( zr_sv_map ) == "zombie_pentagon" ) { setdvar ui_mapname "zombie_pentagon"; } \
				if( dvarString( zr_sv_map ) == "zombie_cosmodrome" ) { setdvar ui_mapname "zombie_cosmodrome"; } \
				if( dvarString( zr_sv_map ) == "zombie_coast" ) { setdvar ui_mapname "zombie_coast"; } \
				if( dvarString( zr_sv_map ) == "zombie_temple" ) { setdvar ui_mapname "zombie_temple"; } \
				if( dvarString( zr_sv_map ) == "zombie_moon" ) { setdvar ui_mapname "zombie_moon"; } \
				if( dvarString( zr_sv_map ) == "zombie_cod5_prototype" ) { setdvar ui_mapname "zombie_cod5_prototype"; } \
				if( dvarString( zr_sv_map ) == "zombie_cod5_asylum" ) { setdvar ui_mapname "zombie_cod5_asylum"; } \
				if( dvarString( zr_sv_map ) == "zombie_cod5_sumpf" ) { setdvar ui_mapname "zombie_cod5_sumpf"; } \
				if( dvarString( zr_sv_map ) == "zombie_cod5_factory" ) { setdvar ui_mapname "zombie_cod5_factory"; } \
				setdvar ui_gametype "zom"; \
				setdvar zr_resume "1"; \
				exec "xpartygo"; \
				}
'@

    if (-not $menu.Contains($startMacro)) {
        throw "Le menu Plutonium upstream ne correspond pas au template T5ZR attendu (start macro)."
    }
    $menu = $menu.Replace($startMacro, $startReplacement)

    $hostMacros = @'
		#define IS_LOBBY_HOST		( gameHost() && inLobby() && dvarBool( xblive_privatematch ) )
		#define IS_NOT_LOBBY_HOST	( !gameHost() || !inLobby() || !dvarBool( xblive_privatematch ) )
'@

    $hostReplacement = @'
		#define IS_LOBBY_HOST		( gameHost() && inLobby() && dvarBool( xblive_privatematch ) )
		#define IS_NOT_LOBBY_HOST	( !gameHost() || !inLobby() || !dvarBool( xblive_privatematch ) )
		#define T5ZR_SUPPORTED_SAVE_MAP ( \
			dvarString( zr_sv_map ) == "zombie_theater" || \
			dvarString( zr_sv_map ) == "zombie_pentagon" || \
			dvarString( zr_sv_map ) == "zombie_cosmodrome" || \
			dvarString( zr_sv_map ) == "zombie_coast" || \
			dvarString( zr_sv_map ) == "zombie_temple" || \
			dvarString( zr_sv_map ) == "zombie_moon" || \
			dvarString( zr_sv_map ) == "zombie_cod5_prototype" || \
			dvarString( zr_sv_map ) == "zombie_cod5_asylum" || \
			dvarString( zr_sv_map ) == "zombie_cod5_sumpf" || \
			dvarString( zr_sv_map ) == "zombie_cod5_factory" )
		#define T5ZR_CAN_RESUME ( IS_LOBBY_HOST && dvarInt( zr_sv_valid ) == 1 && dvarInt( zr_sv_format ) == 8 && T5ZR_SUPPORTED_SAVE_MAP )
'@

    if (-not $menu.Contains($hostMacros)) {
        throw "Le menu Plutonium upstream ne correspond pas au template T5ZR attendu (host macros)."
    }
    $menu = $menu.Replace($hostMacros, $hostReplacement)

    $minPlayersBlock = @'
		FRAME_CHOICE_DVARFLOATLIST_FOCUS_VIS(	3, "@PLUTONIUM_MENU_MINPLAYERS_CAPS",
												sp_minplayers,
												{ "1" 1 "2" 2 "3" 3 "4" 4 },
												;,
												exec set ui_hint_text "@PLUTONIUM_MENU_MINPLAYERS_HINT"; exec set ui_show_arrow 1;,
												CLEARUIHINT, IS_LOBBY_HOST && dvarBool( com_useRawUDP ) )
'@

    $resumeButton = $minPlayersBlock + @'

		TEMP_CHOICE_BUTTON_FOCUS_VIS(	4, "T5ZR - RESUME GAME",
										SETUP_ACTION_T5ZR_RESUME,
										exec set ui_hint_text "Resume the saved T5ZR Zombies session"; exec set ui_show_arrow 1;,
										CLEARUIHINT,
										IS_LOBBY_HOST )
'@

    if (-not $menu.Contains($minPlayersBlock)) {
        throw "Le menu Plutonium upstream ne correspond pas au template T5ZR attendu (button anchor)."
    }
    $menu = $menu.Replace($minPlayersBlock, $resumeButton)

    return "// T5ZR_MENU_OVERRIDE v0.8.0-beta.23 - generated from Plutonium client-raw-assets $MenuUpstreamCommit`n" + $menu
}

if ($InstallMenu) {
    New-Item -ItemType Directory -Path $MenuModUiDir -Force | Out-Null

    # Remove only our obsolete loose override. Current Plutonium T5 expects
    # menu overrides inside a loaded mod (ui/mod.txt), not storage\t5\ui.
    if (Test-Path $LegacyMenuTarget) {
        $legacyMenuText = Get-Content -Path $LegacyMenuTarget -Raw -ErrorAction SilentlyContinue
        if ($null -eq $legacyMenuText) { $legacyMenuText = "" }

        if ($legacyMenuText -match "T5ZR_MENU_OVERRIDE") {
            Remove-Item $LegacyMenuTarget -Force
            Write-Host "[T5ZR] Ancien menu loose T5ZR supprime -> $LegacyMenuTarget"

            if (Test-Path $LegacyMenuBackupPath) {
                Move-Item -Path $LegacyMenuBackupPath -Destination $LegacyMenuTarget -Force
                Write-Host "[T5ZR] Ancien menu custom restaure -> $LegacyMenuTarget"
            }
        }
    }

    Write-Host "[T5ZR] Telechargement du menu officiel Plutonium (source publique)..."
    try {
        $response = Invoke-WebRequest -Uri $MenuUpstreamUrl -UseBasicParsing
        $baseMenu = $response.Content
    }
    catch {
        Write-Error "Impossible de telecharger le menu Plutonium depuis $MenuUpstreamUrl : $($_.Exception.Message)"
    }

    $patchedMenu = Build-T5ZRMenuOverride -BaseMenu $baseMenu

    # T5 r5340+ raw/IWD menu loading: ui/mod.txt is a MenuList and can override
    # an already-defined MenuDef with the same name.
    $menuList = @'
{
    loadMenu { "ui/xboxlive_privatelobby.menu" }
}
'@

    Set-Content -Path $MenuTarget -Value $patchedMenu -Encoding ASCII
    Set-Content -Path $MenuListTarget -Value $menuList -Encoding ASCII
    Set-Content -Path $MenuDescriptionTarget -Value "T5 Zombies Resume - private lobby Resume button" -Encoding ASCII

    Write-Host "[T5ZR] Mod menu installe -> $MenuModDir"
    Write-Host "[T5ZR] IMPORTANT : dans Black Ops, ouvre MODS et charge '$MenuModName'."
    Write-Host "[T5ZR] Ensuite ouvre Zombies > partie privee : le bouton T5ZR doit etre visible."
}
else {
    Write-Host "[T5ZR] Menu Resume non installe (optionnel)."
    Write-Host "[T5ZR] Pour l'ajouter : powershell -ExecutionPolicy Bypass -File .\install.ps1 -InstallMenu"
    Write-Host "[T5ZR] Pour le retirer : powershell -ExecutionPolicy Bypass -File .\install.ps1 -RemoveMenu"
}

# Custom save dvars need the archive flag to survive a full BO1/Plutonium exit.
# Registering them with `seta` in the T5 SP/ZM config gives them that flag.
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
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$DefaultValue
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

# Save metadata. Existing values are never overwritten by the installer.
Ensure-ArchivedDvar "zr_sv_valid" "0"
Ensure-ArchivedDvar "zr_sv_format" $SaveFormat
Ensure-ArchivedDvar "zr_sv_mod_version" $Version
Ensure-ArchivedDvar "zr_sv_map" ""
Ensure-ArchivedDvar "zr_sv_round" "0"
Ensure-ArchivedDvar "zr_sv_reason" ""
Ensure-ArchivedDvar "zr_sv_player_count" "0"
Ensure-ArchivedDvar "zr_sv_total_time_seconds" "0"
Ensure-ArchivedDvar "zr_sv_world_adapter" "none"

# HUD preferences. These are user-facing settings, not save-state fields.
Ensure-ArchivedDvar "zr_hud" "1"
Ensure-ArchivedDvar "zr_hud_round_time" "1"
Ensure-ArchivedDvar "zr_hud_total_time" "1"
Ensure-ArchivedDvar "zr_hud_zombies" "1"
Ensure-ArchivedDvar "zr_hud_scale_pct" "100"
Ensure-ArchivedDvar "zr_zombie_ai_limit" "30"
Ensure-ArchivedDvar "zr_zombie_ai_tuning_version" "0"

# Multi-Pack-a-Punch tuning. Stock PAP is level 1; T5ZR handles level 2+.
Ensure-ArchivedDvar "zr_pap_multi" "1"
Ensure-ArchivedDvar "zr_pap_special" "1"
Ensure-ArchivedDvar "zr_pap_max_level" "8"
Ensure-ArchivedDvar "zr_pap_cost_base" "7500"
Ensure-ArchivedDvar "zr_pap_cost_step" "2500"
Ensure-ArchivedDvar "zr_pap_damage_percent" "60"
Ensure-ArchivedDvar "zr_pap_clip_percent" "45"
Ensure-ArchivedDvar "zr_pap_stock_percent" "60"

# Special-round scheduler state. These fields preserve BO1's hellhound cycle
# across a resumed session instead of letting next_dog_round reset to 5-7.
Ensure-ArchivedDvar "zr_sv_dog_rounds_enabled" "0"
Ensure-ArchivedDvar "zr_sv_dog_round_active" "0"
Ensure-ArchivedDvar "zr_sv_dog_round_count" "0"
Ensure-ArchivedDvar "zr_sv_next_dog_round" "0"

# Kino world adapter (v1): stable round-boundary state only.
$KinoWorldDefaults = @{
    "zr_sv_kino_power" = "0"
    "zr_sv_kino_magic_box_foyer1" = "0"
    "zr_sv_kino_magic_box_crematorium1" = "0"
    "zr_sv_kino_vip_to_dining" = "0"
    "zr_sv_kino_magic_box_alleyway1" = "0"
    "zr_sv_kino_dining_to_dressing" = "0"
    "zr_sv_kino_magic_box_dressing1" = "0"
    "zr_sv_kino_magic_box_west_balcony2" = "0"
    "zr_sv_kino_magic_box_west_balcony1" = "0"
    "zr_sv_kino_curtains_done" = "0"
    "zr_sv_kino_teleporter_linked" = "0"
}

foreach ($Entry in $KinoWorldDefaults.GetEnumerator()) {
    Ensure-ArchivedDvar $Entry.Key $Entry.Value
}

# Up to four co-op players, each identified by engine GUID.
for ($p = 0; $p -lt 4; $p++) {
    Ensure-ArchivedDvar "zr_sv_p${p}_guid" ""
    Ensure-ArchivedDvar "zr_sv_p${p}_name" ""
    Ensure-ArchivedDvar "zr_sv_p${p}_score" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_score_total" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_current_weapon" "none"
    Ensure-ArchivedDvar "zr_sv_p${p}_weapon_count" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_melee_weapon" ""
    Ensure-ArchivedDvar "zr_sv_p${p}_tactical_weapon" ""
    Ensure-ArchivedDvar "zr_sv_p${p}_tactical_clip" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_tactical_stock" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_perk_count" "0"

    # Round scoreboard/stat state.
    Ensure-ArchivedDvar "zr_sv_p${p}_kills" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_kill_tracker" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_headshots" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_downs" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_revives" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_zombie_gibs" "0"
    Ensure-ArchivedDvar "zr_sv_p${p}_perks_stat" "0"

    for ($w = 0; $w -lt 3; $w++) {
        Ensure-ArchivedDvar "zr_sv_p${p}_w${w}_name" ""
        Ensure-ArchivedDvar "zr_sv_p${p}_w${w}_clip" "0"
        Ensure-ArchivedDvar "zr_sv_p${p}_w${w}_stock" "0"
        Ensure-ArchivedDvar "zr_sv_p${p}_w${w}_pap_level" "0"
    }

    for ($perk = 0; $perk -lt 16; $perk++) {
        Ensure-ArchivedDvar "zr_sv_p${p}_perk${perk}" ""
    }
}

Write-Host "[T5ZR] Dvars de sauvegarde archives dans : $ConfigPath"
if ($script:ArchivedAdded -gt 0) {
    Write-Host "[T5ZR] $($script:ArchivedAdded) entree(s) seta ajoutee(s)."
} else {
    Write-Host "[T5ZR] Toutes les entrees seta existaient deja ; aucune save n'a ete ecrasee."
}

Write-Host ""
Write-Host "[T5ZR] IMPORTANT r5346 : aucune DLL n'est requise."

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
    Write-Host "[T5ZR] Aucun t5-gsc-utils actif detecte. C'est correct."
}

Write-Host ""
Write-Host "[T5ZR] Installation terminee."
Write-Host "[T5ZR] Runtime attendu : $Version / save format v$SaveFormat"
Write-Host "[T5ZR] GSC : $ScriptTarget"
Write-Host "[T5ZR] Persistance : $ConfigPath"
Write-Host ""
Write-Host "[T5ZR] Save format : v8 uniquement. Les anciens formats v5/v6/v7 ne sont plus charges."
Write-Host "[T5ZR] beta.23 utilise 30 zombies simultanes par defaut avec 1 slot AI moteur de marge."
Write-Host ""
Write-Host "[T5ZR] Commandes console :"
Write-Host "       set zr_status 1       -> etat/save"
Write-Host "       set zr_resume 1       -> armer la reprise, puis map_restart"
Write-Host "       set zr_clear_save 1   -> effacer la save"
Write-Host "       set zr_hud 0/1        -> masquer/afficher tout le HUD T5ZR"
Write-Host "       set zr_hud_round_time 0/1"
Write-Host "       set zr_hud_total_time 0/1"
Write-Host "       set zr_hud_zombies 0/1"
Write-Host ""
Write-Host "[T5ZR] Multi-PAP (PAP stock = niveau 1) :"
Write-Host "       zr_pap_multi=1, zr_pap_special=1, max=8, couts extra=7500 + 2500/niveau"
Write-Host "       bonus/niveau extra : degats +60%, chargeur effectif +45%, reserve +60%"
Write-Host "       Ray Gun + Winter's Howl : degats + munitions"
Write-Host "       Thunder Gun + Wunderwaffe : munitions (effet special natif conserve)"
Write-Host "       PAP 8 par defaut ; la limite du code reste 10 via set zr_pap_max_level 10"
Write-Host "       Reglages : zr_pap_max_level, zr_pap_cost_base, zr_pap_cost_step,"
Write-Host "                  zr_pap_damage_percent, zr_pap_clip_percent, zr_pap_stock_percent"
Write-Host "       Le compteur natif de clip reste bride ; T5ZR emule les balles supplementaires."
Write-Host "       Zombies simultanes : defaut=30 ; set zr_zombie_ai_limit 32 puis map_restart pour tester le plafond."
Write-Host "       HUD : set zr_hud_scale_pct 45 puis map_restart pour le reduire davantage."
Write-Host ""
Write-Host "[T5ZR] Commandes de correction :"
Write-Host "       set zr_pap_status 1"
Write-Host "       set zr_cmd_player 0"
Write-Host "       set zr_pap_level 2 ; set zr_pap_set_level 1"
Write-Host "       set zr_points_amount 7500 ; set zr_give_points 1"
if ($InstallMenu) {
    Write-Host ""
    Write-Host "[T5ZR] Dans le lobby prive, utilise : T5ZR - RESUME GAME"
}
