# Changelog

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
