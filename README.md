# T5 Zombies Resume

> Sauvegarde/reprise host-only pour **Call of Duty: Black Ops (BO1) Zombies** sur **Plutonium T5**.

![Status](https://img.shields.io/badge/status-release%20candidate-yellow)
![Version](https://img.shields.io/badge/version-0.4.0--rc1-blue)
![Platform](https://img.shields.io/badge/platform-Plutonium%20T5-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## Statut actuel

`0.4.0-rc1` étend la reprise joueur validée sur Plutonium T5 r5346 avec la sauvegarde/restauration des **perks Zombies actifs**.

Déjà validé pendant les tests réels :

- chargement automatique du GSC depuis `scripts\sp\zom` ;
- fonctionnement sans DLL externe ;
- autosave au passage à la manche suivante ;
- persistance après fermeture complète de BO1/Plutonium via des dvars archivés dans `config.cfg` ;
- reprise de la manche ;
- reprise des points ;
- reprise des armes principales et munitions ;
- identification stricte des joueurs par `GetGuid()` pour éviter d'appliquer le snapshot de l'host aux mates.

À valider spécifiquement en `0.4.0-rc1` :

- restauration des perks sur plusieurs joueurs ;
- Jugger-Nog avec sa vie max réelle ;
- Speed Cola / Double Tap / Quick Revive ;
- Stamin-Up / PHD Flopper / Deadshot sur les maps qui les exposent ;
- Mule Kick avec une troisième arme.

Le projet reste host-only et ne nécessite pas que les autres joueurs installent un fichier local.

## Ce que sauvegarde le format v4

Pour la session :

- map ;
- prochaine manche ;
- nombre de joueurs ;
- raison de la sauvegarde ;
- version du mod.

Pour chacun des quatre joueurs maximum :

- GUID moteur/Plutonium ;
- nom (debug uniquement) ;
- points ;
- score total ;
- jusqu'à trois armes principales ;
- munitions chargeur + réserve ;
- arme sélectionnée ;
- jusqu'à seize identifiants de perks actifs.

Perks BO1 actuellement reconnus :

- Jugger-Nog — `specialty_armorvest` ;
- Quick Revive — `specialty_quickrevive` ;
- Speed Cola — `specialty_fastreload` ;
- Double Tap — `specialty_rof` ;
- Stamin-Up — `specialty_longersprint` ;
- PHD Flopper — `specialty_flakjacket` ;
- Deadshot Daiquiri — `specialty_deadshot` ;
- Mule Kick — `specialty_additionalprimaryweapon` ;
- leurs variantes `_upgrade` définies par le script stock.

La restauration ne pose pas seulement un flag : elle réutilise `maps\_zombiemode_perks::give_perk`, comme les scripts Zombies stock, afin de reconstruire les effets, le HUD et le lifecycle du perk.

## Installation

Ferme complètement Plutonium puis lance depuis la racine du dépôt :

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Le script installe :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

et pré-enregistre les dvars `zr_sv_*` dans :

```text
%localappdata%\Plutonium\storage\t5\players\config.cfg
```

Un backup initial est conservé sous :

```text
config.cfg.t5zr.bak
```

### Important pour r5346

`t5-gsc-utils.dll` n'est plus utilisé. Sur la configuration de test r5346, la DLL distribuée provoquait un crash d'initialisation `ddl/stats.ddl`.

Si elle existe encore, garde-la désactivée :

```text
%localappdata%\Plutonium\plugins\t5-gsc-utils.dll.disabled
```

## Utilisation

L'autosave se produit automatiquement quand `level.round_number` passe à la manche suivante. Le jeu affiche :

```text
T5ZR: sauvegarde OK - prochaine manche X
```

État de la sauvegarde :

```text
set zr_status 1
```

Sauvegarde manuelle :

```text
set zr_save_now 1
```

Reprise, pour l'instant :

```text
set zr_resume 1
map_restart
```

Effacer la sauvegarde :

```text
set zr_clear_save 1
```

Une intégration **Reprendre la partie** directement dans les menus est prévue après stabilisation du format joueur/perks.

## Migration v3 -> v4

Une sauvegarde v3 ne contient pas les champs de perks. `0.4.0-rc1` exige donc un **nouvel autosave v4** avant de tester une reprise.

Cela évite de confondre un snapshot ancien incomplet avec une sauvegarde v4.

## Ce qui n'est pas encore sauvegardé

Le format v4 est un snapshot **joueur + manche**, pas encore un snapshot complet de la map.

Restent notamment :

- power/courant ;
- portes, débris et barrières persistantes ;
- position/état de la Mystery Box ;
- Pack-a-Punch/téléporteur côté monde ;
- pièges ;
- Easter Eggs / quêtes ;
- zombies vivants ;
- RNG et état exact d'une manche en cours ;
- historique spécial de certains perks (par exemple les usages passés de Quick Revive solo ou les flags de perks permanents liés à certains Easter Eggs).

Ces systèmes doivent être ajoutés map par map, car ils ont des effets secondaires propres aux scripts stock.

## Protocole de test recommandé pour 0.4.0-rc1

1. installer la version avec Plutonium fermé ;
2. lancer Kino avec deux joueurs si possible ;
3. acheter des perks différents entre les joueurs ;
4. garder aussi des armes/points différents ;
5. passer une manche et attendre `sauvegarde OK` ;
6. quitter BO1/Plutonium normalement ;
7. relancer la même map avec les mêmes comptes ;
8. vérifier `set zr_status 1` et le format `4` ;
9. taper `set zr_resume 1`, puis `map_restart` ;
10. vérifier que chaque GUID retrouve uniquement ses propres points, armes, munitions et perks.

Un joueur absent du snapshot garde son état Zombies normal et ne reçoit aucun slot d'un autre joueur.

## Sécurité / périmètre

Le projet vise uniquement Plutonium T5 Zombies en partie privée. Il n'implémente aucun bypass VAC, aucune injection dans le BO1 Steam vanilla, aucun patch mémoire et aucun mécanisme d'évasion anti-cheat.

## Références de développement

- scripts T5 stock : `plutoniummod/t5-scripts` ;
- perks stock : `ZM/Common/maps/_zombiemode_perks.gsc` ;
- runtime du projet : `src/zombie_resume.gsc` ;
- format persistant : `docs/save-format.md` ;
- dépannage : `docs/troubleshooting.md`.
