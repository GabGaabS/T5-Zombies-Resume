# Codex instructions for T5 Zombies Resume

## Goal

Build a reliable host-side save/resume layer for BO1 Zombies on Plutonium T5, saving at stable round boundaries and reconstructing gameplay state after a new process/map start.

## Non-negotiable safety boundary

Do not implement or suggest:

- Steam/VAC bypasses;
- anti-cheat evasion;
- Cheat Engine workflows;
- process injection into vanilla Steam BO1;
- binary patching of `BlackOps.exe` / `BlackOpsMP.exe`;
- stealth/hiding behavior.

Prefer Plutonium-supported GSC and stock T5 engine/script behavior. Keep the project for private Zombies.

## Current architecture (0.3.0-rc1)

- `src/zombie_resume.gsc` is the runtime script.
- No external DLL is required.
- `t5-gsc-utils.dll` must not be treated as a dependency; on the tested T5 r5346 setup it caused a startup failure on `ddl/stats.ddl`.
- Runtime path: `%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc`.
- Save data is stored in archived `zr_sv_*` dvars pre-registered with `seta` in T5 SP/ZM `config.cfg` by `install.ps1`.
- Save format is v3.
- Autosave watches `level.round_number` for a forward transition.
- Player identity is strict native `getGuid()` matching.
- Player names are metadata only and must never be used as a restore fallback.
- A saved player slot may be claimed only once in a resumed session.
- A player entity gets at most one restore attempt, preventing re-application on later respawns.
- Resume request is currently `set zr_resume 1` followed by `map_restart` on the already loaded saved map.

## Important upstream references

- https://github.com/plutoniummod/t5-scripts
- https://plutonium.pw/docs/

Use stock scripts to verify engine methods and Zombies side effects before adding new gameplay state.

## Development rules

1. Never restore halfway through an active round unless a future design proves it safe.
2. Validate save validity, format, map and round before mutating gameplay state.
3. Never restore one player's state to another player on an ambiguous identity match. Safe failure is preferred.
4. Use GUID identity for co-op save slots. Do not reintroduce name fallback.
5. Restore stock gameplay through stock GSC helpers when those helpers have meaningful side effects.
6. Add one subsystem at a time, beginning with Kino der Toten.
7. For every new saved field, document capture timing, restore timing, persistence behavior and possible stock-script races.
8. Avoid copying full Treyarch stock scripts into this repository.
9. Keep custom client assets optional; host-only installation is a core goal.
10. Do not call a release stable until the relevant path has been tested in a real game session.

## Current validated behavior

Observed working during r5346 testing:

- GSC loads without the external plugin;
- visible runtime activation message;
- autosave when advancing rounds;
- save data survives a normal full process exit after archived dvars were added;
- manual resume restores the saved round and basic player state.

## Next validation target

Before promoting `0.3.0-rc1` to stable `0.3.0`, run a real co-op resume test with at least two players who intentionally have different points/weapons. Confirm:

- each returning GUID gets its own saved slot;
- no slot can be applied to two players;
- a player is not restored again on later respawn;
- a new/unknown GUID remains on stock Zombies state;
- full-exit persistence still works with the new v3 GUID fields.

Only after that should work expand to perks or map/world state, or to a menu-level `Reprendre la partie` UI.
