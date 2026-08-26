# Codex instructions for T5 Zombies Resume

## Goal

Build a reliable host-side save/resume layer for BO1 Zombies on Plutonium T5 at stable round boundaries.

## Safety boundary

Do not implement Steam/VAC bypasses, anti-cheat evasion, Cheat Engine workflows, process injection, binary patching or stealth behavior. Use Plutonium-supported GSC runtime behavior.

## Current architecture (0.5.0-beta.2)

- Runtime: `src/zombie_resume.gsc`.
- No external DLL.
- Save format: v6.
- Persistence: archived `zr_sv_*` dvars registered by `install.ps1`.
- Autosave: direct observation of `level.round_number` advancing.
- Resume: `set zr_resume 1` + `map_restart` until menu integration lands.
- Player identity: strict `GetGuid()`; no name fallback.
- Player state: points, scoreboard fields, stat mirrors, weapons/ammo, selected weapon and perks.
- Perks: stock `maps\_zombiemode_perks::give_perk`.
- Special rounds: stock hellhound scheduler state is persisted/restored.
- Kino adapter: power, permanent routes, curtains and fully-linked teleporter.

## Validated in game

- GSC loading on T5 r5346;
- persistence across full game exit;
- round, points, weapons, ammo and perk resume;
- strict per-player state;
- Kino power and opened-route reconstruction.

Beta.2 specifically needs validation for scoreboard network fields and hellhound scheduler continuity.

## Development rules

1. Save/reconstruct only at stable round boundaries unless a subsystem proves otherwise.
2. Validate map and format before mutating state.
3. Match players by GUID only.
4. Restore a player/slot only once.
5. Prefer stock Zombies functions for systems with side effects.
6. Keep scoreboard network fields and `stats[]` mirrors synchronized.
7. Preserve special-round scheduler variables rather than recomputing random schedules.
8. If a saved special round is already active, restore its stock spawn function before gameplay consumes the round.
9. Treat world state as map-specific.
10. Keep blocker visuals, triggers, paths and zone flags synchronized.
11. Do not claim partial Mystery Box/EE/timer support.
12. Do not mark a feature stable before real in-game testing.

## Important upstream references

- `plutoniummod/t5-scripts`
- `ZM/Common/maps/_zombiemode.gsc`
- `ZM/Common/maps/_zombiemode_score.gsc`
- `ZM/Common/maps/_zombiemode_ai_dogs.gsc`
- `ZM/Common/maps/_laststand.gsc`
- Kino map scripts under `ZM/Maps/Kino der Toten`.
