# Optional private-lobby menu integration

T5ZR can add a **T5ZR - RESUME GAME** button to the BO1 private Zombies lobby.

## Why it is optional

Current Plutonium T5 loads this override through a mod. Other UI mods may replace the same `xboxlive_privatelobby.menu`, so T5ZR does not install the menu unless explicitly requested.

## Install

Close Plutonium completely:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -InstallMenu
```

The installer fetches a pinned public Plutonium lobby menu, patches it locally and creates:

```text
%localappdata%\Plutonium\storage\t5\mods\t5zr_resume_menu\
    description.txt
    ui\mod.txt
    ui\xboxlive_privatelobby.menu
```

The full upstream menu file is not stored in the T5ZR repository.

After installation, launch Black Ops, open **MODS**, load **t5zr_resume_menu**, then enter Zombies/private lobby.

## Remove

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -RemoveMenu
```

The runtime GSC and save data remain installed.

The installer also cleans up the obsolete pre-r5340 loose T5ZR menu if one is still present. It does not delete an unrelated custom override.

## Button behavior

The resume action requires:

- private-lobby host;
- `zr_sv_valid == 1`;
- `zr_sv_format == 8`;
- a saved stock BO1 Zombies map handled by the menu patch.

Selecting **T5ZR - RESUME GAME** sets the saved `ui_mapname`, sets `ui_gametype` to `zom`, sets `zr_resume=1` and launches `xpartygo`.

Normal **Start Match** clears `zr_resume` first.

The button itself remains visible to the host when the menu mod is loaded; the action is gated by the conditions above.

## Test checklist

1. Create a valid current v8 save.
2. Close Plutonium.
3. Run `install.ps1 -InstallMenu`.
4. Launch Black Ops and load **t5zr_resume_menu** from MODS.
5. Enter a private Zombies lobby as host.
6. Confirm **T5ZR - RESUME GAME** appears.
7. Select it and confirm the saved map launches.
8. Look for `[T5ZR] Prepared v8 resume at round ...`.
9. Return to the lobby and use normal **Start Match**; confirm it does not resume the save.

If the lobby fails to load, remove the mod with `-RemoveMenu` and report the first UI/console error.

## Compatibility note

The generated patch is pinned to a known Plutonium `client-raw-assets` revision. If Plutonium changes the private-lobby menu structure, T5ZR should update its patch anchors instead of silently applying a partial modification.
