# Codex instructions for T5 Zombies Resume

## Goal

Reliable host-side round-boundary save/resume for BO1 Zombies on Plutonium T5.

## Safety boundary

No Steam/VAC bypass, anti-cheat evasion, process injection, memory patching or stealth behavior.

## Current architecture (0.6.0-beta.1)

- Runtime: `src/zombie_resume.gsc`.
- Save format: v6.
- Persistence: archived `zr_sv_*` dvars.
- Strict player identity: `GetGuid()`.
- Player state: score, scoreboard fields, stat mirrors, weapons/ammo, selected weapon, perks.
- Hellhound scheduler state is persisted/restored.
- Kino adapter handles stable power/routes/curtain/linked-teleporter state.
- Optional frontend integration: generated private-lobby UI override.
- UI install: `install.ps1 -InstallMenu`.
- UI removal: `install.ps1 -RemoveMenu`.
- The full Plutonium lobby raw asset must not be committed into this repository; fetch the pinned public upstream asset and patch it locally.

## Validated in game

- persistence across full exit;
- points/weapons/ammo/perks;
- strict per-player state;
- Kino power and opened routes.

Scoreboard/hellhound beta.2 fixes and the 0.6 menu layer still need their final real-game validation before stable status.

## Rules

1. Stable round boundaries only unless a subsystem proves otherwise.
2. Validate map/format before state mutation.
3. GUID-only player matching.
4. Restore each player/slot once.
5. Keep network scoreboard fields and internal stats synchronized.
6. Preserve special-round schedulers; do not re-roll them on resume.
7. Prefer stock Zombies lifecycle functions.
8. Treat world state as map-specific.
9. Keep UI integration optional and reversible.
10. Do not overwrite an unrelated custom menu without a backup.
11. Do not redistribute upstream raw UI assets without a clear redistribution basis.
12. Keep console controls as fallback.
13. Do not mark features stable without real in-game testing.
