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
$MenuTarget = Join-Path $UiDir "xboxlive_privatelobby.menu"
$MenuBackupPath = Join-Path $UiDir "xboxlive_privatelobby.menu.t5zr.preexisting.bak"

$Version = "0.6.0-beta.1"
$SaveFormat = "6"

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
    if (Test-Path $MenuTarget) {
        $currentMenuText = Get-Content -Path $MenuTarget -Raw -ErrorAction SilentlyContinue
        if ($null -eq $currentMenuText) {
            $currentMenuText = ""
        }

        if ($currentMenuText -match "T5ZR_MENU_OVERRIDE") {
            Remove-Item $MenuTarget -Force
            Write-Host "[T5ZR] Menu T5ZR supprime -> $MenuTarget"

            if (Test-Path $MenuBackupPath) {
                Move-Item -Path $MenuBackupPath -Destination $MenuTarget -Force
                Write-Host "[T5ZR] Menu precedent restaure -> $MenuTarget"
            }
        }
        else {
            Write-Warning "Le menu actuellement installe n'est pas celui de T5ZR ; aucune suppression effectuee."
        }
    }
    elseif (Test-Path $MenuBackupPath) {
        Move-Item -Path $MenuBackupPath -Destination $MenuTarget -Force
        Write-Host "[T5ZR] Menu precedent restaure -> $MenuTarget"
    }
    else {
        Write-Host "[T5ZR] Aucun menu T5ZR a supprimer."
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
				exec "xpartygo";
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
		#define T5ZR_CAN_RESUME ( IS_LOBBY_HOST && dvarInt( zr_sv_valid ) == 1 && dvarInt( zr_sv_format ) == 6 && T5ZR_SUPPORTED_SAVE_MAP )
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
										T5ZR_CAN_RESUME )
'@

    if (-not $menu.Contains($minPlayersBlock)) {
        throw "Le menu Plutonium upstream ne correspond pas au template T5ZR attendu (button anchor)."
    }
    $menu = $menu.Replace($minPlayersBlock, $resumeButton)

    return "// T5ZR_MENU_OVERRIDE v0.6.0-beta.1 - generated from Plutonium client-raw-assets $MenuUpstreamCommit`n" + $menu
}

if ($InstallMenu) {
    New-Item -ItemType Directory -Path $UiDir -Force | Out-Null

    if (Test-Path $MenuTarget) {
        $existingMenuText = Get-Content -Path $MenuTarget -Raw -ErrorAction SilentlyContinue
        if ($null -eq $existingMenuText) {
            $existingMenuText = ""
        }

        if ($existingMenuText -notmatch "T5ZR_MENU_OVERRIDE") {
            if (-not (Test-Path $MenuBackupPath)) {
                Copy-Item -Path $MenuTarget -Destination $MenuBackupPath -Force
                Write-Host "[T5ZR] Backup menu existant -> $MenuBackupPath"
            }
            else {
                Write-Warning "Un menu custom non-T5ZR existe deja et un backup T5ZR existe aussi."
                Write-Warning "Le fichier actuel sera remplace car -InstallMenu a ete demande explicitement."
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
    Set-Content -Path $MenuTarget -Value $patchedMenu -Encoding ASCII
    Write-Host "[T5ZR] Menu Resume genere et installe -> $MenuTarget"
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
Ensure-ArchivedDvar "zr_sv_world_adapter" "none"

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
Write-Host "[T5ZR] Save format : v6 (compatible avec les saves v6 de 0.5.0-beta.2)."
Write-Host "[T5ZR] Le menu optionnel utilise directement la save v6 existante."
Write-Host ""
Write-Host "[T5ZR] Commandes console :"
Write-Host "       set zr_status 1       -> etat/save"
Write-Host "       set zr_save_now 1     -> save manuelle"
Write-Host "       set zr_resume 1       -> armer la reprise, puis map_restart"
Write-Host "       set zr_clear_save 1   -> effacer la save"
if ($InstallMenu) {
    Write-Host ""
    Write-Host "[T5ZR] Dans le lobby prive, utilise : T5ZR - RESUME GAME"
}
