# Save format v6

T5 Zombies Resume stores one host-side round-boundary snapshot in archived `zr_sv_*` dvars. A save becomes valid only after all session, scheduler, world and player fields have been written.

## Session

```text
zr_sv_valid
zr_sv_format            # 6
zr_sv_mod_version
zr_sv_map
zr_sv_round             # next round to play
zr_sv_reason
zr_sv_player_count
zr_sv_world_adapter
```

## Hellhound scheduler

When the map uses stock dog rounds:

```text
zr_sv_dog_rounds_enabled
zr_sv_dog_round_active
zr_sv_dog_round_count
zr_sv_next_dog_round
```

BO1 normally chooses `next_dog_round` near game start and only switches the spawn function when `level.round_number == level.next_dog_round`. Jumping directly to a saved round without restoring this state causes the scheduler to be left behind.

If `dog_round_active == 1`, the saved round itself had already been queued as a dog round at the autosave boundary. Resume rebuilds the stock `dog_round` flag and uses `maps\_zombiemode_ai_dogs::dog_round_spawning` for that round.

## Player identity

Up to four slots are stored. `GetGuid()` is authoritative; the saved name is metadata only.

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

BO1 keeps both networked player fields used by the coop scoreboard and script-side stat mirrors. v6 restores both:

- `player.kills`;
- `player.headshots`;
- `player.downs`;
- `player.revives`;
- `player.kill_tracker`;
- matching `player.stats[...]` entries.

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

Perks are restored through the stock Zombies path:

```text
self maps\_zombiemode_perks::give_perk(perk, false)
```

They are restored before weapons so Mule Kick can precede a third primary.

## Kino world adapter

When `zr_sv_world_adapter == "kino_v1"`:

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

Matching `zombie_door` / `zombie_debris` entities and their stock route flags are reconstructed together.

## Persistence

`install.ps1` registers the keys with `seta` in:

```text
%localappdata%\Plutonium\storage\t5\players\config.cfg
```

The first installer run creates `config.cfg.t5zr.bak`.

## Validation

Resume is rejected when the save is invalid, the format is not v6, the map differs or the saved round is invalid.

## Deliberately not stored

- Mystery Box location/history;
- active teleporter cooldown;
- active traps/powerups;
- living zombies / mid-round positions;
- Easter Egg / sidequest progress;
- RNG state;
- unsupported map-specific world state.
