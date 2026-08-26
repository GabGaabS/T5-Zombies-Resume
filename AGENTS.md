# Codex instructions for T5 Zombies Resume

## Goal

Build a reliable host-side save/resume layer for BO1 Zombies on Plutonium T5, saving only at stable round boundaries and reconstructing state after a new process/map start.

## Non-negotiable safety boundary

Do not implement or suggest:

- Steam/VAC bypasses;
- anti-cheat evasion;
- Cheat Engine workflows;
- process injection into vanilla Steam BO1;
- binary patching of `BlackOps.exe` / `BlackOpsMP.exe`;
- stealth/hiding behavior.

Use Plutonium-supported GSC behavior only for the active runtime.

## Current architecture (0.4.0-rc1)

- Runtime: `src/zombie_resume.gsc`.
- Install path: `%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc`.
- No external DLL.
- `t5-gsc-utils.dll` must remain disabled on the tested r5346 setup because it caused an early `ddl/stats.ddl` startup failure.
- Save format: v4.
- Persistence: custom `zr_sv_*` dvars pre-registered with `seta` in T5 `players/config.cfg` by `install.ps1`.
- Autosave: direct observation of `level.round_number` advancing.
- Resume request: `set zr_resume 1` followed by `map_restart` during the current development UI flow.
- Player identity: strict engine `GetGuid()` matching; no name fallback.
- Player snapshot: score, score total, up to three primaries, clip/reserve ammo, selected weapon and active perks.
- Perk restoration: stock `maps\_zombiemode_perks::give_perk(perk, false)` path.

## Current known-good development evidence

Real tests have validated:

- GSC loading on current Plutonium T5 r5346;
- no-DLL startup;
- autosave trigger;
- archived dvar persistence across a normal full game exit;
- round/score/weapon/ammo resume.

The 0.4.0-rc1 perk layer still needs its in-game validation pass before promotion to stable.

## Development rules

1. Never restore halfway through an active round unless a future design proves it safe.
2. Validate map and save format before mutating state.
3. Match players by GUID only. An unmatched player must remain untouched.
4. Restore each player and saved slot at most once per resumed session.
5. Prefer stock Zombies functions when a subsystem has side effects.
6. For perks, do not replace stock `give_perk` with only `SetPerk`; that would skip important setup such as HUD/lifecycle and perk-specific effects.
7. Restore Mule Kick before rebuilding a third primary weapon.
8. Add map/world state one subsystem at a time. Do not infer generic behavior for power, doors, Box, teleporters or Easter Eggs.
9. Keep custom client assets optional; host-only installation is a core goal.
10. Do not announce a feature as stable before a real in-game test.

## Important upstream references

- `plutoniummod/t5-scripts`
- `ZM/Common/maps/_zombiemode_perks.gsc`
- map-specific Zombies scripts under `ZM/Maps/...`

## Next validation task

Test v0.4.0-rc1 in a two-player private Zombies session:

1. give each player different points, weapons and perks;
2. include Jugger-Nog and preferably Mule Kick/third weapon when available;
3. create a v4 autosave at a round boundary;
4. close BO1/Plutonium normally;
5. relaunch and resume;
6. confirm each GUID receives only its own snapshot;
7. confirm perk icons and actual gameplay effects are restored;
8. capture exact `[T5ZR]` lines for any mismatch.

Only after that test should work begin on generic equipment or map/world adapters such as power and opened doors.
