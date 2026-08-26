# T5 Zombies Resume

> Prototype host-only pour sauvegarder une partie coop Zombies de **Call of Duty: Black Ops (BO1)** sur **Plutonium T5**, quitter le jeu, puis tenter de reprendre plus tard à partir d'une frontière de manche stable.

![Status](https://img.shields.io/badge/status-exp%C3%A9rimental-orange)
![Version](https://img.shields.io/badge/version-0.2.0--native--test-blue)
![Platform](https://img.shields.io/badge/platform-Plutonium%20T5-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## ⚠️ Statut actuel

**T5 Zombies Resume est un prototype expérimental.**

La version actuelle, `0.2.0-native-test`, a été créée après avoir confirmé sur **Plutonium T5 r5346** que la DLL tierce `t5-gsc-utils.dll` pouvait faire planter le jeu dès l'initialisation avec une erreur liée à `ddl/stats.ddl`.

Le projet a donc été basculé vers une architecture **GSC-only**, sans DLL externe.

Cette version doit encore être validée en jeu sur Kino der Toten. En particulier, il faut confirmer que les `SavedDvar` personnalisés utilisés pour stocker l'état persistent correctement après une fermeture complète de Plutonium.

Ce projet n'est affilié ni à Activision, ni à Treyarch, ni à Steam, ni à l'équipe Plutonium.

---

## 🤖 Transparence : projet développé avec l'aide de l'IA

Le projet a été imaginé à partir d'un besoin concret : pouvoir interrompre une longue partie Zombies entre amis et la reprendre plus tard.

Une partie importante de la recherche, de l'architecture, de la documentation et du code initial a été réalisée avec l'aide de **ChatGPT / OpenAI et Codex**.

Cela signifie notamment que :

- le code initial a été généré et relu avec l'aide d'IA ;
- l'IA a analysé des scripts publics BO1/T5 et des logs Plutonium réels ;
- les changements sont corrigés progressivement à partir des erreurs de compilation/runtime observées ;
- une modification générée par IA n'est jamais considérée comme correcte tant qu'elle n'a pas été testée en jeu ;
- l'objectif du dépôt est aussi d'expérimenter un workflow de développement **humain + IA** transparent.

---

# 🎮 À quoi sert le mod ?

BO1 Zombies n'est pas conçu pour reprendre une longue session coop privée après fermeture complète du jeu.

T5 Zombies Resume tente de reconstruire une partie à partir d'un état de gameplay de haut niveau sauvegardé à la fin d'une manche.

Exemple visé :

```text
Soir 1
Kino - fin de manche
        ↓
autosave
        ↓
fermeture complète de Plutonium

Soir 2
l'host relance Plutonium
        ↓
set zr_resume 1
        ↓
les mêmes amis rejoignent
        ↓
l'host relance Kino
        ↓
le mod tente de restaurer la prochaine manche
```

Il ne s'agit **pas** d'un snapshot complet de la RAM du jeu.

---

# 💾 État sauvegardé par `0.2.0-native-test`

La version actuelle tente de sauvegarder :

- nom de la map ;
- prochaine manche ;
- jusqu'à 4 joueurs ;
- nom de chaque joueur ;
- points ;
- score total ;
- jusqu'à 3 armes principales ;
- munitions dans le chargeur ;
- munitions en réserve ;
- arme sélectionnée quand possible.

Pour limiter les dépendances pendant la validation r5346, les joueurs sont actuellement retrouvés par **nom exact** et non par GUID.

## Pas encore sauvegardé

- perks ;
- courant/power ;
- portes et débris ;
- Mystery Box ;
- pièges ;
- téléporteur / Pack-a-Punch ;
- Easter Eggs / quêtes ;
- zombies vivants ;
- positions exactes ;
- RNG ;
- état complet d'une manche en cours.

La reprise doit donc se faire sur une **frontière de manche stable**.

---

# 🧠 Architecture actuelle : GSC-only

La première version du projet utilisait `t5-gsc-utils.dll` pour écrire des fichiers JSON et enregistrer des commandes console personnalisées.

Sur la configuration de test **Plutonium T5 r5346**, cette DLL a été confirmée comme cause d'un crash au démarrage : le jeu fonctionne normalement quand la DLL est désactivée.

La version actuelle n'utilise donc plus :

```text
t5-gsc-utils.dll
JSON externe
addCommand()
executeCommand()
fileExists()
writeFile()
jsonDump()
jsonParse()
```

À la place, elle utilise les fonctions natives BO1/T5 telles que :

```text
SetSavedDvar
GetDvar
GetDvarInt
SetDvar
```

Les scripts Zombies stock de BO1 utilisent eux-mêmes `SetSavedDvar` pour certaines valeurs moteur. Le prototype réutilise ce mécanisme avec des dvars `zr_sv_*` dédiés.

**La persistance des dvars personnalisés après fermeture complète reste à valider en conditions réelles.**

---

# 👥 Installation host-only

L'objectif reste que **seul l'host installe le GSC**.

Les autres joueurs n'ont pas besoin d'installer d'asset client pour le prototype actuel.

## Prérequis

- Call of Duty: Black Ops sur PC ;
- Plutonium T5 ;
- Zombies fonctionnel sans le mod ;
- aucune DLL `t5-gsc-utils` nécessaire.

---

# 🚫 Important pour Plutonium r5346 : désactiver `t5-gsc-utils`

Si tu avais installé la DLL lors des premiers tests, ferme complètement Plutonium et vérifie :

```text
%localappdata%\Plutonium\plugins\
```

Si tu as :

```text
t5-gsc-utils.dll
```

renomme-la par exemple en :

```text
t5-gsc-utils.dll.disabled
```

Commande PowerShell :

```powershell
Rename-Item "$env:LOCALAPPDATA\Plutonium\plugins\t5-gsc-utils.dll" "t5-gsc-utils.dll.disabled"
```

Sur la configuration r5346 testée, garder cette DLL active provoquait une erreur d'initialisation `ddl/stats.ddl` avant même le chargement de Kino.

---

# 📜 Installer `zombie_resume.gsc`

Le fichier source est :

```text
src\zombie_resume.gsc
```

Les logs Plutonium r5346 utilisés pendant le développement confirment le chargement Zombies depuis :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\
```

Le fichier final doit donc être :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

Les dossiers peuvent être créés manuellement s'ils n'existent pas.

Structure attendue :

```text
Plutonium\
├── plugins\
│   └── t5-gsc-utils.dll.disabled   # uniquement si tu l'avais déjà installée
│
└── storage\
    └── t5\
        └── scripts\
            └── sp\
                └── zom\
                    └── zombie_resume.gsc
```

Ne mets pas une deuxième copie directement dans :

```text
scripts\sp\zombie_resume.gsc
```

car `scripts\sp` peut également être chargé sur le frontend selon la build.

---

# ⚡ Installation automatique

Depuis la racine du dépôt :

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

L'installateur actuel :

- crée `scripts\sp\zom` si nécessaire ;
- nettoie les anciennes copies du GSC dans les emplacements précédemment testés ;
- copie la dernière version de `src\zombie_resume.gsc` ;
- **ne télécharge plus aucune DLL** ;
- avertit si `t5-gsc-utils.dll` est encore active.

Après un `git pull`, relance simplement :

```powershell
git pull
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

---

# ✅ Vérifier que le mod se charge

Lance Kino der Toten.

Dans la console Plutonium, cherche :

```text
Loading script scripts/sp/zom/zombie_resume.gsc...
Script scripts/sp/zom/zombie_resume.gsc loaded successfully.
```

Puis :

```text
[T5ZR] T5 Zombies Resume v0.2.0-native-test loaded (native GSC, no DLL)
```

Si tu obtiens une `Server script compile error`, copie le bloc exact dans une issue ou dans la conversation de développement.

---

# 🎛️ Commandes de test

Comme la version native n'utilise plus `addCommand`, les anciens :

```text
zstatus
zsave
zresume
```

n'existent plus actuellement.

Ils sont remplacés provisoirement par des dvars que le script surveille.

## Afficher l'état

Dans la console pendant la partie :

```text
set zr_status 1
```

La console doit afficher la version du mod, la map, la sauvegarde détectée et la manche sauvegardée.

## Sauvegarde manuelle

```text
set zr_save_now 1
```

Le script remet automatiquement le dvar à `0` après traitement.

## Autosave

L'autosave se déclenche automatiquement après :

```text
level waittill("between_round_over")
```

Le numéro stocké correspond donc à la prochaine manche que le jeu s'apprête à jouer.

---

# 🔄 Reprendre une sauvegarde

## Test sans fermer Plutonium

Après avoir obtenu une sauvegarde valide :

```text
set zr_resume 1
map_restart
```

Au redémarrage de la map, le script doit détecter la demande et afficher :

```text
[T5ZR] Prepared native resume at round X
```

Puis il tente de restaurer les joueurs à leur prochain spawn.

## Test après fermeture complète

1. joue jusqu'à avoir vu un message `[T5ZR] Saved ...` ;
2. ferme complètement Plutonium ;
3. relance Plutonium ;
4. **avant de lancer Kino**, ouvre la console ;
5. tape :

```text
set zr_resume 1
```

6. lance la même map avec les mêmes noms de joueurs.

Ce test est important : il permettra de confirmer ou d'infirmer la persistance réelle des `SavedDvar` personnalisés sur Plutonium T5 r5346.

---

# 🧪 Protocole de validation recommandé sur Kino

Pour le premier vrai test, fais volontairement quelque chose de court :

1. démarre Kino sans `t5-gsc-utils.dll` active ;
2. vérifie le message `0.2.0-native-test loaded` ;
3. joue jusqu'à la fin de la manche 2 ou 3 ;
4. vérifie qu'un message `[T5ZR] Saved zombie_theater -> round ...` apparaît ;
5. tape `set zr_status 1` ;
6. note la manche, les points, armes et munitions ;
7. teste d'abord `set zr_resume 1` puis `map_restart` ;
8. si cela fonctionne, fais ensuite le test avec fermeture complète de Plutonium.

Ne teste pas encore les perks ou l'état du monde : le but est d'abord de valider **chargement → sauvegarde native → persistance → reprise**.

---

# 📁 Où est la sauvegarde ?

La version `0.2.0-native-test` ne crée plus de fichier JSON.

L'état est stocké dans des dvars sauvegardés par le moteur, avec des noms comme :

```text
zr_sv_valid
zr_sv_format
zr_sv_map
zr_sv_round
zr_sv_player_count
zr_sv_p0_name
zr_sv_p0_score
zr_sv_p0_w0_name
zr_sv_p0_w0_clip
zr_sv_p0_w0_stock
```

L'emplacement physique exact est géré par BO1/Plutonium ; le mod ne dépend pas d'un chemin de fichier utilisateur.

---

# 🛡️ Steam / anti-cheat / sécurité

Le projet est conçu uniquement pour **Plutonium T5 Zombies en partie privée**.

Il ne contient pas :

- de bypass VAC ;
- de contournement anti-cheat ;
- de Cheat Engine ;
- d'injection dans le processus vanilla Steam BO1 ;
- de patch binaire de `BlackOps.exe` ;
- de mécanisme destiné à cacher le mod à un anti-cheat.

La version actuelle est encore plus simple que le premier prototype : il s'agit uniquement d'un script GSC chargé via le système de scripts de Plutonium.

Aucun mod tiers ne peut garantir un risque absolu de zéro vis-à-vis de futures politiques de plateforme. N'utilise pas ce prototype dans le multijoueur vanilla Steam.

---

# 🗺️ Roadmap

### `0.2.0-native-test`

- supprimer la dépendance à `t5-gsc-utils` ;
- charger correctement sur r5346 ;
- tester `SetSavedDvar` avec des clés personnalisées ;
- autosave de manche ;
- points ;
- armes ;
- munitions ;
- reprise par nom de joueur.

### Étape suivante

Une fois la persistance native validée :

- améliorer l'identification des joueurs ;
- fiabiliser le timing de restauration de manche ;
- restaurer correctement le HUD des points ;
- ajouter les perks en utilisant les vraies fonctions Zombies et leurs effets secondaires.

### Adaptateurs de map

Kino d'abord, puis :

- Five ;
- Ascension ;
- Call of the Dead ;
- Shangri-La ;
- Moon ;
- maps World at War incluses dans BO1.

Les systèmes comme courant, portes, Box, téléporteur et Pack-a-Punch seront ajoutés map par map après inspection des scripts stock.

---

# 🧠 Développement avec Codex

Le fichier `AGENTS.md` contient les règles de développement pour les agents IA/Codex.

Principes importants :

- Plutonium T5 uniquement ;
- pas de bypass anti-cheat ;
- pas d'injection dans le BO1 Steam vanilla ;
- vérifier les scripts stock avant de manipuler un sous-système Zombies ;
- ajouter un sous-système à la fois ;
- commencer par Kino ;
- ne jamais annoncer une fonctionnalité comme stable avant un vrai test en jeu.

---

# 🔗 Références

- dépôt : https://github.com/GabGaabS/T5-Zombies-Resume
- scripts T5 de référence : https://github.com/plutoniummod/t5-scripts
- documentation Plutonium : https://plutonium.pw/docs/
- `t5-gsc-utils` : https://github.com/alicealys/t5-gsc-utils — **ancienne dépendance, actuellement désactivée pour r5346**

---

# 📄 Licence

MIT — voir `LICENSE`.

---

> **Objectif du projet :** une partie Zombies entre amis ne devrait pas être perdue juste parce que tout le monde doit aller dormir.
