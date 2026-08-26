# Troubleshooting

## Script does not execute

For Plutonium T5 r5346, the tested Zombies-only path is:

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

Do **not** keep a second copy directly under `scripts\sp`, because generic SP scripts can also be loaded by the frontend on this build.

Expected log lines when a Zombies map starts:

```text
Loading script scripts/sp/zom/zombie_resume.gsc...
Script scripts/sp/zom/zombie_resume.gsc loaded successfully.
```

## Game crashes at startup on `ddl/stats.ddl`

Check whether this file exists and is active:

```text
%localappdata%\Plutonium\plugins\t5-gsc-utils.dll
```

The current T5 Zombies Resume runtime does not need that DLL. On the r5346 test setup it was confirmed to trigger a startup failure before Kino loaded.

With Plutonium closed, rename it to:

```text
t5-gsc-utils.dll.disabled
```

## Save disappears after fully closing the game

Run the latest `install.ps1` with Plutonium completely closed.

The installer must add archived `seta zr_sv_*` entries to:

```text
%localappdata%\Plutonium\storage\t5\players\config.cfg
```

It also creates this one-time backup:

```text
config.cfg.t5zr.bak
```

After a new autosave, quit BO1/Plutonium normally and relaunch. In Kino run:

```text
set zr_status 1
```

The saved round should still be present.

## `Ensure-ArchivedDvar` rejects an empty string

Update to an installer containing:

```powershell
[AllowEmptyString()][string]$DefaultValue
```

This was fixed after the first persistence installer build.

## Resume says save format is not v3

`0.3.0-rc1` deliberately rejects v2 snapshots because they do not contain safe per-player GUID identity.

Create a new save with v3 by playing until the next autosave message:

```text
T5ZR: sauvegarde OK - prochaine manche X
```

Then resume again.

## Several players receive the same weapons/points

That was the unsafe v2/name-matching behavior.

Verify the loaded version is:

```text
T5ZR 0.3.0-rc1 actif
```

Format v3 stores `zr_sv_pN_guid` and only restores a player when native `GetGuid()` matches exactly. There is no name fallback. A saved slot can also be claimed only once.

If the issue still reproduces on v3, capture the new Plutonium log. Do not paste account GUID values publicly unless needed for debugging.

## A mate gets `aucune sauvegarde associee a ce joueur`

This is a safe failure mode in v3. It means the joining player's current GUID did not match any unclaimed saved slot.

Possible reasons:

- this player was not in the original save;
- the save was created with v2;
- the player is using a different Plutonium account;
- the slot was already claimed earlier in the resumed session.

The runtime intentionally leaves that player with the normal Zombies loadout rather than applying another player's snapshot.

## Player is restored again after death/respawn

`0.3.0-rc1` has a one-shot restore guard. If this happens, verify that the installed GSC is actually the latest version and that there are no duplicate `zombie_resume.gsc` copies.

## Autosave message never appears

The current runtime watches `level.round_number` directly rather than depending on a cross-script round notify.

Use:

```text
set zr_save_now 1
```

to isolate manual save behavior, and:

```text
set zr_status 1
```

to inspect the current/saved round.

## Resume flow

After relaunching the same map:

```text
set zr_status 1
set zr_resume 1
map_restart
```

The runtime should prepare the saved round, then each saved participant should receive exactly one GUID-matched restore.
