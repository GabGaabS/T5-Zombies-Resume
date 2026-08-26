# Changelog

## 0.5.0-beta.2 - 2026-08-26

- Save format v6.
- Fix coop scoreboard restoration by saving/restoring BO1's networked player fields: `kills`, `headshots`, `downs` and `revives`.
- Keep the existing `stats[]` and `kill_tracker` mirrors in sync with the restored scoreboard state.
- Preserve the stock hellhound scheduler: dog rounds enabled, current dog-round flag, dog-round count and `next_dog_round`.
- Rebuild an already-queued dog round through the stock `_zombiemode_ai_dogs` functions instead of letting the resumed round fall back to a normal round.
- Add dog scheduler information to `zr_status` output.
- Add installer archive keys for the new scheduler fields.
- Require a fresh v6 autosave; beta.1 v5 snapshots are intentionally rejected.

## 0.5.0-beta.1 - 2026-08-26

- Save format v5.
- Persist round stat mirrors: kills, kill tracker, headshots, downs, revives, zombie gibs and perk-consumption counter.
- Add the first map-specific world adapter for Kino der Toten.
- Save and restore Kino power state through the stock `power_on` flag path.
- Save and restore Kino permanent route flags and matching `zombie_door` / `zombie_debris` entities without charging players again.
- Save and restore the Kino stage curtain completion flag.
- Preserve a fully-linked Kino teleporter; half-completed linking and cooldown timers intentionally reset.
- Keep strict GUID player matching, perks, weapons, ammo and points.

## 0.4.0-rc1 - 2026-08-26

- Save format v4.
- Save active Zombies perks per GUID-matched player.
- Restore perks through Treyarch's stock `maps\_zombiemode_perks::give_perk` path.
- Restore perks before primary weapons so Mule Kick can precede restoration of a third gun.

## 0.3.0-rc1 - 2026-08-26

- Save format v3.
- Match players strictly by engine `GetGuid()`.
- Remove name fallback.
- Each saved slot/player can be restored only once.
- Add `set zr_clear_save 1`.

## 0.2.x native test - 2026-08-26

- Removed `t5-gsc-utils.dll` after confirming a startup crash on the tested T5 r5346 setup.
- Switched persistence to native archived dvars.
- Replaced the end-round notify dependency with direct `level.round_number` observation.

## 0.1.0 - 2026-08-25

- Initial experimental host-side save/resume implementation.
