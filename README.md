# T5 Zombies Resume

Host-only save/resume for **Call of Duty: Black Ops Zombies** on **Plutonium T5**.

![Version](https://img.shields.io/badge/version-0.8.0--beta.1-blue)
![Status](https://img.shields.io/badge/status-public%20beta-yellow)
![Platform](https://img.shields.io/badge/platform-Plutonium%20T5-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

T5ZR lets the host stop a private Zombies session at a round boundary, close the game, and continue later with the same players and loadouts.

## Current status

`0.8.0-beta.1` adds multi-level Pack-a-Punch while keeping guarded v5/v6/v7 save compatibility.

The save layer already covers:

- round;
- points and total score;
- weapons and clip/reserve ammo;
- selected weapon;
- Bowie/melee state and tactical grenades (including cymbal monkeys);
- perks;
- persistent total run time;
- optional corner HUD with round time, total time and zombies remaining;
- multi-level Pack-a-Punch for supported upgraded firearms;
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

When a valid v5, v6, v7 or v8 save exists and you are the private-lobby host, a new button should appear:

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

## HUD

The HUD is enabled by default:

- top-left: current round time;
- top-right: total run time (continued after a resume);
- bottom-right: zombies remaining (alive + still waiting to spawn).

Console toggles:

```text
set zr_hud 0
set zr_hud 1
set zr_hud_round_time 0/1
set zr_hud_total_time 0/1
set zr_hud_zombies 0/1
```

Autosave confirmation now uses a compact top-center HUD message instead of the large bold center message.

## Multi-level Pack-a-Punch

BO1's normal Pack-a-Punch remains unchanged and is **PAP level 1**. Once a supported weapon is already upgraded, using the same Pack-a-Punch machine again applies T5ZR levels 2+.

Default tuning:

| Level | Extra cost | Damage vs PAP 1 | Effective clip | Reserve |
| --- | ---: | ---: | ---: | ---: |
| PAP 1 | stock 5000 | base | base | base |
| PAP 2 | 7500 | +20% | +15% | +20% |
| PAP 3 | 10000 | +40% | +30% | +40% |
| PAP 4 | 12500 | +60% | +45% | +60% |
| PAP 5 | 15000 | +80% | +60% | +80% |

The percentages are additive relative to the stock PAP weapon. Settings are archived and configurable:

```text
set zr_pap_multi 0/1
set zr_pap_max_level 5
set zr_pap_cost_base 7500
set zr_pap_cost_step 2500
set zr_pap_damage_percent 20
set zr_pap_clip_percent 15
set zr_pap_stock_percent 20
```

The first beta intentionally excludes script-heavy/explosive special weapons such as Ray Gun, Wunderwaffe/Tesla, Thunder Gun, Winter's Howl/freezegun, launchers, explosive crossbow, ballistic knife and Mustang & Sally. Conventional rifles, SMGs, LMGs, pistols and shotguns are the target.

The enlarged magazine is implemented in GSC by restoring the configured effective capacity after a normal reload while consuming the corresponding reserve ammo. T5ZR logs a warning if the r5346 engine clamps a requested clip/reserve value; that behavior still needs real-game validation.

## Save format

0.8.0-beta.1 writes **save format v8**. Existing **v5, v6 and v7** saves remain readable and migrate to v8 on the next autosave.

Legacy behavior remains conservative:

- v5 restores its native fields and leaves the hellhound scheduler on stock behavior;
- v6 additionally restores its saved hellhound scheduler;
- v7 additionally restores total run time and offhand state;
- v5/v6/v7 have no saved multi-PAP levels, so an already Pack-a-Punched weapon resumes as PAP level 1;
- v8 stores the multi-PAP level alongside each saved primary weapon.

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

The multi-PAP ammo scaling, HUD/offhand additions and optional menu integration need continued real r5346 validation before being called stable.

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
