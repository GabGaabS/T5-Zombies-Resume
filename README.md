# T5 Zombies Resume

> Sauvegarde/reprise host-only pour **Call of Duty: Black Ops (BO1) Zombies** sur **Plutonium T5**.

![Status](https://img.shields.io/badge/status-release%20candidate-yellow)
![Version](https://img.shields.io/badge/version-0.3.0--rc1-blue)
![Platform](https://img.shields.io/badge/platform-Plutonium%20T5-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## Statut actuel

`0.3.0-rc1` est la première release candidate issue des tests réels sur **Plutonium T5 r5346**.

Validé pendant le développement :

- chargement du GSC depuis `scripts\sp\zom` ;
- fonctionnement sans DLL externe ;
- autosave au passage à la manche suivante ;
- restauration de la manche, des points, armes et munitions ;
- persistance de la sauvegarde après fermeture complète de BO1/Plutonium grâce aux dvars archivés dans `config.cfg` ;
- reprise après relance avec `set zr_resume 1` puis `map_restart`.

La `0.2.x` avait encore un défaut coop important : l'identification par nom pouvait faire correspondre plusieurs joueurs au même slot et leur appliquer le même équipement/stats. `0.3.0-rc1` remplace cette logique par une correspondance **strictement par `GetGuid()`**, sans fallback par nom, avec verrouillage des slots et une seule restauration par joueur.

Cette correction doit encore être confirmée par un test coop réel avant de considérer `0.3.0` comme stable.

Ce projet n'est affilié ni à Activision, Treyarch, Steam, ni à l'équipe Plutonium.

---

## Architecture

La version actuelle est **GSC-only** et host-only.

Aucune DLL `t5-gsc-utils` n'est nécessaire. Sur la configuration r5346 utilisée pendant les tests, cette DLL provoquait un crash au démarrage sur `ddl/stats.ddl`, elle doit donc rester désactivée.

Runtime :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

Persistance :

```text
%localappdata%\Plutonium\storage\t5\players\config.cfg
```

`install.ps1` pré-enregistre les clés `zr_sv_*` avec `seta`. Elles conservent ainsi le flag archive et survivent à une fermeture normale du jeu.

---

## Installation / mise à jour

Ferme complètement Plutonium, puis depuis la racine du dépôt :

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Avec un clone Git :

```powershell
git pull
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

L'installateur :

- copie le GSC au bon emplacement Zombies ;
- supprime les anciennes copies potentiellement chargées au mauvais endroit ;
- crée une sauvegarde `config.cfg.t5zr.bak` la première fois ;
- ajoute les dvars archivés manquants sans écraser les valeurs existantes ;
- ajoute les nouveaux champs GUID du format v3 ;
- avertit si `t5-gsc-utils.dll` est encore active.

Si tu utilises un ZIP GitHub, retélécharge le ZIP pour obtenir les nouvelles versions de `install.ps1` et `src\zombie_resume.gsc`.

---

## Important : migration depuis 0.2.x

Le format de sauvegarde passe de **v2 à v3**.

Une ancienne save v2 est volontairement refusée, car elle ne contient pas d'identité GUID suffisamment sûre pour la coop.

Après installation de `0.3.0-rc1` :

1. lance une nouvelle partie ;
2. termine au moins une manche ;
3. attends le message `T5ZR: sauvegarde OK` ;
4. cette nouvelle sauvegarde sera au format v3.

---

## Ce qui est sauvegardé

À chaque frontière de manche :

- map ;
- prochaine manche ;
- jusqu'à 4 joueurs ;
- GUID moteur/Plutonium de chaque joueur ;
- nom, uniquement comme métadonnée d'affichage/debug ;
- points et score total ;
- jusqu'à 3 armes principales ;
- munitions chargeur/réserve ;
- arme sélectionnée.

### Identification coop v3

La restauration fonctionne ainsi :

1. le joueur rejoint la map ;
2. son `GetGuid()` est lu ;
3. le mod cherche exactement ce GUID dans les slots sauvegardés ;
4. le slot est verrouillé dès qu'il est utilisé ;
5. ce joueur ne peut être restauré qu'une seule fois pendant la reprise.

Si aucun GUID ne correspond, **le joueur garde son état Zombies normal**. Le mod ne tente jamais de lui donner la sauvegarde d'un autre joueur.

Cela signifie aussi qu'un ami différent qui rejoint une ancienne sauvegarde ne récupère pas les armes/points d'un participant précédent.

---

## Pas encore sauvegardé

Le projet reconstruit un état de gameplay de haut niveau, pas un snapshot RAM complet.

Ne sont pas encore restaurés :

- perks ;
- portes/débris ;
- courant ;
- Mystery Box ;
- pièges ;
- téléporteur/Pack-a-Punch ;
- quêtes/Easter Eggs ;
- zombies vivants ;
- positions exactes ;
- état RNG ;
- milieu d'une manche.

La sauvegarde se fait donc à une **frontière de manche stable**.

---

## Utilisation

### Vérifier la sauvegarde

Dans la vraie console du jeu :

```text
set zr_status 1
```

### Sauvegarde automatique

Rien à taper. À chaque passage à la manche suivante :

```text
T5ZR: sauvegarde OK - prochaine manche X
```

### Sauvegarde manuelle

```text
set zr_save_now 1
```

### Reprendre après avoir relancé le jeu

1. lance la même map normalement ;
2. ouvre la console ;
3. vérifie éventuellement :

```text
set zr_status 1
```

4. arme la reprise :

```text
set zr_resume 1
```

5. redémarre la map :

```text
map_restart
```

Chaque joueur présent dans la sauvegarde doit récupérer **son propre** snapshot v3 par GUID.

### Effacer la sauvegarde

```text
set zr_clear_save 1
```

---

## Test coop recommandé pour 0.3.0-rc1

Pour valider définitivement la correction :

1. host + au moins un ami lancent Kino ;
2. chacun garde des points/armes volontairement différents ;
3. terminer une manche et attendre `sauvegarde OK` ;
4. quitter normalement le jeu ;
5. relancer la même équipe ;
6. `set zr_resume 1` puis `map_restart` ;
7. vérifier que chacun récupère ses propres points/armes ;
8. vérifier qu'aucun équipement n'est recopié d'un joueur à l'autre.

Test bonus : reprendre avec un nouveau joueur qui n'était pas dans la sauvegarde. Il doit recevoir son loadout Zombies normal et le message indiquant qu'aucune sauvegarde ne lui est associée.

---

## Futur menu « Reprendre la partie »

La console sert encore d'interface de développement. Une future couche UI pourra afficher directement dans le menu Zombies une action **Reprendre la partie** avec la map et la manche sauvegardées, puis armer `zr_resume` et charger la map automatiquement.

La priorité reste d'abord de stabiliser le runtime coop v3.

---

## Sécurité / anti-cheat

Le projet cible uniquement **Plutonium T5 Zombies en partie privée**.

Il ne contient pas :

- bypass VAC/anti-cheat ;
- Cheat Engine ;
- injection dans le BO1 Steam vanilla ;
- patch mémoire ou binaire de `BlackOps.exe` ;
- mécanisme de dissimulation.

Aucun mod tiers ne peut garantir un risque absolu de zéro vis-à-vis de futures politiques de plateforme. N'utilise pas ce projet pour le multijoueur vanilla Steam.

---

## Développement

Les scripts T5 de référence utilisés pendant le développement sont ceux du dépôt public `plutoniummod/t5-scripts`. Les changements ne sont considérés stables qu'après validation réelle en jeu.

Le fichier `AGENTS.md` contient les règles du dépôt pour les contributions humaines/IA.
