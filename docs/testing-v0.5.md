# v0.5.0-beta.1 validation checklist

Use this checklist before promoting the beta to a stable release.

## Clean install

1. Close BO1 and Plutonium completely.
2. Run `install.ps1`.
3. Confirm the installer reports `0.5.0-beta.1 / save format v5`.
4. Launch Kino der Toten.
5. Confirm the GSC compiles and the console reports the v0.5.0-beta.1 load message.

## Build a recognizable save

Use a short private session. Two players are preferred.

Before ending the test round:

- give each player clearly different points;
- use different primary weapons/ammo;
- buy different perks;
- record kills/headshots/downs/revives where practical;
- open at least one clearly identifiable permanent door/debris route;
- turn on power;
- optionally fully link the teleporter.

Advance the round and wait for:

```text
T5ZR: sauvegarde OK - prochaine manche X
```

Then run:

```text
set zr_status 1
```

The console should show `format=5` and `world=kino_v1`.

## Full process restart

1. Quit the Zombies session normally.
2. Close BO1/Plutonium completely.
3. Relaunch Plutonium.
4. Start Kino normally.
5. Run `set zr_status 1` and confirm the same saved round is still present.
6. Run:

```text
set zr_resume 1
map_restart
```

## Verify after resume

For every saved player:

- correct GUID receives the correct snapshot;
- points are correct;
- weapons and clip/reserve ammo are correct;
- selected weapon is reasonable;
- perks and their gameplay effects are active;
- kills/headshots/downs/revives match the saved values.

For Kino:

- power remains on if it was on;
- the tested opened route is physically open;
- zombie path/zone behavior agrees with the open route;
- stage curtains remain in the completed state when applicable;
- a fully-linked teleporter remains linked when that state was saved.

## Regression checks

- A player not present in the save must not receive another player's state.
- The same saved slot must not be applied twice.
- Dying/respawning later must not reapply the original resume snapshot.
- A v4 save must be rejected instead of partially interpreted as v5.
- `set zr_clear_save 1` should invalidate the save.

## Known non-goals for this test

Do not file these as v0.5 regressions unless the README says otherwise:

- Mystery Box position/history resets;
- teleporter cooldown resets;
- temporary powerups/traps reset;
- living zombies are not reconstructed;
- Easter Egg progress resets;
- world state on maps other than Kino resets.

## If something fails

Save the smallest useful console excerpt around `[T5ZR]` and the first related error. Record which route/door was tested and whether its visual state or zombie pathing was wrong.

Redact GUIDs, IPs, tokens and personal filesystem information before publishing a report.
