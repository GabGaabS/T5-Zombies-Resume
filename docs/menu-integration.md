# Optional private-lobby menu integration

T5ZR 0.6.0-beta.1 can add a **T5ZR - RESUME GAME** button to the BO1 private Zombies lobby.

## Why it is optional

T5 only allows this style of frontend integration through a raw UI override. Other BO1 UI mods may replace the same `xboxlive_privatelobby.menu` file, so T5ZR does not install it unless explicitly requested.

## Install

Close Plutonium completely:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -InstallMenu
```

The installer fetches a pinned version of the public Plutonium T5 lobby menu from `plutoniummod/client-raw-assets`, patches it locally and writes:

```text
%localappdata%\Plutonium\storage\t5\ui\xboxlive_privatelobby.menu
```

The full upstream menu file is not stored in the T5ZR repository.

## Existing custom menu

If a non-T5ZR override already exists, the installer creates:

```text
xboxlive_privatelobby.menu.t5zr.preexisting.bak
```

before installing the T5ZR-generated version.

## Remove / restore

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -RemoveMenu
```

If T5ZR created a backup, it is restored automatically.

## Button behavior

The button appears only when:

- the local client is the private-lobby host;
- `zr_sv_valid == 1`;
- `zr_sv_format == 6`;
- the saved map is one of the stock BO1 Zombies maps handled by the menu patch.

Selecting **T5ZR - RESUME GAME** sets `ui_mapname` to the saved map, sets `ui_gametype` to `zom`, sets `zr_resume=1` and launches `xpartygo`.

The regular Start Match action clears `zr_resume` first.

## Test checklist

1. Create or keep a valid v6 save.
2. Close Plutonium.
3. Run the installer with `-InstallMenu`.
4. Launch Zombies and enter a private match lobby as host.
5. Confirm **T5ZR - RESUME GAME** appears.
6. Select it without manually changing the map.
7. Confirm the saved map launches and the normal T5ZR restore message appears.
8. Return to the lobby and use normal **Start Match**; confirm it does not resume the save.

If the lobby fails to load, remove the override with `-RemoveMenu` and report the first UI/console error.

## Compatibility note

The generated patch is currently pinned to a known Plutonium `client-raw-assets` revision. If Plutonium changes the private-lobby menu structure, T5ZR should update the patch anchors instead of silently applying a partial modification.
