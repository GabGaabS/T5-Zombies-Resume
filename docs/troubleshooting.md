# Troubleshooting

## Le script ne se charge pas

Chemin attendu:

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

La console doit afficher une ligne `[T5ZR] ... loaded`. Si Plutonium affiche une erreur de compilation GSC, relever la première erreur liée à `zombie_resume.gsc`.

## La save disparaît après fermeture complète

Exécute `install.ps1` avec Plutonium fermé. Les `zr_sv_*` doivent être archivés dans `storage\t5\players\config.cfg`.

Le runtime courant accepte uniquement `format=8`.

## Le tableau de scores repart à zéro

T5ZR restaure les champs réseau BO1 `kills`, `headshots`, `downs`, `revives` ainsi que les miroirs `stats[]`.

Lance:

```text
set zr_status 1
```

et vérifie la save/roster avant la reprise.

## Les manches de chiens sont sautées

`set zr_status 1` affiche:

```text
dogs_enabled=...
dog_active=...
dog_count=...
next_dog_round=...
```

Après reprise, cherche aussi `[T5ZR] Dog scheduler restored`.

## Le HUD est trop grand / trop petit

Le HUD r5346 validé utilise la police stock `small`.

```text
set zr_hud_scale_pct 100
map_restart
```

`100` correspond à une échelle moteur de `1.0`. La plage runtime est 50-200.

## Le bouton T5ZR n'apparaît pas dans le lobby

Le menu est optionnel. Ferme Plutonium puis lance:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -InstallMenu
```

Ensuite ouvre **MODS** et charge **t5zr_resume_menu** avant d'entrer en Zombies.

Le dossier doit contenir `description.txt`, `ui\mod.txt` et `ui\xboxlive_privatelobby.menu`.

Pour une reprise, confirme aussi avec `set zr_status 1` que `saved_valid=1` et `format=8`.

## Le lobby/menu est cassé après -InstallMenu

Ferme Plutonium puis:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -RemoveMenu
```

Si un autre mod UI remplace également `xboxlive_privatelobby.menu`, les deux overrides ne peuvent pas être empilés naïvement.

## Le bouton lance une nouvelle partie au lieu de reprendre

Cherche:

```text
[T5ZR] Prepared v8 resume at round ...
```

S'il n'apparaît pas, relève les lignes `[T5ZR]`, `set zr_status 1` et la map lancée.

## Une vieille save ne reprend plus

C'est volontaire depuis 0.8.0-beta.19: les formats v5/v6/v7 ne sont plus lus. T5ZR laisse l'ancienne snapshot intacte mais demande une nouvelle partie pour produire une save v8 courante.

## Crash ddl/stats.ddl

Aucune DLL externe n'est requise. Garde l'ancien `t5-gsc-utils.dll` désactivé sur la configuration r5346 testée.

## Mystery Box / Easter Egg / timers

Ces états restent hors snapshot pour le moment.

## Signaler un bug public

Inclure build T5, version T5ZR, map, nombre de joueurs, round, résultat attendu/obtenu et les lignes `[T5ZR]` utiles. Pour un problème UI, préciser les autres mods de menu installés. Retirer GUIDs, IPs, tokens et chemins personnels.
