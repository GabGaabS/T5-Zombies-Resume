# T5 Zombies Resume

> Sauvegarder une partie coop Zombies de **Call of Duty: Black Ops (BO1)** sur **Plutonium T5**, fermer complètement le jeu, puis reprendre plus tard à partir de la manche suivante.

![Status](https://img.shields.io/badge/status-exp%C3%A9rimental-orange)
![Version](https://img.shields.io/badge/version-0.1.0-blue)
![Platform](https://img.shields.io/badge/platform-Plutonium%20T5-lightgrey)
![License](https://img.shields.io/badge/license-MIT-green)

## ⚠️ Projet expérimental

**T5 Zombies Resume est actuellement un prototype v0.1.0 qui doit encore être validé en conditions réelles sur toutes les cartes et toutes les configurations.**

Le premier objectif est de stabiliser la reprise sur **Kino der Toten**, puis d'ajouter progressivement les perks et l'état du monde.

Ce projet n'est affilié ni à Activision, ni à Treyarch, ni à Steam, ni à l'équipe Plutonium.

---

## 🤖 Transparence : projet développé avec l'aide de l'IA

Ce projet a été imaginé à partir d'un besoin utilisateur concret : pouvoir interrompre une longue partie Zombies entre amis et la reprendre plus tard.

Une partie importante de la recherche, de l'architecture, de la documentation et du code initial a été réalisée avec l'aide de **ChatGPT / OpenAI et d'outils de programmation assistée par IA tels que Codex**.

Cela signifie notamment que :

- le code initial a été généré et relu avec l'aide d'IA ;
- l'IA a analysé les scripts publics de BO1/T5 et les API disponibles dans `t5-gsc-utils` ;
- certaines parties devront être corrigées après de vrais tests en jeu ;
- une contribution générée par IA n'est **pas automatiquement considérée comme correcte** ;
- toute évolution importante doit idéalement être testée sur une partie privée avant d'être considérée comme stable.

L'objectif n'est pas de cacher l'utilisation de l'IA : au contraire, ce dépôt est aussi une expérience de développement collaboratif **humain + IA**.

Le propriétaire du dépôt reste responsable de décider quelles modifications sont conservées, testées et publiées.

---

# 🎮 À quoi sert T5 Zombies Resume ?

Dans BO1 Zombies, une longue partie coop peut durer plusieurs heures. En temps normal, si l'host ferme la partie, la progression de la session est perdue.

T5 Zombies Resume tente de résoudre ce problème en sauvegardant une **représentation de l'état utile de la partie** sur le PC de l'host.

Exemple :

```text
Soir 1

Kino der Toten
Manche 26 terminée
      ↓
Autosave
      ↓
Vous fermez Plutonium et le PC

────────────────────────────

Soir 2

L'host relance Plutonium
      ↓
Active la reprise
      ↓
Invite les mêmes amis
      ↓
Relance Kino
      ↓
Le mod charge la sauvegarde
      ↓
La partie reprend à la manche 27
```

L'objectif à terme est de retrouver autant que possible :

- la manche ;
- les joueurs ;
- leurs points ;
- leurs armes ;
- leurs munitions ;
- leurs perks ;
- le courant ;
- les portes déjà ouvertes ;
- le Pack-a-Punch ;
- l'emplacement de la Mystery Box ;
- certains états propres à chaque map.

Le mod ne cherche **pas** à faire un snapshot exact de toute la mémoire du moteur.

La philosophie du projet est plutôt :

> **Sauvegarder à un point stable entre deux manches puis reconstruire proprement la partie au prochain lancement.**

Cette approche est beaucoup plus réaliste et robuste pour BO1 Zombies.

---

# 👥 Est-ce que tous les joueurs doivent installer le mod ?

## Pour la v0.1 : non.

Le projet est conçu pour être **host-only** autant que possible.

L'host installe :

1. `t5-gsc-utils` ;
2. `zombie_resume.gsc`.

Les amis rejoignent ensuite la partie privée normalement.

```text
                 HOST
                  │
         Plutonium T5 Zombies
                  │
       ┌──────────┴──────────┐
       │                     │
t5-gsc-utils.dll     zombie_resume.gsc
       │                     │
       └──────────┬──────────┘
                  │
             sauvegarde
                  │
             fichier JSON
                  │
      ┌───────────┼───────────┐
      │           │           │
   Ami #1      Ami #2      Ami #3
 rien à       rien à       rien à
 installer    installer    installer
```

Cette architecture pourra changer si une future interface graphique nécessite des fichiers côté client, mais ce n'est pas prévu pour le MVP.

---

# 💾 Ce que sauvegarde la v0.1

La version actuelle vise à sauvegarder :

- le nom de la map ;
- la prochaine manche ;
- le GUID de chaque joueur ;
- le pseudo de chaque joueur ;
- les points actuels ;
- le score total ;
- les armes primaires ;
- les munitions dans le chargeur ;
- les munitions en réserve ;
- l'arme actuellement sélectionnée lorsque cela est possible ;
- une sauvegarde précédente de secours (`.backup.json`).

L'autosave est prévu autour de la notification BO1 :

```text
between_round_over
```

C'est volontaire : une transition entre deux manches est beaucoup plus simple à restaurer qu'une partie en plein combat.

---

# 🚧 Ce qui n'est PAS encore sauvegardé

La v0.1 ne garantit pas encore la restauration de :

- perks ;
- portes et débris ;
- courant ;
- Pack-a-Punch ;
- Mystery Box ;
- pièges ;
- téléporteurs ;
- cooldowns ;
- zombies actuellement vivants ;
- position exacte des zombies ;
- état exact de l'IA ;
- graines RNG ;
- progression complète d'un Easter Egg ;
- événements spéciaux complexes propres à Moon, Shangri-La, Call of the Dead, etc.

Ces éléments seront ajoutés progressivement, map par map.

---

# 📋 Prérequis

Il faut :

- **Call of Duty: Black Ops sur PC** utilisable avec Plutonium ;
- **Plutonium T5** ;
- le plugin **t5-gsc-utils** installé uniquement sur la machine de l'host ;
- le fichier `zombie_resume.gsc` de ce dépôt.

### Liens

- T5 Zombies Resume : https://github.com/GabGaabS/T5-Zombies-Resume
- t5-gsc-utils : https://github.com/alicealys/t5-gsc-utils
- Scripts T5 publics : https://github.com/plutoniummod/t5-scripts
- Documentation Plutonium T5 : https://www.plutonium.pw/docs/client/t5/loading-mods/

---

# 📦 Installation complète

## Étape 1 — Installer Plutonium T5

Installe et configure BO1 avec Plutonium normalement.

Vérifie d'abord qu'une partie Zombies privée fonctionne **sans ce mod**.

Cela permet de ne pas mélanger un problème de configuration Plutonium avec un problème du mod.

---

## Étape 2 — Installer `t5-gsc-utils`

Télécharge la version actuelle de :

https://github.com/alicealys/t5-gsc-utils

Le fichier DLL doit être placé côté host dans :

```text
%localappdata%\Plutonium\plugins\t5-gsc-utils.dll
```

`%localappdata%` correspond généralement à :

```text
C:\Users\TON_NOM\AppData\Local
```

Ce plugin fournit au GSC des fonctions qui n'existent pas normalement, notamment :

- lecture de fichiers ;
- écriture de fichiers ;
- JSON ;
- commandes console personnalisées.

**Ne place pas cette DLL dans le dossier Steam de Black Ops.**

---

## Étape 3 — Installer T5 Zombies Resume

Télécharge :

```text
src/zombie_resume.gsc
```

Depuis ce dépôt :

https://github.com/GabGaabS/T5-Zombies-Resume/blob/main/src/zombie_resume.gsc

Puis place-le dans :

```text
%localappdata%\Plutonium\storage\t5\scripts\sp\zom\zombie_resume.gsc
```

Tu devrais obtenir quelque chose comme :

```text
AppData
└── Local
    └── Plutonium
        ├── plugins
        │   └── t5-gsc-utils.dll
        │
        └── storage
            └── t5
                └── scripts
                    └── sp
                        └── zom
                            └── zombie_resume.gsc
```

Si ce chemin de scripts n'est pas chargé par ta version de T5, consulte :

```text
docs/troubleshooting.md
```

Le fallback à tester est notamment :

```text
raw\scripts\sp
```

---

# ✅ Vérifier que le mod est chargé

Lance une partie Zombies en étant host.

Dans la console Plutonium, tu dois voir :

```text
[T5ZR] T5 Zombies Resume v0.1.0 loaded
```

Tu peux ensuite taper :

```text
zstatus
```

Le mod doit afficher des informations telles que :

- sa version ;
- la map ;
- la manche actuelle ;
- le chemin de sauvegarde ;
- l'état de l'autoresume.

Si la commande n'existe pas, le GSC ou `t5-gsc-utils` n'a probablement pas été chargé correctement.

---

# 🎛️ Commandes disponibles

## `zstatus`

Affiche l'état du mod.

```text
zstatus
```

À utiliser en premier pour vérifier l'installation.

---

## `zsave`

Force une sauvegarde manuelle.

```text
zsave
```

Il est fortement recommandé de l'utiliser **entre deux manches** et non au milieu d'un combat.

Le mod effectue aussi automatiquement des sauvegardes aux points prévus par son système d'autosave.

---

## `zresume`

Teste immédiatement une reprise de la sauvegarde de la map actuelle.

```text
zresume
```

Cette commande arme la sauvegarde puis lance un redémarrage de la map.

Elle est surtout utile pendant le développement et les tests.

---

# 🔄 Reprendre une partie après avoir complètement fermé le jeu

Supposons que vous ayez terminé la manche 20.

Le mod sauvegarde alors la reprise vers la manche suivante.

Vous pouvez ensuite fermer complètement Plutonium.

Au prochain lancement :

## 1. Ouvrir la console de l'host

Avant de lancer la map :

```text
set zr_autoresume 1
```

## 2. Inviter les mêmes amis

Pour de meilleurs résultats pendant le développement, utilise les mêmes joueurs que lors de la sauvegarde.

Le mod essaie de faire correspondre les joueurs grâce à leur GUID.

## 3. Lancer la même map

Exemple :

```text
zombie_theater
```

pour Kino der Toten.

## 4. Le mod charge la sauvegarde

S'il trouve une sauvegarde compatible, il essaie de :

1. valider le fichier ;
2. vérifier qu'il correspond à la map ;
3. positionner la manche sauvegardée ;
4. attendre que les joueurs soient disponibles ;
5. retrouver chaque joueur grâce à son GUID ;
6. restaurer ses points ;
7. restaurer ses armes ;
8. restaurer ses munitions.

Le flag d'autoresume est ensuite consommé afin d'éviter de recharger la même sauvegarde accidentellement à chaque restart.

---

# 🗂️ Où sont stockées les sauvegardes ?

`t5-gsc-utils` utilise le `fs_homepath` de T5 comme répertoire de travail.

T5 Zombies Resume crée :

```text
zombie_resume/
└── saves/
    ├── zombie_theater.json
    └── zombie_theater.backup.json
```

Chaque map utilise son propre fichier.

Exemple de structure logique :

```json
{
  "format": 1,
  "mod_version": "0.1.0",
  "map": "zombie_theater",
  "round": 16,
  "players": [
    {
      "guid": "PLAYER_GUID",
      "name": "Player",
      "score": 12540,
      "weapons": []
    }
  ]
}
```

Le fichier `.backup.json` sert à conserver la sauvegarde précédente lorsqu'une nouvelle sauvegarde est écrite.

---

# 🧪 Protocole de test recommandé

Pour éviter de perdre du temps sur une partie de 4 heures, commence avec **Kino der Toten et deux joueurs**.

### Test 1 — Chargement du script

1. Lance Kino.
2. Vérifie :

```text
[T5ZR] T5 Zombies Resume v0.1.0 loaded
```

3. Tape :

```text
zstatus
```

### Test 2 — Sauvegarde simple

1. Arrive à la manche 3.
2. Note les points de chaque joueur.
3. Note les armes et les munitions.
4. Termine la manche.
5. Vérifie la présence d'un message `[T5ZR] Saved ...`.
6. Vérifie que le JSON a été créé.

### Test 3 — Restart sans fermer le jeu

1. Tape :

```text
zresume
```

2. Vérifie :
   - la manche ;
   - les points ;
   - les armes ;
   - les munitions.

### Test 4 — Vraie reprise

1. Termine une manche.
2. Ferme complètement Plutonium.
3. Relance Plutonium.
4. Tape :

```text
set zr_autoresume 1
```

5. Invite le même ami.
6. Relance Kino.
7. Compare l'état restauré à l'état sauvegardé.

En cas de problème, conserve **l'erreur exacte de la console Plutonium**. Une erreur complète est beaucoup plus utile qu'un simple « ça marche pas ».

---

# 🔐 Steam, anti-cheat et sécurité

Ce projet n'a pas pour objectif de contourner un anti-cheat.

T5 Zombies Resume lui-même est un script GSC destiné à **Plutonium T5 Zombies en partie privée**.

Le projet ne contient pas de code destiné à :

- patcher `BlackOps.exe` ;
- patcher `BlackOpsMP.exe` ;
- modifier VAC ;
- désactiver un anti-cheat ;
- masquer une injection ;
- contourner une détection ;
- utiliser Cheat Engine ;
- modifier directement la mémoire du jeu depuis notre propre programme.

La dépendance `t5-gsc-utils` est un projet tiers séparé destiné à étendre le scripting Plutonium.

### Recommandation

Utilise ce projet uniquement avec **Plutonium T5 en Zombies privé**.

Ne copie pas les plugins expérimentaux dans les dossiers du client vanilla Steam et ne les utilise pas dans le multijoueur Steam classique.

Aucun mod tiers ne peut promettre un risque absolument nul sur une plateforme ou un compte. Le projet cherche simplement à rester dans le modèle de modding Plutonium plutôt que de développer des techniques de contournement.

---

# 🧠 Pourquoi ne pas sauvegarder directement toute la RAM ?

Un véritable save-state du processus devrait capturer énormément d'informations :

- entités ;
- zombies ;
- pointeurs ;
- threads GSC ;
- animations ;
- timers ;
- réseau ;
- RNG ;
- scripts spécifiques à la map ;
- état interne du moteur.

Même si un snapshot semblait fonctionner une fois, il serait extrêmement fragile et pourrait casser avec :

- une autre version du client ;
- un nombre différent de joueurs ;
- un changement d'adresse mémoire ;
- une update Plutonium ;
- un changement de map.

T5 Zombies Resume préfère donc sauvegarder des **données de gameplay de haut niveau** et reconstruire l'état proprement.

---

# 🗺️ Compatibilité des maps

La première cible est :

| Map | État prévu |
|---|---|
| Kino der Toten | 🧪 MVP / validation |
| Five | ⏳ prévu |
| Ascension | ⏳ prévu |
| Call of the Dead | ⏳ prévu |
| Shangri-La | ⏳ prévu |
| Moon | ⏳ prévu |
| Nacht der Untoten | ⏳ prévu |
| Verrückt | ⏳ prévu |
| Shi No Numa | ⏳ prévu |
| Der Riese | ⏳ prévu |

Le cœur du système doit rester générique, tandis que les états spéciaux seront probablement gérés par des adaptateurs propres à chaque map.

---

# 🛣️ Roadmap

## v0.1 — MVP

- [x] architecture host-only ;
- [x] fichier JSON ;
- [x] sauvegarde de secours ;
- [x] commandes host ;
- [x] map ;
- [x] manche ;
- [x] GUID joueurs ;
- [x] points ;
- [x] armes primaires ;
- [x] munitions ;
- [ ] validation complète en jeu.

## v0.2 — Joueurs

- [ ] perks ;
- [ ] grenades ;
- [ ] équipement spécial ;
- [ ] kills ;
- [ ] downs ;
- [ ] revives ;
- [ ] meilleur traitement des joueurs absents/nouveaux.

## v0.3 — Kino

- [ ] courant ;
- [ ] portes et débris ;
- [ ] Pack-a-Punch ;
- [ ] téléporteur ;
- [ ] Mystery Box ;
- [ ] pièges importants.

## v0.4 — Autres maps

- [ ] Five ;
- [ ] Ascension ;
- [ ] Call of the Dead ;
- [ ] Shangri-La ;
- [ ] Moon ;
- [ ] maps World at War incluses dans BO1.

## v0.5 — Qualité de vie

- [ ] plusieurs slots ;
- [ ] commande `zlist` ;
- [ ] commande `zdelete` ;
- [ ] métadonnées de sauvegarde ;
- [ ] migration automatique de format ;
- [ ] validation plus forte des JSON corrompus ;
- [ ] meilleure documentation d'installation.

---

# 👨‍💻 Développement avec Codex / IA

Le fichier :

```text
AGENTS.md
```

contient les instructions destinées aux agents de programmation comme Codex.

Avant de modifier le projet, un agent IA doit notamment :

1. préserver le modèle host-only ;
2. privilégier le GSC ;
3. ne pas introduire de contournement anti-cheat ;
4. vérifier les API contre des sources T5 réelles ;
5. ajouter les fonctionnalités progressivement ;
6. ne pas prétendre qu'une fonctionnalité est testée si elle ne l'est pas ;
7. garder la compatibilité des sauvegardes ou augmenter la version du format.

Une bonne boucle de développement est :

```text
GitHub
  ↓
Codex propose une modification
  ↓
Review du diff
  ↓
Test Kino en partie privée
  ↓
Console/logs
  ↓
Correction
  ↓
Commit
```

---

# 🐛 Signaler un bug

Pour qu'un bug soit exploitable, donne si possible :

- la map ;
- le nombre de joueurs ;
- la manche ;
- la commande utilisée ;
- le contenu pertinent du JSON ;
- la version de Plutonium ;
- la version de `t5-gsc-utils` ;
- l'erreur exacte de la console ;
- ce qui était attendu ;
- ce qui s'est réellement passé.

Exemple :

```text
Map: Kino
Players: 2
Saved round: 8
Command: zresume
Expected: spawn round 8 with MP40 + Ray Gun
Actual: round restored but second player's weapons reset
Console: [copier ici l'erreur complète]
```

---

# ❓ FAQ

### Mes amis doivent-ils installer le mod ?

Pour la v0.1, le but est **non**. Seul l'host installe le GSC et `t5-gsc-utils`.

### Puis-je quitter complètement le jeu ?

C'est précisément l'objectif du projet. La sauvegarde est écrite sur disque afin de survivre à la fermeture de Plutonium et du PC.

### Est-ce une sauvegarde exacte en plein milieu d'une manche ?

Non. Le système vise une reprise propre entre les manches.

### Puis-je reprendre avec une autre map ?

Non. Une sauvegarde appartient à la map sur laquelle elle a été créée.

### Puis-je reprendre avec d'autres amis ?

Le projet utilise les GUID pour retrouver les joueurs. Le comportement avec des joueurs différents devra être défini et testé plus précisément.

### Est-ce que les Easter Eggs sont sauvegardés ?

Pas actuellement.

### Est-ce que les perks sont sauvegardés ?

Pas dans la v0.1 stable prévue. Ils font partie de la prochaine étape.

### Est-ce garanti sans bug ?

Non. C'est actuellement un projet expérimental et explicitement assisté par IA.

### Est-ce officiel ?

Non. C'est un projet communautaire indépendant.

---

# 📁 Structure du dépôt

```text
T5-Zombies-Resume/
│
├── README.md
├── AGENTS.md
├── CHANGELOG.md
├── LICENSE
├── .gitignore
│
├── src/
│   └── zombie_resume.gsc
│
├── docs/
│   ├── save-format.md
│   └── troubleshooting.md
│
└── examples/
    └── kino-save.example.json
```

---

# 🙏 Remerciements et références

Ce projet s'appuie sur le travail public de la communauté BO1/Plutonium.

Références principales :

- **Plutonium T5 scripts**  
  https://github.com/plutoniummod/t5-scripts

- **t5-gsc-utils par alicealys**  
  https://github.com/alicealys/t5-gsc-utils

- **Documentation Plutonium**  
  https://www.plutonium.pw/docs/

Merci aux développeurs et modders qui ont documenté et maintenu l'écosystème T5.

---

# ⚖️ Licence

Le code spécifique à ce dépôt est publié sous licence **MIT**.

Voir :

```text
LICENSE
```

Les noms, marques, jeux et contenus appartenant à Activision/Treyarch restent la propriété de leurs détenteurs respectifs.

---

# ❤️ Objectif du projet

Le projet part d'une idée très simple :

> **Une partie Zombies entre amis ne devrait pas être perdue juste parce que tout le monde doit aller dormir.**

Si le prototype devient suffisamment fiable, l'objectif est d'arriver à une expérience aussi simple que :

```text
Jouer → autosave → quitter → revenir demain → continuer.
```

Et de garder le projet open source, compréhensible et améliorable avec l'aide de la communauté — humaine comme IA.
