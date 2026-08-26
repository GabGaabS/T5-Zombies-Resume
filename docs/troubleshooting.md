# Troubleshooting

## Le script ne se charge pas

Chemin attendu sur la build T5 r5346 testée :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

Évite toute seconde copie directement sous `scripts\sp` : ce dossier peut aussi être chargé sur le frontend.

## Crash `ddl/stats.ddl` au démarrage

La version actuelle ne nécessite aucune DLL externe.

Sur la configuration r5346 utilisée pendant le développement, `t5-gsc-utils.dll` provoquait ce crash avant le chargement de Kino. Si tu l'avais installée pour une ancienne version, garde-la désactivée.

## La save disparaît après fermeture complète

Exécute `install.ps1` avec Plutonium fermé. Les clés `zr_sv_*` doivent être pré-enregistrées avec `seta` dans :

```text
%localappdata%\Plutonium\storage\t5\players\config.cfg
```

Le premier lancement de l'installateur crée aussi `config.cfg.t5zr.bak`.

## Une ancienne save ne se charge plus

`0.5.x` exige le format v5. Une save v4 n'est pas convertie automatiquement.

Termine une manche avec la nouvelle version, puis :

```text
set zr_status 1
```

La console doit indiquer `format=5`.

## Un mate reçoit le snapshot d'un autre joueur

Cela ne doit pas arriver : le runtime utilise un appariement strict `GetGuid()` et aucun fallback par nom.

Si le problème réapparaît, fournis les lignes `[T5ZR] Restored player ... from save slot ...`, mais masque les GUID avant de publier un log.

## Les perks ne reviennent pas

Le runtime utilise le chemin stock :

```text
self maps\_zombiemode_perks::give_perk(perk, false)
```

Si un perk précis pose problème, indique la map, le perk, si son icône apparaît et si son effet gameplay fonctionne.

## Le compteur de kills/stats est faux

Le format v5 sauvegarde/restaure : kills, kill tracker, headshots, downs, revives, zombie gibs et compteur de perks consommés.

Si une valeur diverge, note la valeur juste avant l'autosave et juste après la reprise. Les statistiques de carrière/leaderboard ne sont pas réécrites par T5ZR ; il restaure uniquement l'état de la session reprise.

## Le courant Kino ne revient pas

Vérifie d'abord :

```text
set zr_status 1
```

Le save doit être v5 et `world=kino_v1`.

La reprise remet le flag stock `power_on` et laisse le thread Kino `wait_for_power()` appliquer les effets. Si le flag est restauré mais que les machines/lumières restent incorrectes, envoie les lignes `[T5ZR] Kino world restored...` et les erreurs qui suivent.

## Une porte Kino est visuellement fermée/ou les zombies traversent mal

Le v5 ouvre les entités `zombie_door` / `zombie_debris` correspondant aux flags de route de `theater_zone_init()` puis réactive les mêmes flags de zone.

Signale précisément quelle porte est concernée (côté spawn/VIP, alley, dressing, stage, etc.). Les coordonnées ou un screenshot sont plus utiles qu'un log complet.

## Le téléporteur Kino n'est pas restauré comme prévu

Seul l'état **entièrement lié** est sauvegardé. Un lien commencé mais pas terminé est volontairement remis à zéro. Le cooldown après utilisation n'est pas sauvegardé non plus.

## La Mystery Box a changé de place

C'est encore une limitation connue. Le v5 ne persiste pas la position/historique de la Box, car `level.chest_index` est couplé à la configuration des entités de coffre. Une restauration partielle serait plus fragile qu'un reset normal.

## Le numéro de manche est mauvais

Cherche :

```text
[T5ZR] Prepared v5 resume at round ...
```

T5ZR reconstruit une frontière de manche stable. Il ne tente pas de sauvegarder les zombies vivants ni l'état exact d'une manche en cours.

## Signaler un bug public

Inclure :

- build Plutonium T5 ;
- map ;
- nombre de joueurs ;
- round sauvegardé ;
- résultat attendu / obtenu ;
- lignes `[T5ZR]` utiles.

Retirer les GUID, IP, tokens, chemins personnels et autres informations privées avant publication.
