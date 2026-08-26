# Save format v4

T5 Zombies Resume stores one host-side snapshot in archived `zr_sv_*` dvars.

The snapshot is written only at a stable round boundary (or manually) and is considered valid only after every field has been updated.

## Session fields

```text
zr_sv_valid
zr_sv_format
zr_sv_mod_version
zr_sv_map
zr_sv_round
zr_sv_reason
zr_sv_player_count
```

`zr_sv_format` must be `4` for `0.4.x` resume.

`zr_sv_round` is the next round to play after loading.

## Player identity

Each of up to four slots stores:

```text
zr_sv_p0_guid
zr_sv_p0_name
```

`guid` is authoritative. `name` is display/debug metadata only.

A player is restored only when the live `GetGuid()` value exactly matches a saved slot. There is no name fallback.

Each slot can be claimed only once in a resumed session and each live player entity can be restored at most once.

## Score and weapons

Per player:

```text
zr_sv_p0_score
zr_sv_p0_score_total
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

Per player:

```text
zr_sv_p0_perk_count
zr_sv_p0_perk0
...
zr_sv_p0_perk15
```

The runtime recognizes these stock BO1 identifiers:

```text
specialty_armorvest
specialty_quickrevive
specialty_fastreload
specialty_rof
specialty_longersprint
specialty_flakjacket
specialty_deadshot
specialty_additionalprimaryweapon
```

and the corresponding `_upgrade` variants defined in the stock perk script.

Perks are restored before weapons. This matters for `specialty_additionalprimaryweapon` (Mule Kick) when a saved player owns three primaries.

Restoration uses the stock Zombies call:

```text
self maps\_zombiemode_perks::give_perk(perk, false)
```

rather than only calling `SetPerk`. The stock path is responsible for the perk HUD/lifecycle and perk-specific effects such as Jugger-Nog max health and Deadshot's client flag.

## Persistence

`install.ps1` pre-registers every save key with `seta` in:

```text
%localappdata%\Plutonium\storage\t5\players\config.cfg
```

so the custom dvars have the archive flag and survive a normal full BO1/Plutonium exit.

The installer creates an initial backup at:

```text
config.cfg.t5zr.bak
```

## Validation rules

Resume is rejected when:

- `zr_sv_valid != 1`;
- format is not v4;
- saved map differs from the loaded map;
- saved round is invalid;
- a player has no matching GUID slot.

A missing player does not block the whole session: unmatched players keep their normal stock spawn state.

## Not part of format v4

The following are map/world state and are intentionally not yet reconstructed:

- power/courant;
- opened doors/debris;
- Mystery Box position/history;
- Pack-a-Punch/téléporter state;
- traps;
- Easter Egg / sidequest flags;
- live zombies and mid-round AI;
- RNG state;
- special history such as prior Quick Revive solo purchases or permanent-perk quest flags.

Those systems need explicit map adapters instead of being treated as generic player fields.
