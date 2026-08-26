# Troubleshooting

## Le script ne s'exécute pas

Chemin attendu sur la build T5 r5346 testée :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

Ne laisse pas une seconde copie directement sous `scripts\sp`, car ce dossier peut être chargé sur le frontend.

## Crash `ddl/stats.ddl` au démarrage

Sur la configuration r5346 testée, `t5-gsc-utils.dll` provoquait ce crash avant le chargement de Kino.

La version actuelle n'en a pas besoin. Garde la DLL désactivée :

```text
%localappdata%\Plutonium\plugins\t5-gsc-utils.dll.disabled
```

## La sauvegarde disparaît après avoir fermé le jeu

Vérifie que `install.ps1` a été exécuté avec Plutonium complètement fermé et que les lignes `seta zr_sv_*` sont présentes dans :

```text
%localappdata%\Plutonium\storage\t5\players\config.cfg
```

Quitte normalement BO1/Plutonium pour le test de persistance.

## Une save v3 ne se charge plus

C'est volontaire en `0.4.x`.

Le format v4 ajoute les perks. Termine au moins une manche avec `0.4.0-rc1` pour créer un nouveau snapshot v4, puis vérifie :

```text
set zr_status 1
```

La console doit indiquer `format=4`.

## Un mate reçoit les armes/stats d'un autre

Cela ne doit plus arriver en format v3+ : les joueurs sont appariés strictement avec `GetGuid()` et aucun fallback par nom n'est utilisé.

Si le problème réapparaît, capture les lignes `[T5ZR] Restored player ... from save slot ...` et le nombre de joueurs sauvegardés. Ne publie pas les GUID complets dans une issue publique.

## Les armes/points reviennent mais pas les perks

En `0.4.0-rc1`, cherche d'abord une erreur de compilation ou runtime autour de :

```text
maps/_zombiemode_perks
give_perk
unknown function
```

Le runtime utilise le même appel cross-script que les scripts Zombies stock :

```text
self maps\_zombiemode_perks::give_perk(perk, false)
```

Si la map charge mais un perk précis n'a pas d'effet, indique le perk, la map et si son icône HUD apparaît.

## Jugger-Nog a l'icône mais pas la bonne vie

C'est précisément pour éviter ce cas que le mod ne se limite pas à `SetPerk`. Le stock `give_perk` applique `SetMaxHealth` pour Jugger-Nog.

Si l'effet est faux, capture le log de reprise et indique si la partie est en mutateur particulier.

## Mule Kick / troisième arme

Les perks sont restaurés avant les armes. Une troisième primaire n'est reconstruite qu'après la restauration de `specialty_additionalprimaryweapon`.

Si la troisième arme manque :

1. confirme que Mule Kick était réellement actif au moment de l'autosave ;
2. confirme que la save est format v4 ;
3. envoie le log autour de `Restored ... perk(s)` et `Restored player ...`.

## Quick Revive solo

Le perk actif est restauré via le chemin stock. En revanche, le format v4 ne sauvegarde pas encore l'historique complet du nombre d'achats/utilisations de Quick Revive au cours de la session précédente.

## Power, portes, Box ou Pack-a-Punch ne reviennent pas

Normal pour le format v4. Ce sont des états de map, pas des champs joueur. Ils seront ajoutés avec des adaptateurs spécifiques par map afin de respecter les effets secondaires des scripts stock.

## Le numéro de manche est mauvais

Capture :

```text
[T5ZR] Prepared v4 resume at round ...
```

Le mod reconstruit une frontière de manche stable ; il ne tente pas de restaurer une manche en cours avec ses zombies vivants.
