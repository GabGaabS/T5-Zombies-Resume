# Changelog

## 0.3.0-rc1 - 2026-08-26

- Save format bumped to v3.
- Player identity is now stored and matched strictly with native `GetGuid()`.
- Removed player-name fallback during restore to prevent multiple players resolving to the same save slot.
- Added per-session slot claiming so one saved slot cannot be applied to two connected players.
- Added one-shot restore guard so a player's snapshot is not re-applied on later respawns.
- Unknown/new players are left with stock Zombies state instead of inheriting another player's snapshot.
- Added `zr_clear_save` control.
- Installer now archives per-player GUID fields and v3 metadata in T5 `config.cfg`.
- Installer keeps existing save values and only adds missing `seta` entries.
- Documentation updated for the working GSC-only r5346 path, full-exit persistence, and v3 migration.

Known limitation before final `0.3.0`: GUID-safe restore still needs one real multi-player validation pass after the 0.2.x slot-collision bug report.

## 0.2.1-native-test - 2026-08-26

- Removed dependency on `t5-gsc-utils.dll` after confirming a startup crash on Plutonium T5 r5346.
- Switched to native GSC dvars for save data.
- Autosave changed to direct `level.round_number` monitoring.
- Added visible in-game save/status messages.
- Added installer-managed archived `seta` dvars so save data survives a normal full game exit.
- Full-exit save persistence and manual resume were validated in testing.
- Player matching by name remained unsafe in co-op and was replaced in v3.

## 0.1.0 - 2026-08-25

- Initial experimental host-side save/resume implementation.
- End-of-round autosave.
- Per-map JSON saves and one backup save.
- Player matching by GUID with unique-name testing fallback.
- Round, points, primary weapons, clip/reserve ammo and selected weapon restoration.
- `zsave`, `zstatus`, `zresume` host console commands.
- No stock GSC includes in the runtime script; stock score HUD helper resolved dynamically.
