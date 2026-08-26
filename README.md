# T5 Zombies Resume

Host-only save/resume for **Call of Duty: Black Ops Zombies** on **Plutonium T5**.

![Version](https://img.shields.io/badge/version-0.5.0--beta.2-blue)
![Status](https://img.shields.io/badge/status-public%20beta-yellow)
![Platform](https://img.shields.io/badge/platform-Plutonium%20T5-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

T5ZR lets the host stop a private Zombies session at a round boundary, close the game, and continue later with the same players and loadouts.

## Current status

`0.5.0-beta.2` is the version prepared for the first public beta.

Validated during real Plutonium T5 r5346 testing:

- no external DLL required;
- automatic round-boundary saves;
- save data survives a full BO1/Plutonium restart;
- round, points, weapons and ammo restoration;
- perks, including Jugger-Nog's actual gameplay effect;
- strict per-player restore through `GetGuid()`;
- Kino der Toten power and permanent opened routes.

Beta.2 fixes two issues found during the Kino beta.1 test:

- the coop scoreboard now restores the networked `kills`, `headshots`, `downs` and `revives` fields as well as the script stat mirrors;
- the hellhound scheduler is saved/restored, including the next dog round, dog-round count and a dog round that was already queued at the saved boundary.

## What is saved

For up to four players:

- player GUID;
- current points and total score;
- scoreboard kills, headshots, downs and revives;
- Zombies stat/kill-tracker mirrors;
- up to three primary weapons;
- clip and reserve ammo;
- selected weapon;
- active BO1 Zombies perks.

Session state also includes the hellhound round scheduler when the current map uses stock dog rounds.

On **Kino der Toten**, the world adapter additionally stores:

- power;
- permanent door/debris route state;
- stage curtain state;
- whether the teleporter was fully linked.

Saves are designed around a stable round boundary. T5ZR is not a RAM snapshot.

## Install

Close Plutonium completely, then run from the repository folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The runtime is installed to:

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

Persistent `zr_sv_*` dvars are registered in the T5 Zombies `players/config.cfg`. The installer creates `config.cfg.t5zr.bak` before modifying it for the first time.

### Plutonium r5346

T5ZR does **not** use `t5-gsc-utils.dll`. On the development setup that DLL caused an early `ddl/stats.ddl` startup failure, so users coming from the old prototype should keep it disabled.

## Use

Autosave is automatic when the game advances to the next round:

```text
T5ZR: sauvegarde OK - prochaine manche X
```

Check the current save:

```text
set zr_status 1
```

Resume:

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

A proper **Resume Game** menu entry is planned; the beta still uses console controls.

## Save compatibility

Beta.2 uses **save format v6**.

A v5 save from beta.1 is not partially interpreted as v6. After installing beta.2, finish one round to create a fresh v6 snapshot before testing resume.

## Known limitations

Not currently reconstructed:

- Mystery Box location/history;
- teleporter cooldown or an in-progress teleport;
- active traps and temporary powerups;
- living zombies / mid-round positions;
- Easter Egg and sidequest progress;
- RNG state;
- map-specific world state outside implemented adapters.

Other BO1 Zombies maps can still use the player/round layer, but map-specific systems may reset unless an adapter exists.

## Reporting a bug

Please include the Plutonium build, map, player count, saved round, expected/actual result and the relevant `[T5ZR]` console lines.

For special-round bugs, `set zr_status 1` now prints the saved dog-round state too.

Do not publish full GUIDs, IPs, account tokens or personal filesystem paths.

See [Troubleshooting](docs/troubleshooting.md), [Save format](docs/save-format.md) and [beta test checklist](docs/testing-v0.5.md).

## Scope and safety

T5 Zombies Resume is intended for **private Plutonium T5 Zombies sessions**. It contains no VAC bypass, anti-cheat evasion, process injection, memory patching or modification of vanilla Steam BO1.

## Credits

Built from the public BO1/T5 script references in [`plutoniummod/t5-scripts`](https://github.com/plutoniummod/t5-scripts) and validated through real in-game testing.

The project is developed with substantial assistance from **ChatGPT / OpenAI Codex** for research, implementation and review. Features are still tested in-game before being treated as working.

## License

MIT — see [LICENSE](LICENSE).
