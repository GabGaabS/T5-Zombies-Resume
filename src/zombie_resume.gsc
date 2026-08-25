// T5 Zombies Resume
// Host-side save/resume MVP for Plutonium T5 / BO1 Zombies.
// Requires alicealys/t5-gsc-utils on the host.
//
// v0.1 restores at a stable round boundary:
// - next round number
// - player points / total score
// - primary weapons
// - clip + reserve ammo
// - selected weapon when possible
//
// Not restored yet: perks, doors, power, box, traps, EE state, mid-round AI.

main()
{
    level.zr_format_version = 1;
    level.zr_mod_version = "0.1.0";
    level.zr_root = "zombie_resume";
    level.zr_save_dir = level.zr_root + "/saves";

    createDirectory(level.zr_root);
    createDirectory(level.zr_save_dir);

    // t5-gsc-utils server/host console commands.
    command::add("zsave", ::zr_cmd_save);
    command::add("zstatus", ::zr_cmd_status);
    command::add("zresume", ::zr_cmd_resume);

    level thread zr_watch_round_end();
    level thread zr_watch_players();
    level thread zr_prepare_resume();

    println("[T5ZR] T5 Zombies Resume v" + level.zr_mod_version + " loaded");
}

zr_current_map()
{
    return GetDvar("mapname");
}

zr_save_path()
{
    return level.zr_save_dir + "/" + zr_current_map() + ".json";
}

zr_backup_path()
{
    return level.zr_save_dir + "/" + zr_current_map() + ".backup.json";
}

zr_cmd_save(args)
{
    zr_save_game("manual");
}

zr_cmd_status(args)
{
    path = zr_save_path();
    round = -1;

    if (IsDefined(level.round_number))
    {
        round = level.round_number;
    }

    println("[T5ZR] version=" + level.zr_mod_version + " map=" + zr_current_map() + " round=" + round);
    println("[T5ZR] save=" + path + " exists=" + fileExists(path));
    println("[T5ZR] autoresume=" + GetDvar("zr_autoresume"));
}

zr_cmd_resume(args)
{
    path = zr_save_path();

    if (!fileExists(path))
    {
        println("[T5ZR] No save exists for this map: " + path);
        return;
    }

    SetDvar("zr_autoresume", "1");
    println("[T5ZR] Restarting map and resuming latest save...");
    command::execute("map_restart");
}

zr_watch_round_end()
{
    for (;;)
    {
        // Stock BO1 increments level.round_number immediately before this notify.
        // The stored value is therefore the NEXT round to play.
        level waittill("between_round_over");
        wait 0.05;
        zr_save_game("autosave");
    }
}

zr_save_game(reason)
{
    if (!IsDefined(level.round_number))
    {
        println("[T5ZR] Save skipped: round number is not initialized yet.");
        return false;
    }

    players = GetPlayers();
    player_data = [];

    for (i = 0; i < players.size; i++)
    {
        player_data[player_data.size] = zr_capture_player(players[i]);
    }

    save = json::create_map(
        "format_version", level.zr_format_version,
        "mod_version", level.zr_mod_version,
        "map", zr_current_map(),
        "round", level.round_number,
        "reason", reason,
        "player_count", players.size,
        "players", player_data
    );

    path = zr_save_path();
    backup = zr_backup_path();

    // Keep one known-good previous save when possible.
    if (fileExists(path))
    {
        writeFile(backup, readFile(path));
    }

    ok = json::dump(path, save, 2);

    if (ok)
    {
        println("[T5ZR] Saved " + zr_current_map() + " -> round " + level.round_number + " (" + reason + ")");
    }
    else
    {
        println("[T5ZR] ERROR: failed to write " + path);
    }

    return ok;
}

zr_capture_player(player)
{
    weapons = player GetWeaponsListPrimaries();
    weapon_data = [];

    for (i = 0; i < weapons.size; i++)
    {
        weapon = weapons[i];
        weapon_data[weapon_data.size] = json::create_map(
            "name", weapon,
            "clip", player GetWeaponAmmoClip(weapon),
            "stock", player GetWeaponAmmoStock(weapon)
        );
    }

    return json::create_map(
        "guid", "" + player GetGuid(),
        "name", player.name,
        "score", zr_defined_int(player.score, 0),
        "score_total", zr_defined_int(player.score_total, zr_defined_int(player.score, 0)),
        "current_weapon", player GetCurrentWeapon(),
        "weapons", weapon_data
    );
}

zr_defined_int(value, fallback)
{
    if (!IsDefined(value))
    {
        return fallback;
    }

    return Int(value);
}

