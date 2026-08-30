# Save format v8

T5 Zombies Resume writes one host-side **round-boundary** snapshot in archived `zr_sv_*` dvars. A save becomes valid only after session, scheduler, world and player fields have been written.

The current runtime reads and writes **v8 only**. Legacy v5/v6/v7 readers were removed in 0.8.0-beta.19.

## Session

```text
zr_sv_valid
zr_sv_format            # 8
zr_sv_mod_version
zr_sv_map
zr_sv_round             # next round to play
zr_sv_reason
zr_sv_player_count
zr_sv_world_adapter
zr_sv_total_time_seconds
```

## Hellhound scheduler

```text
zr_sv_dog_rounds_enabled
zr_sv_dog_round_active
zr_sv_dog_round_count
zr_sv_next_dog_round
```

The scheduler is restored instead of letting BO1 choose a fresh special-round cycle after resume.

## Player identity

Up to four persistent slots are stored. Engine `GetGuid()` is authoritative; the saved name is metadata only.

```text
zr_sv_p0_guid
zr_sv_p0_name
```

There is no name fallback and an absent player keeps their slot.

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

Restore updates both the coop scoreboard fields and the internal Zombies stat mirrors.

## Primary weapons

```text
zr_sv_p0_current_weapon
zr_sv_p0_weapon_count
zr_sv_p0_w0_name
zr_sv_p0_w0_clip
zr_sv_p0_w0_stock
zr_sv_p0_w0_pap_level
...
zr_sv_p0_w2_name
zr_sv_p0_w2_clip
zr_sv_p0_w2_stock
zr_sv_p0_w2_pap_level
```

Up to three primaries are stored. `current_weapon` is normalized to a saved primary so an offhand/temporary weapon cannot become the resume selection accidentally.

For supported PAP 2+ weapons, `clip` and `stock` are **effective ammunition** values. They include virtual-magazine and virtual-reserve overflow that T5 cannot represent directly in the weapon asset.

## Perks

```text
zr_sv_p0_perk_count
zr_sv_p0_perk0
...
zr_sv_p0_perk15
```

Perks are rebuilt through the stock Zombies perk path before primaries are restored, so Mule Kick can precede a third weapon.

## Melee and tactical state

```text
zr_sv_p0_melee_weapon
zr_sv_p0_tactical_weapon
zr_sv_p0_tactical_clip
zr_sv_p0_tactical_stock
```

These preserve state such as `bowie_knife_zm` and `zombie_cymbal_monkey`.

## Multi-PAP state

Each primary stores `pap_level`:

- `0`: non-PAP / no T5ZR PAP state;
- `1`: stock BO1 Pack-a-Punch;
- `2+`: T5ZR extra PAP levels.

Restored values are clamped to the current runtime maximum before virtual ammo/damage state is rebuilt.

## Kino world adapter

When `zr_sv_world_adapter == "kino_v1"`, T5ZR restores the stable Kino state it currently models:

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

## Transaction behavior

A save starts by writing `zr_sv_valid=0`. Only after all current state has been written does T5ZR set `zr_sv_valid=1` again. A partially written snapshot is therefore rejected on resume.

## Resume validation

Resume is rejected when:

- `zr_sv_valid != 1`;
- `zr_sv_format != 8`;
- saved map and current map differ;
- saved round is invalid.

Old v5/v6/v7 snapshots are left untouched but are no longer loaded.

## Deliberately not stored

- Mystery Box location/history;
- active teleporter cooldown;
- active traps/powerups;
- living zombies / mid-round positions;
- Easter Egg / sidequest progress;
- RNG state;
- unsupported map-specific world state.
