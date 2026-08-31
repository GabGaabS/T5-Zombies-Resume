# Codex instructions for T5 Zombies Resume

## Goal

Reliable host-side round-boundary save/resume for BO1 Zombies on Plutonium T5.

## Safety boundary

No Steam/VAC bypass, anti-cheat evasion, process injection, memory patching or stealth behavior.

## Current architecture (0.8.0-beta.22)

- Runtime: `src/zombie_resume.gsc`.
- Save format: **v8 only**.
- Persistence: archived `zr_sv_*` dvars.
- Strict player identity: `GetGuid()`.
- Persistent four-slot coop roster; absent players keep their saved slots.
- Player state: score/score total, scoreboard fields and stat mirrors, primaries, effective PAP ammo, selected primary, perks, Bowie/melee and tactical grenades.
- Per-weapon multi-PAP registry with virtual magazine + virtual reserve.
- Optional simultaneous AI cap via `zr_zombie_ai_limit` (stock 24, runtime clamp 1-32).
- Hellhound scheduler state is persisted/restored.
- Kino adapter handles stable power/routes/curtain/linked-teleporter state.
- Optional frontend integration: generated `mods/t5zr_resume_menu` mod with `ui/mod.txt`.
- UI install/remove: `install.ps1 -InstallMenu` / `-RemoveMenu`.
- The full Plutonium lobby raw asset must not be committed; fetch the pinned public upstream asset and patch it locally.

## Validated in game

- persistence across full exit;
- points/weapons/ammo/perks;
- strict per-player state;
- multi-PAP per-weapon pricing;
- virtual magazine behavior;
- stock-small configurable HUD on r5346;
- Kino power and opened routes.

## Rules

1. Stable round boundaries only. Do not add mid-round snapshot paths.
2. Validate save format/map before state mutation.
3. Current runtime supports v8 only; do not reintroduce v5/v6/v7 branches without a concrete requirement.
4. GUID-only player matching.
5. Restore each saved slot conservatively; do not let guests overwrite the persistent roster.
6. Keep network scoreboard fields and internal stats synchronized.
7. Preserve special-round schedulers; do not re-roll them on resume.
8. Prefer stock Zombies lifecycle functions.
9. Treat world state as map-specific.
10. Keep UI integration optional and reversible.
11. Do not overwrite an unrelated custom menu without a backup.
12. Do not redistribute upstream raw UI assets without a clear redistribution basis.
13. Keep console controls as fallback.
14. Do not mark features stable without real in-game testing.
15. Keep live HUD updates configstring-safe.

## Current rollback note

beta.20 all-map world-state code was rolled back after an r5346 compile failure. Reintroduce map adapters incrementally, one map per testable change, starting from the beta.19/beta.21 known-good runtime.
