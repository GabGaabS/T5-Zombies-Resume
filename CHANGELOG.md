# Changelog

## 0.8.0-beta.3 - 2026-08-28

- Fix `G_FindConfigstringIndex: overflow` caused by continuously changing HUD strings.
- Replace live round-time, total-time and zombies-remaining text updates with static labels plus numeric `SetValue()` elements.
- Keep the HUD safe for long sessions without consuming a new configstring every refresh.
- Reduce the autosave confirmation to a much smaller static top-center message.
- Keep save format v8 unchanged.

## 0.8.0-beta.2 - 2026-08-28

- Preserve absent players in a persistent four-slot coop roster keyed by GUID.
- Update present players in-place instead of rebuilding save slots from the current connection order.
- Add new players only when a free persistent slot exists.
- Treat unmatched players as guests when all four saved slots are occupied; guests never overwrite an existing saved player.
- Keep an absent player's last weapons, ammo, perks, stats, offhand state and multi-PAP levels until they return.
- Start a fresh roster on the first save of a normal non-resumed Start Match, preventing accidental campaign merges.
- Keep save format v8; no schema migration is required.

## 0.8.0-beta.1 - 2026-08-27

- Save format v8; v5/v6/v7 saves remain readable and migrate on the next autosave.
- Add multi-level Pack-a-Punch on the stock PAP machine for already-upgraded supported firearms.
- Default maximum is PAP 5.
- Default extra costs are 7500, 10000, 12500 and 15000 points for PAP 2-5.
- Default per-extra-level scaling is +20% firearm damage, +15% effective clip and +20% reserve.
- Register a stock Zombies damage callback and apply only the bonus damage, suppressing duplicate score/effect processing for the nested damage event.
- Refill the effective enlarged magazine after native reloads by moving the extra rounds from reserve.
- Persist the PAP level per saved primary weapon.
- Add archived multi-PAP tuning dvars.
- Exclude script-heavy/explosive special weapons from the first multi-PAP beta.
- Allow the optional Resume Game menu for v8 saves.

## 0.7.0-beta.2 - 2026-08-27

- Add backward-compatible resume for save format v5.
- Keep v6 compatibility and continue writing only save format v7.
- Guard legacy reads by format so stale newer fields cannot leak into a v5/v6 restore.
- For v5, restore its original GUID/player, score/stat, primary weapon/ammo, perk and Kino world fields.
- For v5, leave the hellhound scheduler on stock behavior because scheduler state was introduced in v6.
- For v5/v6, do not restore v7-only total-time or melee/tactical fields.
- Allow the optional **T5ZR - RESUME GAME** button for valid v5, v6 and v7 saves.
- Migrate legacy saves to v7 automatically on the next autosave.

## 0.7.0-beta.1 - 2026-08-27

- Save format v7; v6 saves remain readable and migrate on the next autosave.
- Add optional per-player HUD: round time, persistent total run time and zombies remaining.
- Count zombies as stock pending spawns plus currently alive enemies.
- Move autosave confirmation to a compact top-center HUD message at half-size.
- Preserve melee state, including the Bowie knife.
- Preserve tactical grenade state and exact ammo, including cymbal monkeys.
- Add archived HUD toggles: `zr_hud`, `zr_hud_round_time`, `zr_hud_total_time`, `zr_hud_zombies`.

## 0.6.0-beta.1 - 2026-08-26

- Keep save format v6; v6 saves from 0.5.0-beta.2 remain compatible.
- Add an optional **T5ZR - RESUME GAME** button to the private Zombies lobby.
- Resume button is visible only to the private-lobby host with a valid supported v6 save.
- Resume button selects the saved stock Zombies map, sets `zr_resume=1` and starts the match.
- Normal **Start Match** clears `zr_resume` to prevent accidental resume.
- Add `install.ps1 -InstallMenu` for menu integration.
- Add `install.ps1 -RemoveMenu` to remove T5ZR UI and restore a pre-existing menu backup.
- Do not redistribute Plutonium's full lobby menu asset; the installer downloads a pinned public upstream raw asset and applies the T5ZR patch locally.
- Keep the console resume flow as fallback.

## 0.5.0-beta.2 - 2026-08-26

- Save format v6.
- Restore BO1 coop scoreboard fields: kills, headshots, downs and revives.
- Keep networked scoreboard values and Zombies stat mirrors synchronized.
- Preserve hellhound scheduler state: enabled, active, count and `next_dog_round`.
- Rebuild an already-queued dog round through the stock dog-round functions.

## 0.5.0-beta.1 - 2026-08-26

- Save format v5.
- Add Kino power, permanent route, curtain and fully-linked teleporter world state.
- Add player stat mirrors.
- Keep GUID player matching, perks, weapons, ammo and points.

## 0.4.0-rc1 - 2026-08-26

- Save format v4.
- Add active perk persistence/restoration.

## 0.3.0-rc1 - 2026-08-26

- Save format v3.
- Strict `GetGuid()` player matching.
- One restore per player/slot.

## 0.2.x native test - 2026-08-26

- Remove external DLL dependency.
- Move persistence to archived native dvars.

## 0.1.0 - 2026-08-25

- Initial experimental save/resume implementation.
