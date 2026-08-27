# Save format v7

T5 Zombies Resume writes one host-side round-boundary snapshot in archived `zr_sv_*` dvars. A save becomes valid only after all session, scheduler, world and player fields have been written.

The current runtime writes **v7** and can read **v5, v6 and v7**.

## Compatibility matrix

| Field group | v5 | v6 | v7 |
| --- | --- | --- | --- |
| Round / map / player GUIDs | yes | yes | yes |
| Points / stats / primaries / ammo | yes | yes | yes |
| Perks | yes | yes | yes |
| Kino world adapter | yes | yes | yes |
| Hellhound scheduler | no | yes | yes |
| Persistent total run time | no | no | yes |
| Melee / tactical state (Bowie, monkeys) | no | no | yes |

A legacy save is never modified merely by loading it. The **next successful autosave** writes all currently available state as v7.

For safety, the reader is format-gated. A v5 restore never consumes archived v6/v7-only values that may be left in `config.cfg` from another snapshot.

## Session

```text
zr_sv_valid
zr_sv_format            # current writer: 7
zr_sv_mod_version
zr_sv_map
zr_sv_round             # next round to play
zr_sv_reason
zr_sv_player_count
zr_sv_world_adapter
zr_sv_total_time_seconds    # v7+
```

## Hellhound scheduler (v6+)

```text
zr_sv_dog_rounds_enabled
zr_sv_dog_round_active
zr_sv_dog_round_count
zr_sv_next_dog_round
```

A v5 resume intentionally leaves this on stock BO1 behavior because the v5 snapshot never contained scheduler state.

## Player identity

Up to four slots are stored. Engine `GetGuid()` is authoritative; the saved name is metadata only.

```text
zr_sv_p0_guid
zr_sv_p0_name
```

There is no name fallback.

## Points and scoreboard

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

v5 already stored the script-side round stat values. Current releases rebuild both the stat mirrors and the coop scoreboard fields from those saved values.

## Primary weapons

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

Up to three primaries are stored.

## Perks

```text
zr_sv_p0_perk_count
zr_sv_p0_perk0
...
zr_sv_p0_perk15
```

Perks are rebuilt through the stock Zombies perk path before primaries are restored, so Mule Kick can precede a third weapon.

## Melee and tactical state (v7+)

```text
zr_sv_p0_melee_weapon
zr_sv_p0_tactical_weapon
zr_sv_p0_tactical_clip
zr_sv_p0_tactical_stock
```

These fields preserve state such as `bowie_knife_zm` and `zombie_cymbal_monkey`.

They are deliberately ignored for v5/v6 restores.

## Kino world adapter (v5+)

When `zr_sv_world_adapter == "kino_v1"`, the runtime can restore the stable Kino state introduced by v5:

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

## Persistence

`install.ps1` registers the keys with `seta` in:

```text
%localappdata%\Plutonium\storage\t5\players\config.cfg
```

The first installer run creates `config.cfg.t5zr.bak`.

## Resume validation

Resume is rejected when:

- `zr_sv_valid != 1`;
- the format is not v5, v6 or v7;
- saved map and current map differ;
- saved round is invalid.

## Deliberately not stored

- Mystery Box location/history;
- active teleporter cooldown;
- active traps/powerups;
- living zombies / mid-round positions;
- Easter Egg / sidequest progress;
- RNG state;
- unsupported map-specific world state.
