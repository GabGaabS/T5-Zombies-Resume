# v0.5.0-beta.2 validation checklist

## Install

1. Fermer BO1 et Plutonium.
2. Lancer `install.ps1`.
3. Vérifier `0.5.0-beta.2 / save format v6`.
4. Lancer Kino et confirmer que le GSC compile.

## Player / scoreboard test

Avant l'autosave, noter pour chaque joueur:

- points;
- kills;
- headshots;
- downs;
- revives;
- armes/munitions;
- perks.

Passer une manche et attendre le message de sauvegarde.

Après fermeture complète puis reprise, vérifier que le tableau coop affiche exactement les mêmes kills/headshots/downs/revives, puis que les nouveaux événements continuent à incrémenter ces valeurs normalement.

## Hellhound test

Le plus utile est de garder la session assez longtemps pour atteindre plusieurs manches spéciales.

À chaque autosave, `set zr_status 1` permet de relever:

```text
dog_active
dog_count
next_dog_round
```

Deux cas doivent marcher:

1. save sur une manche normale: la prochaine dog round doit arriver au numéro sauvegardé dans `next_dog_round`;
2. save juste au passage vers une dog round (`dog_active=1`): après reprise, cette manche doit être une vraie manche de hellhounds et ne doit pas être sautée.

Après une dog round reprise, les manches normales puis la prochaine dog round doivent continuer leur cycle.

## Kino regression

Vérifier aussi:

- power;
- au moins une porte/débris ouvert;
- perks;
- armes/munitions;
- GUID correct par joueur;
- téléporteur lié si testé.

## Expected status

```text
format=6
world=kino_v1
dogs_enabled=1
```

## Redaction

Avant de publier un log, retirer GUIDs complets, IPs, tokens et chemins personnels.
