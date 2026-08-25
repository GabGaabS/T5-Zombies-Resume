$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceScript = Join-Path $RepoRoot "src\zombie_resume.gsc"

if (-not (Test-Path $SourceScript)) {
    Write-Error "Impossible de trouver src\zombie_resume.gsc. Lance install.ps1 depuis le depot complet."
}

$PlutoniumRoot = Join-Path $env:LOCALAPPDATA "Plutonium"
$PluginDir = Join-Path $PlutoniumRoot "plugins"
$PluginPath = Join-Path $PluginDir "t5-gsc-utils.dll"
$PluginUrl = "https://github.alicent.cat/t5-gsc-utils/t5-gsc-utils.dll"

$T5Root = Join-Path $PlutoniumRoot "storage\t5"
$SpScriptsDir = Join-Path $T5Root "scripts\sp"
$ScriptTarget = Join-Path $SpScriptsDir "zombie_resume.gsc"

# Previous installer versions copied the script into per-map folders.
# Current Plutonium T5 SP builds demonstrably load generic scripts directly
# from storage\t5\scripts\sp, so keep a single copy there to avoid duplicate loads.
$OldMapFolders = @(
    "zombie_theater",
    "zombie_pentagon",
    "zombie_cosmodrome",
    "zombie_coast",
    "zombie_temple",
    "zombie_moon",
    "zombie_cod5_prototype",
    "zombie_cod5_asylum",
    "zombie_cod5_sumpf",
    "zombie_cod5_factory"
)

Write-Host "[T5ZR] Plutonium root: $PlutoniumRoot"

New-Item -ItemType Directory -Path $PluginDir -Force | Out-Null
New-Item -ItemType Directory -Path $SpScriptsDir -Force | Out-Null

Copy-Item -Path $SourceScript -Destination $ScriptTarget -Force
Write-Host "[T5ZR] GSC installe -> $ScriptTarget"

foreach ($MapFolder in $OldMapFolders) {
    $OldCopy = Join-Path (Join-Path $SpScriptsDir $MapFolder) "zombie_resume.gsc"
    if (Test-Path $OldCopy) {
        Remove-Item $OldCopy -Force
        Write-Host "[T5ZR] Ancienne copie supprimee -> $OldCopy"
    }
}

Write-Host "[T5ZR] Telechargement de t5-gsc-utils depuis la source officielle..."
$TempPlugin = "$PluginPath.download"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $PluginUrl -OutFile $TempPlugin -UseBasicParsing

    if (-not (Test-Path $TempPlugin)) {
        throw "Le telechargement n'a cree aucun fichier."
    }

    $DownloadedSize = (Get-Item $TempPlugin).Length
    if ($DownloadedSize -lt 1024) {
        throw "Le fichier telecharge est anormalement petit ($DownloadedSize octets)."
    }

    Move-Item -Path $TempPlugin -Destination $PluginPath -Force
    $Hash = (Get-FileHash -Path $PluginPath -Algorithm SHA256).Hash

    Write-Host "[T5ZR] Plugin installe -> $PluginPath"
    Write-Host "[T5ZR] SHA256: $Hash"
}
catch {
    if (Test-Path $TempPlugin) {
        Remove-Item $TempPlugin -Force -ErrorAction SilentlyContinue
    }

    Write-Warning "Telechargement automatique de t5-gsc-utils impossible: $($_.Exception.Message)"
    Write-Host "[T5ZR] Telecharge-le manuellement ici :"
    Write-Host "       $PluginUrl"
    Write-Host "[T5ZR] Puis mets la DLL ici :"
    Write-Host "       $PluginPath"
    exit 1
}

Write-Host ""
Write-Host "[T5ZR] Installation terminee."
Write-Host "[T5ZR] Fichiers attendus :"
Write-Host "       $PluginPath"
Write-Host "       $ScriptTarget"
Write-Host ""
Write-Host "[T5ZR] FERME completement Plutonium s'il etait ouvert, puis relance-le."
Write-Host "[T5ZR] Lance une partie Zombies et cherche dans la console :"
Write-Host "       [T5ZR] T5 Zombies Resume v0.1.0 loaded"
Write-Host "[T5ZR] Puis teste : zstatus"
