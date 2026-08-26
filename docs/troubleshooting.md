# Troubleshooting

## Le script ne se charge pas

Chemin attendu :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

Évite une seconde copie directement sous `scripts\sp`.

## Crash `ddl/stats.ddl`

La version actuelle ne nécessite aucune DLL externe. Sur la configuration r5346 de développement, `t5-gsc-utils.dll` provoquait ce crash ; garde-la désactivée.

## La save disparaît après fermeture complète

Exécute `install.ps1` avec Plutonium fermé. Les clés `zr_sv_*` doivent être enregistrées avec `seta` dans `storage\t5\players\config.cfg`.

## Une save beta.1 ne se charge plus

Beta.2 utilise le **format v6**. Une save v5 est volontairement refusée.

Crée une nouvelle autosave, puis:

```text
set zr_status 1
```

La console doit indiquer `format=6`.

## Le tableau de scores repart à zéro

Beta.2 restaure désormais les champs réseau BO1 `kills`, `headshots`, `downs`, `revives` en plus des `stats[]` internes.

Si le tableau est encore faux, relève les quatre valeurs avant l'autosave et après la reprise, puis garde la ligne:

```text
[T5ZR] Restored player ...
```

## Les manches de chiens disparaissent / sont sautées

Lance:

```text
set zr_status 1
```

Beta.2 affiche:

```text
dogs_enabled=...
dog_active=...
dog_count=...
next_dog_round=...
```

Sur une save faite juste avant une manche de chiens, `dog_active=1` signifie que la manche sauvegardée doit reprendre directement avec les hellhounds.

La reprise doit aussi afficher:

```text
[T5ZR] Dog scheduler restored: ...
```

## Un mate reçoit le snapshot d'un autre joueur

Cela ne doit pas arriver: l'appariement utilise uniquement `GetGuid()`. Masque les GUID avant de publier un log.

## Les perks ne reviennent pas

Le runtime utilise le chemin stock `maps\_zombiemode_perks::give_perk`. Indique le perk, la map, l'icône HUD et l'effet gameplay observé.

## Le courant ou une porte Kino ne revient pas

Vérifie `format=6` et `world=kino_v1` dans `zr_status`, puis fournis la ligne `Kino world restored` et précise la porte concernée.

## Mystery Box

Sa position/historique n'est pas encore persisté. C'est une limitation connue.

## Signaler un bug public

Inclure build T5, map, nombre de joueurs, round sauvegardé, résultat attendu/obtenu et les lignes `[T5ZR]` utiles. Retirer GUIDs, IPs, tokens et chemins personnels.
