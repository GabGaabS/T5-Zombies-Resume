# Changelog

## 0.5.0-beta.1 - 2026-08-26

- Save format v5.
- Persist round scoreboard stats: kills, kill tracker, headshots, downs, revives, zombie gibs and perk-consumption counter.
- Add the first map-specific world adapter for Kino der Toten.
- Save and restore Kino power state through the stock `power_on` flag path.
- Save and restore Kino permanent route flags and open matching `zombie_door` / `zombie_debris` entities without charging players again.
- Save and restore the Kino stage curtain completion flag.
- Preserve a fully-linked Kino teleporter; half-completed linking and cooldown timers intentionally reset.
- Keep strict GUID player matching and one-restore-per-slot protection.
- Keep perks, weapons, ammo and points from v4.
- Add installer persistence keys for the v5 player stats and Kino world adapter.
- Rewrite README for public beta use and move the AI-development note to Credits.

### Not included in this beta

- Mystery Box location/history.
- Teleporter cooldown or an in-progress teleport.
- Active traps/powerups.
- Easter Egg / quest state.
- Mid-round zombies, positions or RNG state.
- Map-specific world adapters outside Kino.

## 0.4.0-rc1 - 2026-08-26

- Save format v4.
- Save active Zombies perks per GUID-matched player.
- Recognize the eight standard BO1 Zombies perk identifiers plus their stock `_upgrade` variants.
- Restore perks through Treyarch's stock `maps\_zombiemode_perks::give_perk` path so gameplay effects, HUD and lifecycle are rebuilt.
- Restore perks before primary weapons so Mule Kick can precede restoration of a third gun.
- Archive per-player `perk_count` and up to 16 perk slots in `config.cfg`.
- Require a fresh v4 autosave; v3 snapshots are intentionally rejected by the v4 resume path.

## 0.3.0-rc1 - 2026-08-26

- Save format v3.
- Match players strictly by engine `GetGuid()`.
- Remove name fallback to prevent one player's snapshot being applied to another player.
- Each saved slot can be claimed once per resumed session.
- Each player entity is restored at most once.
- Persist GUID fields through archived `zr_sv_*` dvars.
- Add `set zr_clear_save 1`.
- Keep the runtime GSC-only with no external DLL.

## 0.2.x native test - 2026-08-26

- Removed `t5-gsc-utils.dll` after confirming a startup crash on the tested Plutonium T5 r5346 setup.
- Switched persistence to native dvars.
- Added installer-managed `seta` archive entries in T5 `players/config.cfg` so custom save dvars survive a normal full process exit.
- Replaced end-round notify dependency with direct `level.round_number` observation.
- Added visible in-game save/status messages.

## 0.1.0 - 2026-08-25

- Initial experimental host-side save/resume implementation.
- End-of-round autosave.
- Per-map JSON saves and one backup save.
- Player matching by GUID with unique-name testing fallback.
- Round, points, primary weapons, clip/reserve ammo and selected weapon restoration.
- `zsave`, `zstatus`, `zresume` host console commands.
