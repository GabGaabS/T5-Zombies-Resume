# T5 Zombies Resume

Host-only save/resume for **Call of Duty: Black Ops Zombies** on **Plutonium T5**.

![Version](https://img.shields.io/badge/version-0.6.0--beta.1-blue)
![Status](https://img.shields.io/badge/status-public%20beta-yellow)
![Platform](https://img.shields.io/badge/platform-Plutonium%20T5-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

T5ZR lets the host stop a private Zombies session at a round boundary, close the game, and continue later with the same players and loadouts.

## Current status

`0.6.0-beta.1` adds the first menu integration on top of the v6 save runtime.

The save layer already covers:

- round;
- points and total score;
- weapons and clip/reserve ammo;
- selected weapon;
- perks;
- coop scoreboard kills/headshots/downs/revives;
- strict per-player matching through `GetGuid()`;
- hellhound scheduler state;
- Kino power and permanent opened routes;
- Kino stage curtain and fully-linked teleporter state.

## Install

Close Plutonium completely, then run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

This installs the GSC runtime only.

### Optional Resume Game button

To add **T5ZR - RESUME GAME** to the private Zombies lobby:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -InstallMenu
```

The menu integration is optional because T5 UI overrides can conflict with other menu mods.

The installer:

1. downloads the pinned public `xboxlive_privatelobby.menu` raw asset from Plutonium's `client-raw-assets` repository;
2. applies the small T5ZR patch locally;
3. backs up an existing custom lobby menu before replacing it;
4. writes the generated override to the local T5 `ui` folder.

T5ZR does **not** redistribute Plutonium's full menu asset in this repository.

Remove the T5ZR menu layer and restore the previous menu with:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -RemoveMenu
```

The GSC/save runtime remains installed.

## Using the menu

When a valid v6 save exists and you are the private-lobby host, a new button should appear:

```text
T5ZR - RESUME GAME
```

Selecting it:

- chooses the saved map;
- sets the Zombies gametype;
- arms `zr_resume`;
- starts the match.

A normal **Start Match** explicitly clears `zr_resume`, so it starts a fresh game.

The console fallback still works:

```text
set zr_status 1
set zr_resume 1
map_restart
```

## Save format

0.6.0-beta.1 still uses **save format v6**, so existing v6 saves from 0.5.0-beta.2 remain compatible.

## Install paths

Runtime:

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

Optional generated menu override:

```text
%localappdata%\Plutonium\storage\t5\ui\xboxlive_privatelobby.menu
```

Persistent save dvars:

```text
%localappdata%\Plutonium\storage\t5\players\config.cfg
```

## Known limitations

Not currently reconstructed:

- Mystery Box location/history;
- active teleporter cooldown;
- temporary traps and powerups;
- living zombies / exact mid-round positions;
- Easter Egg and sidequest progress;
- RNG state;
- full map-specific world state outside implemented adapters.

The optional menu integration is new in 0.6.0-beta.1 and needs real r5346 validation before being called stable.

## Plutonium r5346

No external DLL is required. The old `t5-gsc-utils.dll` prototype dependency is not used.

## Reporting a bug

Please include:

- Plutonium build;
- map;
- player count;
- saved round;
- expected vs. actual result;
- relevant `[T5ZR]` console lines.

For menu bugs, also say whether the button appears and whether a different UI/menu mod is installed.

Do not post full GUIDs, IPs, tokens or personal filesystem paths.

## Scope and safety

T5ZR is intended for **private Plutonium T5 Zombies sessions**. It contains no VAC bypass, anti-cheat evasion, process injection or memory patching.

## Credits

Built from public BO1/T5 script references in [`plutoniummod/t5-scripts`](https://github.com/plutoniummod/t5-scripts) and tested in-game.

The optional menu patch is generated locally from Plutonium's public `client-raw-assets` source rather than redistributing that menu file.

Development is substantially assisted by **ChatGPT / OpenAI Codex** for research, implementation and review.

## License

MIT — see [LICENSE](LICENSE).