zr_prepare_resume()
{
    if (GetDvarInt("zr_autoresume") != 1)
    {
        return;
    }

    path = zr_save_path();

    if (!fileExists(path))
    {
        println("[T5ZR] Resume requested but save does not exist: " + path);
        SetDvar("zr_autoresume", "0");
        return;
    }

    raw = readFile(path);
    save = json::parse(raw);

    if (!zr_validate_save(save))
    {
        SetDvar("zr_autoresume", "0");
        return;
    }

    level.zr_pending_save = save;

    // Wait until stock Zombies creates the round variable, then override it as
    // early as possible. This is the critical timing point to validate in game.
    while (!IsDefined(level.round_number))
    {
        wait 0.01;
    }

    level.round_number = Int(save["round"]);
    println("[T5ZR] Prepared resume at round " + level.round_number);

    // Consume once so a later restart cannot accidentally re-apply the save.
    SetDvar("zr_autoresume", "0");
}

zr_validate_save(save)
{
    if (!IsDefined(save) || !IsDefined(save["format_version"]))
    {
        println("[T5ZR] Resume aborted: invalid save file.");
        return false;
    }

    if (!IsDefined(save["map"]) || save["map"] != zr_current_map())
    {
        println("[T5ZR] Resume aborted: save belongs to another map.");
        return false;
    }

    if (Int(save["format_version"]) != level.zr_format_version)
    {
        println("[T5ZR] Resume aborted: unsupported save format " + save["format_version"]);
        return false;
    }

    if (!IsDefined(save["round"]) || Int(save["round"]) < 1)
    {
        println("[T5ZR] Resume aborted: invalid round value.");
        return false;
    }

    if (!IsDefined(save["players"]))
    {
        println("[T5ZR] Resume aborted: missing player data.");
        return false;
    }

    return true;
}

zr_watch_players()
{
    for (;;)
    {
        level waittill("connected", player);
        player thread zr_restore_on_spawn();
    }
}

zr_restore_on_spawn()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        if (!IsDefined(level.zr_pending_save))
        {
            continue;
        }

        // Let stock loadout initialization finish before replacing primaries.
        wait 0.10;

        saved_player = zr_find_saved_player(level.zr_pending_save["players"], self);

        if (!IsDefined(saved_player))
        {
            println("[T5ZR] No saved state for " + self.name + " (GUID " + self GetGuid() + ")");
            continue;
        }

        self zr_restore_player(saved_player);
    }
}

zr_find_saved_player(saved_players, player)
{
    guid = "" + player GetGuid();

    for (i = 0; i < saved_players.size; i++)
    {
        if (saved_players[i]["guid"] == guid)
        {
            return saved_players[i];
        }
    }

    // Testing fallback only. Reject ambiguous duplicate names.
    matches = 0;
    candidate = undefined;

    for (i = 0; i < saved_players.size; i++)
    {
        if (saved_players[i]["name"] == player.name)
        {
            matches++;
            candidate = saved_players[i];
        }
    }

    if (matches == 1)
    {
        println("[T5ZR] GUID changed; matched " + player.name + " by unique name.");
        return candidate;
    }

    return undefined;
}

zr_restore_player(saved)
{
    self.score = Int(saved["score"]);
    self.score_total = Int(saved["score_total"]);
    self.old_score = self.score;

    // Avoid #include of stock scripts: current Plutonium T5 can resolve stock
    // GSC functions dynamically. If unavailable, points still restore and the
    // HUD will refresh on the next normal score update.
    score_hud_fn = getFunction("maps/_zombiemode_score", "set_player_score_hud");
    if (IsDefined(score_hud_fn))
    {
        self [[score_hud_fn]](true);
    }

    current_primaries = self GetWeaponsListPrimaries();
    for (i = 0; i < current_primaries.size; i++)
    {
        self TakeWeapon(current_primaries[i]);
    }

    saved_weapons = saved["weapons"];
    for (i = 0; i < saved_weapons.size; i++)
    {
        weapon = saved_weapons[i]["name"];
        self GiveWeapon(weapon);
        self SetWeaponAmmoClip(weapon, Int(saved_weapons[i]["clip"]));
        self SetWeaponAmmoStock(weapon, Int(saved_weapons[i]["stock"]));
    }

    current = saved["current_weapon"];
    if (IsDefined(current) && current != "none" && self HasWeapon(current))
    {
        self SwitchToWeapon(current);
    }

    self iPrintLnBold("^2T5 Zombies Resume:^7 partie restauree (round " + level.round_number + ")");
    println("[T5ZR] Restored " + self.name + " score=" + self.score + " primaries=" + saved_weapons.size);
}
