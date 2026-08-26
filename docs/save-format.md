# Save format v5

T5 Zombies Resume keeps one host-side round-boundary snapshot in archived `zr_sv_*` dvars.

A save is marked valid only after all session, world and player fields have been written.

## Session

```text
zr_sv_valid
zr_sv_format            # 5
zr_sv_mod_version
zr_sv_map
zr_sv_round             # next round to play
zr_sv_reason
zr_sv_player_count
zr_sv_world_adapter
```

## Player identity

Up to four slots are stored. `GetGuid()` is authoritative; the saved name is only metadata.

```text
zr_sv_p0_guid
zr_sv_p0_name
```

There is no name fallback. A live player without an exact GUID match is left in the normal stock spawn state.

Each saved slot can be claimed once per resumed session and each live player entity is restored at most once.

## Points and round stats

```text
zr_sv_p0_score
zr_sv_p0_score_total
zr_sv_p0_kills
zr_sv_p0_kill_tracker
zr_sv_p0_headshots
zr_sv_p0_downs
zr_sv_p0_revives
zr_sv_p0_zombie_gibs
zr_sv_p0_perks_stat
```

The runtime restores both the round `stats[...]` values used by BO1 and the kill tracker used by the scoring path.

## Weapons

```text
zr_sv_p0_current_weapon
zr_sv_p0_weapon_count

zr_sv_p0_w0_name
zr_sv_p0_w0_clip
zr_sv_p0_w0_stock
...
zr_sv_p0_w2_name
zr_sv_p0_w2_clip
zr_sv_p0_w2_stock
```

Up to three primary weapons are stored.

## Perks

```text
zr_sv_p0_perk_count
zr_sv_p0_perk0
...
zr_sv_p0_perk15
```

The runtime recognizes the eight standard BO1 Zombies perk identifiers and their stock `_upgrade` variants.

Perks are restored through:

```text
self maps\_zombiemode_perks::give_perk(perk, false)
```

This rebuilds the stock perk lifecycle and side effects instead of only setting a perk bit. Perks are restored before primary weapons so Mule Kick can precede a third gun.

## Kino world adapter

When `zr_sv_world_adapter == "kino_v1"`, v5 also stores stable Kino der Toten world state:

```text
zr_sv_kino_power
zr_sv_kino_magic_box_foyer1
zr_sv_kino_magic_box_crematorium1
zr_sv_kino_vip_to_dining
zr_sv_kino_magic_box_alleyway1
zr_sv_kino_dining_to_dressing
zr_sv_kino_magic_box_dressing1
zr_sv_kino_magic_box_west_balcony2
zr_sv_kino_magic_box_west_balcony1
zr_sv_kino_curtains_done
zr_sv_kino_teleporter_linked
```

The route names come from Kino's stock `theater_zone_init()` adjacency flags.

On resume, matching `zombie_door` and `zombie_debris` entities are opened/removed and the same stock route flags are set, so visual blockers and zombie zone connectivity stay aligned.

Power is restored by setting the stock `power_on` flag after disabling the fresh power-switch trigger. Kino's own `wait_for_power()` thread handles the switch/power side effects.

Only a **fully linked** teleporter is persisted. A half-finished core/pad link and any cooldown timer reset normally.

## Persistence

`install.ps1` pre-registers save keys with `seta` in:

```text
%localappdata%\Plutonium\storage\t5\players\config.cfg
```

The first installer run also creates:

```text
config.cfg.t5zr.bak
```

## Validation

Resume is rejected when:

- `zr_sv_valid != 1`;
- the save format is not v5;
- saved map and current map differ;
- the saved round is invalid.

A missing/unmatched player does not abort the session.

## Deliberately not stored

Format v5 is still a stable-boundary reconstruction, not a full engine snapshot. It does not store:

- Mystery Box location/history;
- active teleporter cooldown or in-progress teleport;
- active traps or temporary powerups;
- living zombies or their positions;
- Easter Egg / sidequest progress;
- RNG state;
- map-specific world state outside the implemented Kino adapter.
