# Save format v3

`0.3.0-rc1` stores the resume snapshot in archived T5 dvars rather than JSON.

The installer pre-registers every `zr_sv_*` key with `seta` in:

```text
%localappdata%\Plutonium\storage\t5\players\config.cfg
```

The runtime updates those values with native GSC calls. On a normal BO1/Plutonium exit, the archived values remain available for the next launch.

## Metadata

```text
zr_sv_valid
zr_sv_format
zr_sv_mod_version
zr_sv_map
zr_sv_round
zr_sv_reason
zr_sv_player_count
```

Expected format value:

```text
zr_sv_format = 3
```

`zr_sv_round` is the next round to play after resume.

The runtime writes `zr_sv_valid = 0` before updating a snapshot and only sets it back to `1` after every field has been written.

## Per-player slots

Up to four players are stored as `p0` through `p3`.

For each player:

```text
zr_sv_p0_guid
zr_sv_p0_name
zr_sv_p0_score
zr_sv_p0_score_total
zr_sv_p0_current_weapon
zr_sv_p0_weapon_count
```

`guid` is the authoritative identity key. `name` is metadata only and is never used as a restore fallback in v3.

For each of up to three primary weapons:

```text
zr_sv_p0_w0_name
zr_sv_p0_w0_clip
zr_sv_p0_w0_stock
```

The same layout exists for `w1` and `w2`, and for player slots `p1` through `p3`.

## Restore matching rules

A player can be restored only when all of these are true:

1. `zr_sv_valid == 1`;
2. `zr_sv_format == 3`;
3. saved map equals current map;
4. saved round is valid;
5. current `player GetGuid()` exactly equals one saved slot GUID;
6. that slot has not already been claimed in the current resumed session;
7. that player entity has not already attempted restore.

There is intentionally **no player-name fallback**.

If no GUID matches, the runtime leaves that player's stock Zombies state untouched. This is safer than applying another participant's points/weapons.

## Compatibility

Format v2 saves are rejected by v3. Create a new autosave with `0.3.0-rc1` before testing resume.

## Not represented yet

Format v3 does not store perks, doors, power, box state, traps, teleporters, Pack-a-Punch world state, Easter Egg progress, active zombies, exact player positions, RNG state, or a mid-round simulation snapshot.
