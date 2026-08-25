# Troubleshooting

## Script does not execute

The common community path for T5 Zombies scripts is:

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom
```

If your current Plutonium T5 build does not execute scripts from that path, some recent community setups use:

```text
%localappdata%\Plutonium\storage\t5\raw\scripts\sp
```

Move only `zombie_resume.gsc` while testing; do not duplicate it in both paths at once.

## Unknown function: json::dump / command::add / readFile

`t5-gsc-utils` is missing, outdated, or not loaded. Install the current `t5-gsc-utils.dll` into:

```text
%localappdata%\Plutonium\plugins\
```

Then restart Plutonium.

## Include errors

The runtime script intentionally avoids `#include` directives for stock BO1 GSC. Current T5 community reports show that custom scripts can have trouble including base-game raw GSC depending on loader path/build. Stock helpers are resolved dynamically where needed.

## Round starts at the wrong value

Capture the exact console lines around:

```text
[T5ZR] Prepared resume at round ...
```

This means the remaining issue is startup timing relative to BO1's stock `round_start()`, not save parsing. Do not add perks/world state until this timing is confirmed.

## Points restore but HUD is stale

The mod dynamically resolves stock `maps/_zombiemode_score::set_player_score_hud`. If that function lookup differs on a future build, gameplay points can still be correct while the HUD waits for the next normal score update. Capture the console output and adjust the stock function resolution.
