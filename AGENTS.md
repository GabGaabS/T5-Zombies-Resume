# Codex instructions for T5 Zombies Resume

## Goal

Build a reliable host-side save/resume layer for BO1 Zombies on Plutonium T5, saving only at stable round boundaries and reconstructing game state after a new process/map start.

## Non-negotiable safety boundary

Do not implement or suggest:

- Steam/VAC bypasses;
- anti-cheat evasion;
- Cheat Engine workflows;
- process injection into vanilla Steam BO1;
- binary patching of `BlackOps.exe` / `BlackOpsMP.exe`;
- stealth/hiding behavior.

Prefer Plutonium-supported GSC and the documented `t5-gsc-utils` plugin API. Keep the project usable in private Zombies.

## Current architecture

- `src/zombie_resume.gsc` is the runtime script.
- Host installs `t5-gsc-utils` separately.
- Save data is JSON under `fs_homepath/zombie_resume/saves/`.
- Server-console commands only (`command::add`), no client commands for the MVP.
- Autosave trigger: stock `between_round_over` notification.
- Player identity: `getGuid()`.
- Resume request: `zr_autoresume` dvar, consumed once on map startup.

## Important upstream references

- https://github.com/plutoniummod/t5-scripts
- https://github.com/alicealys/t5-gsc-utils

## Development rules

1. Never restore halfway through an active round unless a future design proves it safe.
2. Validate map and save format before mutating state.
3. Restore stock gameplay through stock GSC helpers when those helpers have side effects.
4. Add one subsystem at a time, beginning with Kino der Toten.
5. For every new saved field, document capture timing, restore timing, and possible stock-script races.
6. Avoid copying full Treyarch stock scripts into this repository.
7. Keep custom client assets optional; host-only installation is a core goal.

## Next task

Validate v0.1 against current Plutonium T5 and fix any GSC compile/runtime errors before adding perks or world state. Specifically verify command/JSON API names, script loader path, `getFunction`, weapon ammo methods, `zr_autoresume` persistence across `map_restart`, player spawn timing, and whether restored `level.round_number` is applied before stock `round_start()` consumes it.
