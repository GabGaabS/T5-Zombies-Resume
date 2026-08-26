# Troubleshooting

## Le script ne se charge pas

Chemin attendu:

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

## La save disparaît après fermeture complète

Exécute `install.ps1` avec Plutonium fermé. Les `zr_sv_*` doivent être archivés dans `storage\t5\players\config.cfg`.

## Le tableau de scores repart à zéro

Le format v6 restaure les champs réseau BO1 `kills`, `headshots`, `downs`, `revives` ainsi que les miroirs `stats[]`.

## Les manches de chiens sont sautées

`set zr_status 1` affiche:

```text
dogs_enabled=...
dog_active=...
dog_count=...
next_dog_round=...
```

Après reprise, cherche aussi `[T5ZR] Dog scheduler restored`.

## Le bouton T5ZR n'apparaît pas dans le lobby

Le menu est optionnel. Ferme Plutonium puis lance:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -InstallMenu
```

Le bouton n'apparaît que pour l'hôte avec une save v6 valide sur une map supportée.

Vérifie aussi:

```text
set zr_status 1
```

et confirme `saved_valid=1` / `format=6`.

## Le lobby/menu est cassé après -InstallMenu

Ferme Plutonium puis:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -RemoveMenu
```

T5ZR retire son override et restaure automatiquement le menu précédent s'il avait été sauvegardé.

Si un autre mod UI remplace également `xboxlive_privatelobby.menu`, les deux ne peuvent pas être empilés naïvement.

## Le bouton lance une nouvelle partie au lieu de reprendre

Cherche dans la console:

```text
[T5ZR] Prepared v6 resume at round ...
```

S'il n'apparaît pas, relève `set zr_status 1` et la map lancée.

## Crash ddl/stats.ddl

Aucune DLL externe n'est requise. Garde l'ancien `t5-gsc-utils.dll` désactivé sur la configuration r5346 testée.

## Mystery Box / Easter Egg / timers

Ces états restent hors snapshot pour le moment.

## Signaler un bug public

Inclure build T5, map, nombre de joueurs, round, résultat attendu/obtenu et les lignes `[T5ZR]` utiles. Pour un problème UI, préciser les autres mods de menu installés. Retirer GUIDs, IPs, tokens et chemins personnels.
