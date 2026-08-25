# T5 Zombies Resume

Experimental **host-side save/resume mod for Call of Duty: Black Ops 1 Zombies on Plutonium T5**.

The target workflow is: finish a Zombies round with friends, quit the game, then later restart the same map and continue from the next round with the same players' points, weapons and ammo.

> **Status: v0.1 experimental / first in-game validation required.** Start on Kino der Toten. This project does not patch `BlackOps.exe`, hook Steam/VAC, use Cheat Engine, or implement anti-cheat bypasses.

## Host only

The MVP is designed so **only the host needs this GSC plus `t5-gsc-utils`**. Friends join the private match normally. There are no custom client assets in v0.1.

## What v0.1 saves

Autosave is triggered at BO1's `between_round_over` notification, after the stock script has incremented `level.round_number`.

- map name
- next round number
- player GUID and display name
- current points and total score
- primary weapons
- clip ammo and reserve ammo
- selected weapon when possible
- one previous `.backup.json` per map

Not yet restored: perks, doors/debris, power, Mystery Box, traps, Pack-a-Punch/world state, Easter Egg state, or zombies alive mid-round.

## Requirements

1. BO1 usable with Plutonium T5.
2. Plutonium T5.
3. [`alicealys/t5-gsc-utils`](https://github.com/alicealys/t5-gsc-utils) on the **host**:

```text
%localappdata%\Plutonium\plugins\t5-gsc-utils.dll
```

`t5-gsc-utils` provides `readFile`/`writeFile`, JSON helpers and host console commands.

## Install

Recommended T5 Zombies script path:

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

Copy `src\zombie_resume.gsc` there. If that loader path does not execute on your current T5 build, use the documented fallback discussed in `docs/troubleshooting.md` (`raw\scripts\sp`).

## Host console commands

`zsave` — manually save the current state. Prefer using it between rounds.

`zstatus` — print mod version, current map/round, save path and autoresume flag.

`zresume` — arm the current map's save and execute `map_restart`.

## Resume after fully closing Plutonium

The GSC is not running in the menu, so arm the load before starting the map:

```text
set zr_autoresume 1
```

Then start the **same Zombies map** and invite the same friends. The flag is consumed after the save is accepted.

Example: a game autosaves after round 15. The stored `round` is 16. On the next launch, `set zr_autoresume 1` then start Kino. The mod attempts to set the stock round counter to 16 before normal spawning and restores each player's inventory on spawn by GUID.

## Save location

`t5-gsc-utils` uses T5's `fs_homepath` as its working directory. The mod writes:

```text
zombie_resume/saves/<mapname>.json
zombie_resume/saves/<mapname>.backup.json
```

## First validation: Kino

1. Host Kino with one friend.
2. Reach round 3 and note both players' points/weapons/ammo.
3. Finish the round and confirm `[T5ZR] Saved ...` in the host console.
4. Run `zstatus`.
5. Run `zresume` and verify round + both inventories.
6. Quit Plutonium completely.
7. Relaunch, run `set zr_autoresume 1`, invite the same friend, start Kino.
8. Verify the same restoration across a full process restart.
9. If anything fails, keep the exact Plutonium console error/log and fix that before adding perks/world state.

## Safety boundary

Keep this project confined to Plutonium private Zombies. The mod itself is GSC and does not modify Steam executables, patch memory or bypass anti-cheat. `t5-gsc-utils` is a separate Plutonium plugin dependency loaded from Plutonium's plugin directory.

No third-party mod can guarantee zero account/platform risk, so do not load experimental plugins into vanilla Steam multiplayer.

## Roadmap

- v0.1 — round + points + primary weapons/ammo
- v0.2 — perks using stock Zombies side effects
- v0.3 — Kino power + doors/debris + Mystery Box
- v0.4 — map adapters for Five/Ascension/CotD/Shangri-La/Moon
- v0.5 — save slots, stronger corruption handling, migration/versioning

## References

- https://github.com/plutoniummod/t5-scripts
- https://github.com/alicealys/t5-gsc-utils
- https://www.plutonium.pw/docs/client/t5/loading-mods/

## License

MIT. See `LICENSE`.
