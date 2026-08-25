# T5 Zombies Resume

> Sauvegarder une partie coop Zombies de **Call of Duty: Black Ops (BO1)** sur **Plutonium T5**, fermer complètement le jeu, puis reprendre plus tard à partir de la manche suivante.

![Status](https://img.shields.io/badge/status-exp%C3%A9rimental-orange)
![Version](https://img.shields.io/badge/version-0.1.0-blue)
![Platform](https://img.shields.io/badge/platform-Plutonium%20T5-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## ⚠️ Projet expérimental

**T5 Zombies Resume est actuellement un prototype v0.1.0.** Le premier objectif est de stabiliser la reprise sur **Kino der Toten** avant d'étendre progressivement la sauvegarde aux perks et à l'état du monde.

Ce projet n'est affilié ni à Activision, ni à Treyarch, ni à Steam, ni à l'équipe Plutonium.

---

## 🤖 Transparence : projet développé avec l'aide de l'IA

Ce projet a été imaginé à partir d'un besoin concret : pouvoir interrompre une longue partie Zombies entre amis et la reprendre plus tard.

Une partie importante de la recherche, de l'architecture, de la documentation et du code initial a été réalisée avec l'aide de **ChatGPT / OpenAI et Codex**.

Cela signifie que :

- le code initial a été généré et relu avec l'aide d'IA ;
- l'IA a analysé des scripts publics BO1/T5 et les fonctions exposées par `t5-gsc-utils` ;
- le code doit être validé en conditions réelles sur Plutonium ;
- une modification générée par IA n'est pas automatiquement considérée comme correcte ;
- toute évolution importante doit être testée en partie privée avant d'être considérée comme stable.

Le but n'est pas de cacher l'utilisation de l'IA : ce dépôt est aussi une expérience de développement collaboratif **humain + IA**.

---

# 🎮 À quoi sert le mod ?

Dans BO1 Zombies, une partie coop peut durer plusieurs heures. Si l'host ferme la partie, la session n'est normalement pas conçue pour être reprise plus tard comme une sauvegarde de campagne.

T5 Zombies Resume tente de sauvegarder une représentation utile de la session sur le PC de l'host.

Exemple :

```text
Soir 1
Kino - manche 26 terminée
        ↓
autosave
        ↓
fermeture complète de Plutonium

Soir 2
l'host relance Plutonium
        ↓
active la reprise
        ↓
invite les mêmes amis
        ↓
relance Kino
        ↓
la partie tente de reprendre manche 27
```

## Ce que la v0.1 sauvegarde

- nom de la map ;
- prochaine manche ;
- GUID et nom des joueurs ;
- points ;
- score total ;
- armes principales ;
- munitions dans le chargeur ;
- munitions en réserve ;
- arme actuellement sélectionnée quand possible ;
- une sauvegarde de secours `.backup.json`.

## Ce qui n'est pas encore restauré

- perks ;
- courant/power ;
- portes et débris ;
- Mystery Box ;
- pièges ;
- état Pack-a-Punch / téléporteurs ;
- Easter Eggs / quêtes ;
- zombies vivants, positions et RNG au milieu d'une manche.

La v0.1 est donc une **reprise logique entre deux manches**, pas un save-state de la mémoire du jeu.

---

# 👥 Installation host-only

Le but du MVP est que **seul l'host installe le mod**.

Les amis n'ont normalement rien à installer pour rejoindre la partie privée. La v0.1 ne contient aucun asset client personnalisé.

Deux éléments sont nécessaires sur le PC de l'host :

1. `t5-gsc-utils.dll` — plugin Plutonium qui fournit les fonctions fichier/JSON/commandes ;
2. `zombie_resume.gsc` — le mod de sauvegarde/reprise de ce dépôt.

---

# 📦 1. Installer `t5-gsc-utils`

Projet officiel utilisé par ce mod :

https://github.com/alicealys/t5-gsc-utils

Télécharge la dernière version de `t5-gsc-utils.dll`.

Le dossier attendu est :

```text
%localappdata%\Plutonium\plugins\
```

Le fichier final doit donc être :

```text
%localappdata%\Plutonium\plugins\t5-gsc-utils.dll
```

### Je n'ai pas de dossier `plugins`

C'est normal : **crée-le manuellement**.

1. `Win + R`
2. colle :

```text
%localappdata%\Plutonium
```

3. crée un dossier nommé :

```text
plugins
```

4. place `t5-gsc-utils.dll` dedans.

⚠️ Le dossier `plugins` est directement sous `Plutonium`, **pas** sous `storage\t5`.

Structure attendue :

```text
Plutonium\
├── plugins\
│   └── t5-gsc-utils.dll
└── storage\
    └── t5\
```

---

# 📜 2. Installer `zombie_resume.gsc`

Le script source se trouve ici :

```text
src\zombie_resume.gsc
```

## Important : partie privée / solo

Pour T5 Zombies en partie privée/solo, le chargement le plus fiable consiste à placer le script dans le **dossier correspondant à la map** sous :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\
```

Ces dossiers peuvent ne pas exister : **crée-les manuellement**.

### Kino der Toten — recommandé pour le premier test

Crée :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zombie_theater\
```

Puis place le fichier ici :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zombie_theater\zombie_resume.gsc
```

Structure attendue :

```text
Plutonium\
├── plugins\
│   └── t5-gsc-utils.dll
└── storage\
    └── t5\
        └── scripts\
            └── sp\
                └── zombie_theater\
                    └── zombie_resume.gsc
```

## Noms de dossiers des maps

Pour installer le script sur plusieurs maps, copie le même `zombie_resume.gsc` dans le dossier de chaque map :

| Map | Dossier |
|---|---|
| Kino der Toten | `zombie_theater` |
| Five | `zombie_pentagon` |
| Ascension | `zombie_cosmodrome` |
| Call of the Dead | `zombie_coast` |
| Shangri-La | `zombie_temple` |
| Moon | `zombie_moon` |
| Nacht der Untoten | `zombie_cod5_prototype` |
| Verrückt | `zombie_cod5_asylum` |
| Shi No Numa | `zombie_cod5_sumpf` |
| Der Riese | `zombie_cod5_factory` |

Exemple pour Ascension :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zombie_cosmodrome\zombie_resume.gsc
```

## Et le dossier `zom` ?

On rencontre aussi ce chemin dans des scripts T5 :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\
```

Il peut être utilisé dans certains contextes Zombies/serveur, mais sur T5 privé/solo le comportement a historiquement été moins uniforme selon les scripts et les builds.

**Pour ce projet, utilise d'abord les dossiers spécifiques aux maps.**

Tu n'as donc pas besoin d'avoir un dossier `zom` pour tester Kino.

---

# ⚡ Installation automatique des dossiers

Le dépôt contient également :

```text
install.ps1
```

Ce script :

- crée `%localappdata%\Plutonium\plugins` s'il manque ;
- crée les dossiers T5 Zombies nécessaires ;
- copie `src\zombie_resume.gsc` dans les dossiers de maps connus ;
- n'installe pas automatiquement une DLL téléchargée sur Internet.

Depuis PowerShell, à la racine du dépôt :

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Tu dois ensuite placer toi-même `t5-gsc-utils.dll` dans le dossier `plugins` créé par le script.

---

# 🎮 Utilisation

Une fois le plugin DLL et le GSC installés :

1. démarre Plutonium T5 ;
2. lance Zombies ;
3. crée une partie privée sur Kino ;
4. regarde la console host.

Le mod doit afficher quelque chose proche de :

```text
[T5ZR] T5 Zombies Resume v0.1.0 loaded
```

## Commandes host

### `zstatus`

Affiche l'état du mod : version, map, manche, chemin de sauvegarde et statut de reprise.

```text
zstatus
```

### `zsave`

Force une sauvegarde manuelle.

```text
zsave
```

Il est recommandé de sauvegarder **entre deux manches**.

### `zresume`

Charge la sauvegarde de la map actuelle après un `map_restart`.

```text
zresume
```

Cette commande est surtout utile pour tester rapidement sans fermer Plutonium.

---

# 💾 Reprendre après avoir complètement fermé le jeu

Quand Plutonium est fermé, le script GSC ne tourne évidemment plus.

Au prochain lancement :

1. démarre Plutonium T5 ;
2. ouvre la console ;
3. exécute :

```text
set zr_autoresume 1
```

4. invite les mêmes amis ;
5. démarre **la même map**.

Si la sauvegarde est valide, le mod tente de :

- charger le numéro de manche ;
- retrouver les joueurs par GUID ;
- restaurer leurs points ;
- restaurer armes et munitions.

Le flag `zr_autoresume` est consommé après acceptation de la sauvegarde.

---

# 📁 Où sont les sauvegardes ?

`t5-gsc-utils` travaille relativement au `fs_homepath` T5.

Le mod crée :

```text
zombie_resume\saves\<mapname>.json
zombie_resume\saves\<mapname>.backup.json
```

Exemple :

```text
zombie_resume\saves\zombie_theater.json
```

Ne modifie pas manuellement le JSON sauf pour du debug.

---

# 🧪 Premier test recommandé

Commence uniquement sur **Kino der Toten**.

1. Installe `t5-gsc-utils.dll`.
2. Installe `zombie_resume.gsc` dans `scripts\sp\zombie_theater`.
3. Lance Kino avec un ami.
4. Exécute `zstatus`.
5. Joue jusqu'à la manche 3.
6. Termine la manche.
7. Vérifie le message `[T5ZR] Saved`.
8. Note les points, armes et munitions des deux joueurs.
9. Exécute `zresume`.
10. Vérifie la manche et les inventaires.
11. Ferme complètement Plutonium.
12. Relance-le.
13. Exécute `set zr_autoresume 1`.
14. Invite le même ami et relance Kino.
15. Vérifie la restauration après redémarrage complet.

Si le script ne se charge pas ou produit une erreur, copie **l'erreur exacte de la console Plutonium** dans une issue GitHub.

---

# 🛡️ Steam / anti-cheat / sécurité

Ce projet est conçu pour rester du côté **Plutonium T5 / partie Zombies privée**.

Le projet ne contient pas :

- de bypass VAC ;
- de contournement anti-cheat ;
- de Cheat Engine ;
- d'injection dans le processus vanilla Steam BO1 ;
- de patch binaire de `BlackOps.exe` ;
- de mécanisme destiné à cacher le mod à un anti-cheat.

Le mod principal est un script GSC. `t5-gsc-utils.dll` est une dépendance tierce chargée par le système de plugins Plutonium.

Aucun mod tiers ne peut garantir un risque absolu de zéro vis-à-vis des politiques futures d'une plateforme. **N'utilise pas ce prototype dans le multijoueur vanilla Steam.**

---

# 🗺️ Roadmap

### v0.1
- round ;
- joueurs ;
- points ;
- armes principales ;
- munitions ;
- sauvegarde JSON + backup.

### v0.2
- perks avec les vrais effets Zombies associés.

### v0.3
- adaptateur Kino ;
- courant ;
- portes/débris ;
- Mystery Box ;
- état téléporteur/PaP quand raisonnable.

### v0.4
- adaptateurs Five, Ascension, CotD, Shangri-La et Moon.

### v0.5
- plusieurs slots ;
- migrations de format ;
- meilleure récupération en cas de corruption ;
- outils de diagnostic.

---

# 🧠 Développement avec Codex

Le fichier `AGENTS.md` donne les règles de développement pour les agents IA/Codex.

Principes importants :

- ne pas inventer les variables internes BO1 ;
- vérifier les scripts stock T5 avant de modifier un système complexe ;
- ajouter un sous-système à la fois ;
- commencer par Kino ;
- ne pas transformer le projet en bypass anti-cheat ;
- toujours tester les changements dans Plutonium avant de les déclarer stables.

---

# 🔗 Liens utiles

- T5 Zombies Resume : https://github.com/GabGaabS/T5-Zombies-Resume
- t5-gsc-utils : https://github.com/alicealys/t5-gsc-utils
- scripts T5 de référence : https://github.com/plutoniummod/t5-scripts
- documentation Plutonium : https://plutonium.pw/docs/

---

# 📄 Licence

MIT — voir `LICENSE`.
