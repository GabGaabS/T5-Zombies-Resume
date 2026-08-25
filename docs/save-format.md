# Save format v1

One JSON save is kept per map for the MVP.

```json
{
  "format_version": 1,
  "mod_version": "0.1.0",
  "map": "zombie_theater",
  "round": 8,
  "reason": "autosave",
  "player_count": 2,
  "players": [
    {
      "guid": "12345678",
      "name": "Player One",
      "score": 6240,
      "score_total": 15120,
      "current_weapon": "ray_gun_zm",
      "weapons": [
        {"name": "ray_gun_zm", "clip": 18, "stock": 132}
      ]
    }
  ]
}
```

`round` is the next round to start after loading. Players are matched by GUID first, with a unique-name fallback only for testing.

Loading is rejected if the format version differs, the map differs, the round is invalid, or player data is missing.
