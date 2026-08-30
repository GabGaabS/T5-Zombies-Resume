# T5 Zombies Resume

Host-only save/resume for **Call of Duty: Black Ops Zombies** on **Plutonium T5**.

![Version](https://img.shields.io/badge/version-0.8.0--beta.19-blue)
![Status](https://img.shields.io/badge/status-public%20beta-yellow)
![Platform](https://img.shields.io/badge/platform-Plutonium%20T5-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

T5ZR lets the host stop a private Zombies session at a round boundary, close the game, and continue later with the same players and loadouts.

## Current status

`0.8.0-beta.19` hardens the current v8 runtime after r5346 in-game validation: legacy v5/v6/v7 readers and old tuning/HUD migrations are removed, one-shot console triggers are reset safely on map load, PAP runtime state is clamped, and the optional menu mod now includes the missing `description.txt`. The validated stock-small HUD and virtual PAP reserve remain unchanged.

The save layer already covers:

- round;
- points and total score;
- weapons and clip/reserve ammo;
- selected weapon;
- Bowie/melee state and tactical grenades (including cymbal monkeys);
- perks;
- persistent total run time;
- small corner HUD with round time, total time and zombies remaining;
- multi-level Pack-a-Punch for supported upgraded firearms and selected Wonder Weapons;
- coop scoreboard kills/headshots/downs/revives;
- strict per-player matching through `GetGuid()`;
- persistent 4-slot coop roster: absent players keep their last saved state; new players only take free slots;
- hellhound scheduler state;
- Kino power and permanent opened routes;
- Kino stage curtain and fully-linked teleporter state.

## Installation from scratch

### 1. Install Call of Duty: Black Ops

T5ZR runs on **Plutonium T5**, which uses the original **Call of Duty: Black Ops** game files. Plutonium does not replace those files, so install Black Ops first from Steam or another legitimate source.

A common Steam location is:

```text
C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops
```

Your Steam library can be on another drive, so the exact path may differ.

### 2. Download and install Plutonium

Use the official Plutonium resources only:

- official French installation guide: https://plutonium.pw/fr/docs/install/
- official launcher download: https://cdn.plutonium.pw/updater/plutonium.exe
- Plutonium home/docs: https://plutonium.pw/docs/

Then:

1. download `plutonium.exe`;
2. save it somewhere convenient and launch it;
3. sign in with your Plutonium/forum account;
4. open the **Black Ops** tab;
5. click **SETUP**;
6. select the folder that contains your **Call of Duty: Black Ops** game files;
7. click **PLAY** once to make sure Plutonium T5 starts correctly.

If Plutonium reports an invalid game path, do not select an entire drive such as `C:\`. Select the actual `Call of Duty Black Ops` folder. You can change it later with **Game Settings** next to the PLAY button.

> T5ZR is intended for private Plutonium T5 Zombies sessions. No external DLL, injector or memory patch is required.

### 3. Download T5 Zombies Resume

Repository:

https://github.com/GabGaabS/T5-Zombies-Resume

#### Option A — with Git

Open PowerShell in the folder where you want the project, then run:

```powershell
git clone https://github.com/GabGaabS/T5-Zombies-Resume.git
cd T5-Zombies-Resume
```

If you already cloned the project, update it instead:

```powershell
git pull
```

#### Option B — without Git

1. open the GitHub repository;
2. click **Code**;
3. click **Download ZIP**;
4. extract the ZIP;
5. open PowerShell inside the extracted `T5-Zombies-Resume` folder.

### 4. Install T5ZR

**Close Plutonium completely** before installing or updating T5ZR.

From the repository folder, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

This installs the GSC runtime to the Plutonium T5 storage directory. It does **not** install any external DLL.

Expected runtime path:

```text
%LOCALAPPDATA%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

After installation, start Plutonium, open **Black Ops → Zombies**, create a private lobby and launch a match. The console should contain a line similar to:

```text
[T5ZR] T5 Zombies Resume v0.8.0-beta.19 loaded
```

### Optional Resume Game button

To add **T5ZR - RESUME GAME** to the private Zombies lobby:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -InstallMenu
```

Current Plutonium T5 loads custom `.menu` overrides through a loaded **mod** using `ui/mod.txt`. The installer therefore creates:

```text
%LOCALAPPDATA%\Plutonium\storage\t5\mods\t5zr_resume_menu\
```

After installation:

1. start Plutonium T5;
2. from the Black Ops main menu open **MODS**;
3. select and load **t5zr_resume_menu**;
4. enter Zombies and create/open the private lobby;
5. as host, **T5ZR - RESUME GAME** should be visible.

The button is deliberately visible to the private-lobby host whenever the menu mod is loaded. Clicking it only starts a resume when the archived T5ZR save is valid and supported. This makes it easy to distinguish a menu-loading problem from a save-validation problem.

The installer downloads the pinned public `xboxlive_privatelobby.menu` asset from Plutonium, applies the small T5ZR patch locally, and creates a `ui/mod.txt` MenuList. T5ZR does **not** redistribute Plutonium's full menu asset in this repository.

Remove the T5ZR menu mod with:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -RemoveMenu
```

The GSC/save runtime remains installed.

## Weapon restore verification

On resume, T5ZR now keeps BO1 Zombies' weapon ownership bookkeeping synchronized when rebuilding saved primaries. After the spawn/loadout threads settle, it removes stray starter primaries, re-applies every saved primary if needed, restores exact clip/reserve ammo and re-selects the saved current weapon.

The console prints:

```text
[T5ZR] Restore inventory verified: expected=N actual=N.
```

For a normal two-weapon loadout, the expected successful result is `expected=2 actual=2`. With Mule Kick and three saved primaries, it should be `3/3`.

## Persistent coop roster

T5ZR keeps up to four persistent player slots, keyed by engine `GetGuid()`.

On a resumed campaign:

- a player whose GUID already exists updates only their own slot;
- a saved player who is absent is **not deleted** and keeps their last saved weapons, ammo, perks, stats, Bowie/monkeys and multi-PAP levels;
- a new player is added to the next free slot at the next successful autosave;
- if all four saved slots are already occupied, an unmatched player is treated as a **guest** and never replaces an existing saved player;
- when an absent saved player returns in a later resumed session, their GUID matches the old slot and their last saved state is restored.

A normal fresh **Start Match** starts a new campaign roster on its first save, so an old campaign is not silently merged into a brand-new run.

## Using the menu

After loading the **t5zr_resume_menu** mod, the private-lobby host should see:

```text
T5ZR - RESUME GAME
```

Selecting it:

- chooses the saved map;
- sets the Zombies gametype;
- arms `zr_resume`;
- starts the match.

A normal **Start Match** explicitly clears `zr_resume`, so it starts a fresh game.

The console fallback still works:

```text
set zr_status 1
set zr_resume 1
map_restart
```

## HUD

The HUD uses the original corner layout:

- top-left: `Manche: M:SS`;
- top-right: `Total: M:SS` (or `H:MM:SS` after one hour);
- bottom-right: `Zombies: N`.

The HUD now uses direct `NewClientHudElem` elements with T5's stock `small` font. This avoids the SP/MP `createFontString()` calling-convention mismatch and the giant fractional-scale rendering seen during r5346 testing. One cohesive text element is used per corner, and live values are updated through Plutonium `SetTextUnlimited()` to stay configstring-safe.

HUD size is configurable with an archived percentage:

```text
set zr_hud_scale_pct 100
```

The default is 100, meaning T5 engine font scale 1.0 with the stock `small` font. To make it smaller, for example:

```text
set zr_hud_scale_pct 75
map_restart
```

The runtime clamps the percentage to 50-200 for this HUD path.

Console toggles:

```text
set zr_hud 0
set zr_hud 1
set zr_hud_round_time 0/1
set zr_hud_total_time 0/1
set zr_hud_zombies 0/1
```

Autosave confirmation is shown in a very small line just below the top HUD bar.

The live HUD is configstring-safe through Plutonium `SetTextUnlimited()`, so changing timers and zombie counts do not consume the finite configstring table. This fixes the `G_FindConfigstringIndex: overflow` crash seen on longer runs.

## Multi-level Pack-a-Punch

BO1's normal Pack-a-Punch remains unchanged and is **PAP level 1**. Once a supported weapon is already upgraded, using the same Pack-a-Punch machine again applies T5ZR levels 2+.

Default tuning:

| Level | Extra cost | Damage vs PAP 1 | Effective clip | Reserve |
| --- | ---: | ---: | ---: | ---: |
| PAP 1 | stock 5000 | base | base | base |
| PAP 2 | 7500 | +60% | +45% | +60% |
| PAP 3 | 10000 | +120% | +90% | +120% |
| PAP 4 | 12500 | +180% | +135% | +180% |
| PAP 5 | 15000 | +240% | +180% | +240% |
| PAP 6 | 17500 | +300% | +225% | +300% |
| PAP 7 | 20000 | +360% | +270% | +360% |
| PAP 8 | 22500 | +420% | +315% | +420% |

## Repair commands

These commands are intended for the private-lobby host to repair an existing v8 save after bugs from older beta versions.

First inspect connected players and all current primary weapons:

```text
set zr_pap_status 1
```

The console prints each connected player's command index, weapon name, PAP level, native clip, effective clip and reserve.

Choose the player to modify (host is normally index 0):

```text
set zr_cmd_player 0
```

To correct the **currently held Pack-a-Punched weapon** to a specific T5ZR PAP level:

```text
set zr_pap_level 2
set zr_pap_set_level 1
```

The level is clamped between 1 and `zr_pap_max_level`. T5ZR also updates the matching archived weapon slot immediately when it can find that player's GUID/weapon in the current save, so the correction survives even before the next autosave.

To refund/add points:

```text
set zr_points_amount 7500
set zr_give_points 1
```

This uses BO1 Zombies' stock `add_to_player_score` path, updates the HUD/score total, and immediately updates the matching archived player's saved score when available. The command only accepts positive amounts and caps one grant at 1,000,000 points.

### Per-weapon PAP progression

Multi-PAP progression is tracked independently for each weapon held by each player. Upgrading a Ray Gun to PAP 4 does **not** make a newly PAP-1 Galil cost the PAP-5 price.

Example:

```text
Ray Gun PAP 4 -> next Ray Gun upgrade: PAP 5 price
Galil PAP 1   -> next Galil upgrade: PAP 2 price (7500 by default)
```

The runtime uses a parallel per-player weapon registry rather than indexing GSC arrays directly by weapon-name strings. The same registry isolates both virtual-magazine and virtual-reserve state per weapon.

### Virtual magazine and reserve

T5 clamps both the native clip and native reserve to the weapon asset's limits. T5ZR therefore keeps two extra per-weapon counters for PAP 2+:

- virtual magazine rounds, representing the part of the enlarged magazine that cannot fit in the native clip;
- virtual reserve rounds, representing reserve ammo above the native engine cap.

Virtual magazine rounds are charged from the effective reserve when the magazine is loaded/reloaded, then fired without subtracting reserve a second time. When the native reserve reaches zero, T5ZR progressively exposes hidden virtual reserve back to the engine so reloads can continue normally.

For PAP 2+ weapons, autosaves store the **effective** clip and reserve in the existing v8 weapon fields. Older v8 saves remain readable because their values simply stay within native limits.

For diagnostics, every PAP interaction prints:

```text
[T5ZR] Multi-PAP quote ... weapon=<name> current_level=<n> next_level=<n> cost=<points>
```

The default maximum is **PAP 8**. The runtime still supports up to **PAP 10**:

```text
set zr_pap_max_level 10
```

With the default cost curve, PAP 9 costs 25,000 points and PAP 10 costs 27,500 points. Their cumulative default bonuses are +480%/+360%/+480% and +540%/+405%/+540% respectively.

The percentages are additive relative to the stock PAP weapon. Settings are archived and configurable:

```text
set zr_pap_multi 0/1
set zr_pap_special 0/1
set zr_pap_max_level 8
set zr_pap_cost_base 7500
set zr_pap_cost_step 2500
set zr_pap_damage_percent 60
set zr_pap_clip_percent 45
set zr_pap_stock_percent 60
```

### Wonder Weapon profiles

Selected special weapons now use a guarded profile instead of blindly applying the normal firearm logic:

| Weapon | Multi-PAP | Extra damage | Clip/reserve | Native special effect |
| --- | --- | --- | --- | --- |
| Ray Gun | yes | yes | yes | unchanged |
| Winter's Howl / freezegun | yes | yes | yes | freeze logic preserved |
| Thunder Gun | yes | no — close-range fling is already scripted lethal | yes | unchanged |
| Wunderwaffe / Tesla Gun | yes | no — chain kills are script-driven | yes | unchanged |

For low-capacity Wonder Weapons, T5ZR guarantees at least **+1 effective clip round per extra PAP level** when the configured percentage would otherwise round back down to the native clip size.

Ray Gun bonus damage is applied only to its normal projectile/explosion damage path. Winter's Howl gets additional raw health damage and its cumulative freeze-damage tracker is increased by the same bonus, while the stock freeze/shatter behavior still runs normally.

Thunder Gun and Wunderwaffe deliberately receive **ammo improvements only**: their signature kill effects use bespoke scripts that already bypass ordinary weapon damage, so multiplying a normal damage number would either do nothing or risk duplicate behavior.

Still excluded for now: Shrink Ray, Wave/Microwave Gun, explosive crossbow, launchers, ballistic knife and Mustang & Sally. Those need separate policies before they are safe to enable.

BO1/T5 clamps both the visible clip and native reserve to weapon-asset limits. T5ZR therefore keeps a **virtual magazine** and **virtual reserve** per weapon. Virtual magazine rounds are charged from the effective reserve when a magazine is loaded/reloaded, then firing them does **not** subtract reserve a second time. When the native reserve reaches zero, hidden virtual reserve is progressively exposed back to the engine so normal reloads continue. The stock ammo HUD still cannot display values above the weapon asset's native limits.

The damage bonus is real additional health damage. T5ZR's Zombies damage callback calculates the configured percentage and applies a guarded extra `DoDamage()` call; the nested callback is suppressed only to avoid duplicate scoring/effects, not to cancel the engine damage.

## Save format

The current runtime writes and reads **save format v8 only**.

Formats v5, v6 and v7 are intentionally no longer accepted. This removes stale format-gating branches from the runtime and keeps restore logic aligned with the state actually validated in current builds: total run time, offhand state, persistent roster and per-weapon multi-PAP levels.

If an old save is still present, T5ZR refuses to resume it without mutating it. Start a fresh match and let the next round-boundary autosave create a current v8 snapshot.

## Install paths

Runtime:

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

Optional generated menu mod:

```text
%localappdata%\Plutonium\storage\t5\mods\t5zr_resume_menu\ui\mod.txt
%localappdata%\Plutonium\storage\t5\mods\t5zr_resume_menu\ui\xboxlive_privatelobby.menu
```

Persistent save dvars:

```text
%localappdata%\Plutonium\storage\t5\players\config.cfg
```

## Known limitations

Not currently reconstructed:

- Mystery Box location/history;
- active teleporter cooldown;
- temporary traps and powerups;
- living zombies / exact mid-round positions;
- Easter Egg and sidequest progress;
- RNG state;
- full map-specific world state outside implemented adapters.

The multi-PAP ammo scaling, verified weapon restoration, revised HUD and new mod-based menu integration need continued real r5346 validation before being called stable.

## Plutonium r5346

No external DLL is required. The old `t5-gsc-utils.dll` prototype dependency is not used.

## Reporting a bug

Please include:

- Plutonium build;
- map;
- player count;
- saved round;
- expected vs. actual result;
- relevant `[T5ZR]` console lines.

For menu bugs, also say whether the button appears and whether a different UI/menu mod is installed.

Do not post full GUIDs, IPs, tokens or personal filesystem paths.

## Scope and safety

T5ZR is intended for **private Plutonium T5 Zombies sessions**. It contains no VAC bypass, anti-cheat evasion, process injection or memory patching.

## Credits

Built from public BO1/T5 script references in [`plutoniummod/t5-scripts`](https://github.com/plutoniummod/t5-scripts) and tested in-game.

The optional menu patch is generated locally from Plutonium's public `client-raw-assets` source rather than redistributing that menu file.

Development is substantially assisted by **ChatGPT / OpenAI Codex** for research, implementation and review.

## License

MIT — see [LICENSE](LICENSE).
