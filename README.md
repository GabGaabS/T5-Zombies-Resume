# T5 Zombies Resume

Host-only save/resume for **Call of Duty: Black Ops Zombies** on **Plutonium T5**.

![Version](https://img.shields.io/badge/version-0.5.0--beta.1-blue)
![Status](https://img.shields.io/badge/status-public%20beta-yellow)
![Platform](https://img.shields.io/badge/platform-Plutonium%20T5-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

> The goal is simple: stop a private Zombies session at a round boundary, close the game, and continue later with the same host and players.

## Current status

`0.5.0-beta.1` is the first version prepared for broader testing.

Already validated on Plutonium T5 r5346 during development:

- GSC loads from `scripts\sp\zom`;
- no external DLL is required;
- end-of-round autosave;
- save data survives a full BO1/Plutonium restart;
- round restoration;
- points, primary weapons and ammo restoration;
- perks, including Jugger-Nog gameplay effects;
- strict per-player restore through `GetGuid()`.

New in this beta and still requiring wider testing:

- kills, headshots, downs and revives;
- Kino der Toten power state;
- Kino permanent doors/debris;
- fully-linked Kino teleporter state.

## What is saved

For up to four players:

- player GUID;
- points and total score;
- kills, headshots, downs, revives and gib/perk counters;
- up to three primary weapons;
- clip and reserve ammo;
- selected weapon;
- active BO1 Zombies perks.

On **Kino der Toten**, the v5 world adapter also stores:

- power on/off;
- permanent door/debris route state;
- stage curtain state;
- whether the teleporter was fully linked.

The save is taken at a round boundary. It is not a RAM snapshot.

## Install

Close Plutonium completely, then run from the repository folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The installer places the runtime at:

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

Persistent `zr_sv_*` dvars are registered in the T5 Zombies config so the save survives a full game restart. The installer creates `config.cfg.t5zr.bak` before modifying the config for the first time.

### Plutonium r5346

This version does **not** use `t5-gsc-utils.dll`. During development, the distributed DLL caused a `ddl/stats.ddl` startup failure on the tested r5346 setup.

If you installed it for an older T5ZR build, keep it disabled.

## Use

Autosave is automatic when the next round starts. You should see:

```text
T5ZR: sauvegarde OK - prochaine manche X
```

Check the current save:

```text
set zr_status 1
```

Resume the current map:

```text
set zr_resume 1
map_restart
```

Manual save:

```text
set zr_save_now 1
```

Delete the save:

```text
set zr_clear_save 1
```

A proper **Resume Game** menu entry is planned; console controls are still used in the beta.

## Save compatibility

`0.5.x` uses **save format v5**. Older v4 saves are left untouched but are not resumed by the v5 runtime. Finish one round with the new version to create a v5 save.

## Known limitations

The following state is intentionally not restored yet:

- Mystery Box location/history;
- teleporter cooldown or an in-progress teleport;
- active traps and temporary powerups;
- living zombies or mid-round positions;
- Easter Egg / quest progress;
- RNG state;
- full world state on maps other than Kino.

Other maps can still use the player/round save layer, but their map-specific world state currently resets normally.

## Reporting a bug

Please include:

- Plutonium T5 build number;
- map;
- number of players;
- saved round;
- what was expected vs. what was restored;
- the relevant `[T5ZR]` console lines.

Do not post account tokens, private identifiers or full logs containing information you do not want public.

See [Troubleshooting](docs/troubleshooting.md) and [Save format](docs/save-format.md) for more detail.

## Scope and safety

T5 Zombies Resume is intended for **private Plutonium T5 Zombies sessions**. It does not contain VAC bypasses, anti-cheat evasion, process injection, memory patching or modifications to vanilla Steam BO1.

## Credits

Built from the public BO1/T5 script references in [`plutoniummod/t5-scripts`](https://github.com/plutoniummod/t5-scripts) and tested manually on Plutonium T5.

The project is developed with substantial assistance from **ChatGPT / OpenAI Codex** for research, code generation and review. Runtime behavior is still validated through real in-game testing before being treated as working.

## License

MIT — see [LICENSE](LICENSE).
