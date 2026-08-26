# Contributing

Thanks for helping test or improve T5 Zombies Resume.

The project is intentionally conservative: a save/resume mod can appear to work while leaving the stock Zombies scripts in an inconsistent state. Changes should prefer a small, verifiable reconstruction over a large partial snapshot.

## Before opening a pull request

- Test on a private Plutonium T5 Zombies session.
- Keep the runtime host-only where possible.
- Reference the relevant stock BO1/T5 script when changing a gameplay subsystem.
- Add one subsystem or map adapter at a time.
- Do not mark a feature as stable until it has been tested after a full BO1/Plutonium restart.

## Player state

Player restoration must use `GetGuid()` only. Do not add a name-based fallback.

An unmatched player should be left untouched rather than receiving another player's state.

## Map/world state

World state should be implemented per map when the stock scripts require it.

When restoring a door, power system, teleporter or similar feature, account for its flags, triggers, visuals, paths, zone state and stock side effects. Do not save a single variable when the real subsystem depends on several pieces of state.

## Safety scope

Do not contribute:

- VAC/anti-cheat bypasses;
- process injection;
- Cheat Engine workflows;
- memory patches for vanilla Steam BO1;
- code intended to hide modifications from anti-cheat systems.

The project targets Plutonium T5 private Zombies sessions.

## Bug reports and logs

Useful reports contain:

- Plutonium T5 build;
- T5ZR version/save format;
- map and player count;
- exact steps to reproduce;
- expected and actual state;
- relevant `[T5ZR]` lines.

Before posting, remove GUIDs, IP addresses, account/session tokens, Windows usernames and other private information.

## AI-assisted development

AI tools are used in this repository for research, code generation and review. That does not replace runtime testing: generated changes should be treated as unverified until tested in-game.
