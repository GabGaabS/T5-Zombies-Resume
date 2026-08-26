# Codex instructions for T5 Zombies Resume

## Goal

Build a reliable host-side save/resume layer for BO1 Zombies on Plutonium T5. Saves are taken at stable round boundaries and reconstructed after a new process/map start.

## Non-negotiable safety boundary

Do not implement or suggest:

- Steam/VAC bypasses;
- anti-cheat evasion;
- Cheat Engine workflows;
- process injection into vanilla Steam BO1;
- binary patching of `BlackOps.exe` / `BlackOpsMP.exe`;
- stealth/hiding behavior.

Use Plutonium-supported GSC behavior for the runtime.

## Current architecture (0.5.0-beta.1)

- Runtime: `src/zombie_resume.gsc`.
- Install path: `%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc`.
- No external DLL.
- `t5-gsc-utils.dll` should remain disabled on the tested r5346 setup because it caused an early `ddl/stats.ddl` startup failure.
- Save format: v5.
- Persistence: custom `zr_sv_*` dvars pre-registered with `seta` in T5 `players/config.cfg` by `install.ps1`.
- Autosave: direct observation of `level.round_number` advancing.
- Resume request: `set zr_resume 1` followed by `map_restart` while the menu integration is still pending.
- Player identity: strict engine `GetGuid()` matching; no name fallback.
- Player snapshot: score, total score, round stats, up to three primaries, clip/reserve ammo, selected weapon and active perks.
- Perk restoration: stock `maps\_zombiemode_perks::give_perk(perk, false)` path.
- First map adapter: Kino der Toten (`kino_v1`) for power, permanent doors/debris, curtain completion and fully-linked teleporter state.

## Validated during real in-game testing

The development test setup has validated:

- GSC loading on Plutonium T5 r5346;
- no-DLL startup;
- round-boundary autosave;
- archived dvar persistence across a normal full game exit;
- round, points, weapons and ammo resume;
- strict per-player state instead of copying the host snapshot to mates;
- active perk restoration, including Jugger-Nog gameplay effect.

The new v5 round-stat and Kino world adapter code still requires its in-game validation pass before it can be called stable.

## Development rules

1. Save/reconstruct only at stable round boundaries unless a future subsystem explicitly proves a mid-round restore safe.
2. Validate map and save format before mutating state.
3. Match players by GUID only. An unmatched player must remain untouched.
4. Restore each player and saved slot at most once per resumed session.
5. Prefer stock Zombies functions when a subsystem has side effects.
6. For perks, keep the stock `give_perk` path; do not reduce restoration to `SetPerk`.
7. Restore Mule Kick before rebuilding a third primary weapon.
8. Restore session scoreboard values after perk setup so stock perk bookkeeping does not overwrite the saved counters.
9. Treat world state as map-specific. Verify the map's stock flags/entities before adding a field.
10. Keep blocker visuals, triggers, paths and zone flags synchronized when restoring doors/debris.
11. Do not fake support for a subsystem with a partial state restore. Mystery Box, Easter Eggs and temporary timers stay unsupported until the complete stock lifecycle is understood.
12. Keep custom client assets optional; host-only installation is a core goal.
13. Never mark a feature stable before real in-game testing.

## Important upstream references

- `plutoniummod/t5-scripts`
- `ZM/Common/maps/_zombiemode.gsc`
- `ZM/Common/maps/_zombiemode_perks.gsc`
- `ZM/Common/maps/_zombiemode_blockers.gsc`
- `ZM/Maps/Kino der Toten/maps/zombie_theater.gsc`
- `ZM/Maps/Kino der Toten/maps/zombie_theater_teleporter.gsc`

## Next validation task

Validate `0.5.0-beta.1` on Kino before creating a stable release:

1. install with Plutonium fully closed;
2. start a private session and create distinct player states;
3. open at least one permanent door/debris route;
4. turn on power;
5. accumulate visible kills/headshots/downs/revives where practical;
6. optionally fully link the teleporter;
7. advance a round and confirm the v5 autosave;
8. exit BO1/Plutonium normally;
9. relaunch, confirm `format=5` and `world=kino_v1` through `set zr_status 1`;
10. resume and verify player state, stats, power, the opened route and teleporter state;
11. capture exact `[T5ZR]` lines for any mismatch.

Do not expand to Mystery Box or another map until this test passes cleanly.
