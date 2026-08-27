// T5 Zombies Resume
// Host-only save/resume for Plutonium T5 / BO1 Zombies.
// Native GSC only: no external DLL.
//
// v0.7.0-beta.1 / save format v7
// - strict player matching by engine GetGuid()
// - round, points, primary weapons, ammo and selected weapon
// - Zombies perks restored through stock _zombiemode_perks::give_perk
// - scoreboard network fields + round stats (kills/headshots/downs/revives)
// - dog-round scheduler state so resumed special rounds are not skipped
// - Kino adapter: power, permanent doors/debris and fully-linked teleporter
// - each saved slot/player is restored only once per resumed session
// - Bowie/melee + tactical grenade state (including cymbal monkeys)
// - optional corner HUD: round time, total run time and zombies remaining
// - compact autosave toast at the top-center of the screen
//
// Saves are intentionally made at round boundaries. Mid-round zombies, active
// powerups, temporary trap/cooldown timers and RNG are not snapshots.

zr_current_map()
{
    return GetDvar("mapname");
}

zr_int_or(value, fallback)
{
    if (!IsDefined(value))
    {
        return fallback;
    }

    return Int(value);
}

zr_bool_string(value)
{
    if (value)
    {
        return "1";
    }

    return "0";
}

zr_show_message(message)
{
    players = GetPlayers();

    for (i = 0; i < players.size; i++)
    {
        players[i] iPrintLnBold(message);
    }
}


zr_pad2(value)
{
    value = Int(value);

    if (value < 10)
    {
        return "0" + value;
    }

    return "" + value;
}

zr_format_time(seconds)
{
    seconds = Int(seconds);

    if (seconds < 0)
    {
        seconds = 0;
    }

    hours = Int(seconds / 3600);
    minutes = Int((seconds - (hours * 3600)) / 60);
    secs = seconds - (hours * 3600) - (minutes * 60);

    if (hours > 0)
    {
        return "" + hours + ":" + zr_pad2(minutes) + ":" + zr_pad2(secs);
    }

    return zr_pad2(minutes) + ":" + zr_pad2(secs);
}

zr_total_elapsed_seconds()
{
    base_seconds = zr_int_or(level.zr_total_time_base_seconds, 0);

    if (!IsDefined(level.zr_session_start_time) || level.zr_session_start_time <= 0)
    {
        if (IsDefined(level.round_start_time) && level.round_start_time > 0)
        {
            level.zr_session_start_time = level.round_start_time;
        }
        else
        {
            return base_seconds;
        }
    }

    elapsed = Int((GetTime() - level.zr_session_start_time) / 1000);

    if (elapsed < 0)
    {
        elapsed = 0;
    }

    return base_seconds + elapsed;
}

zr_round_elapsed_seconds()
{
    if (!IsDefined(level.round_start_time) || level.round_start_time <= 0)
    {
        return 0;
    }

    elapsed = Int((GetTime() - level.round_start_time) / 1000);

    if (elapsed < 0)
    {
        elapsed = 0;
    }

    return elapsed;
}

zr_zombies_remaining()
{
    pending = 0;

    if (IsDefined(level.zombie_total))
    {
        pending = Int(level.zombie_total);
    }

    active = maps\_zombiemode_utility::get_enemy_count();
    remaining = pending + active;

    if (remaining < 0)
    {
        remaining = 0;
    }

    return remaining;
}

zr_save_toast_player(message)
{
    self endon("disconnect");

    hud = NewClientHudElem(self);
    hud.horzAlign = "center";
    hud.vertAlign = "top";
    hud.alignX = "center";
    hud.alignY = "top";
    hud.x = 0;
    hud.y = 18;
    hud.foreground = true;
    hud.sort = 100;
    hud.font = "default";
    hud.fontScale = 0.8;
    hud.alpha = 1;
    hud SetText(message);

    wait 2.0;
    hud FadeOverTime(0.25);
    hud.alpha = 0;
    wait 0.25;
    hud Destroy();
}

zr_show_save_toast(message)
{
    players = GetPlayers();

    for (i = 0; i < players.size; i++)
    {
        players[i] thread zr_save_toast_player(message);
    }
}

zr_create_corner_hud(horz_align, vert_align, align_x, align_y, x, y)
{
    hud = NewClientHudElem(self);
    hud.horzAlign = horz_align;
    hud.vertAlign = vert_align;
    hud.alignX = align_x;
    hud.alignY = align_y;
    hud.x = x;
    hud.y = y;
    hud.foreground = true;
    hud.sort = 90;
    hud.font = "default";
    hud.fontScale = 1.0;
    hud.alpha = 0;

    return hud;
}

zr_hud_loop()
{
    self endon("disconnect");

    round_hud = self zr_create_corner_hud("left", "top", "left", "top", 12, 12);
    total_hud = self zr_create_corner_hud("right", "top", "right", "top", -12, 12);
    zombies_hud = self zr_create_corner_hud("right", "bottom", "right", "bottom", -12, -70);

    for (;;)
    {
        hud_enabled = GetDvarInt("zr_hud") == 1;

        if (hud_enabled && GetDvarInt("zr_hud_round_time") == 1)
        {
            round_hud.alpha = 1;
            round_hud SetText("Manche: " + zr_format_time(zr_round_elapsed_seconds()));
        }
        else
        {
            round_hud.alpha = 0;
        }

        if (hud_enabled && GetDvarInt("zr_hud_total_time") == 1)
        {
            total_hud.alpha = 1;
            total_hud SetText("Total: " + zr_format_time(zr_total_elapsed_seconds()));
        }
        else
        {
            total_hud.alpha = 0;
        }

        if (hud_enabled && GetDvarInt("zr_hud_zombies") == 1)
        {
            zombies_hud.alpha = 1;
            zombies_hud SetText("Zombies: " + zr_zombies_remaining());
        }
        else
        {
            zombies_hud.alpha = 0;
        }

        wait 0.25;
    }
}

zr_store(key, value)
{
    // install.ps1 registers zr_sv_* through `seta`, giving the custom dvars
    // the archive flag. SetDvar changes the live archived value; SetSavedDvar
    // is kept as the native T5 persistence path validated during development.
    SetDvar(key, value);
    SetSavedDvar(key, value);
}

zr_flag_is_set(flag_name)
{
    return common_scripts\utility::flag(flag_name);
}

zr_set_flag(flag_name)
{
    if (!common_scripts\utility::flag(flag_name))
    {
        common_scripts\utility::flag_set(flag_name);
    }
}

zr_player_guid(player)
{
    guid = player GetGuid();

    if (!IsDefined(guid))
    {
        return "";
    }

    return "" + guid;
}

zr_player_key(slot, suffix)
{
    return "zr_sv_p" + slot + "_" + suffix;
}

zr_weapon_key(slot, weapon_slot, suffix)
{
    return "zr_sv_p" + slot + "_w" + weapon_slot + "_" + suffix;
}

zr_perk_key(slot, perk_slot)
{
    return "zr_sv_p" + slot + "_perk" + perk_slot;
}

zr_clear_saved_weapon(slot, weapon_slot)
{
    zr_store(zr_weapon_key(slot, weapon_slot, "name"), "");
    zr_store(zr_weapon_key(slot, weapon_slot, "clip"), "0");
    zr_store(zr_weapon_key(slot, weapon_slot, "stock"), "0");
}

zr_clear_saved_perks(slot)
{
    zr_store(zr_player_key(slot, "perk_count"), "0");

    for (p = 0; p < 16; p++)
    {
        zr_store(zr_perk_key(slot, p), "");
    }
}

zr_clear_saved_player(slot)
{
    zr_store(zr_player_key(slot, "guid"), "");
    zr_store(zr_player_key(slot, "name"), "");
    zr_store(zr_player_key(slot, "score"), "0");
    zr_store(zr_player_key(slot, "score_total"), "0");
    zr_store(zr_player_key(slot, "current_weapon"), "none");
    zr_store(zr_player_key(slot, "weapon_count"), "0");
    zr_store(zr_player_key(slot, "melee_weapon"), "");
    zr_store(zr_player_key(slot, "tactical_weapon"), "");
    zr_store(zr_player_key(slot, "tactical_clip"), "0");
    zr_store(zr_player_key(slot, "tactical_stock"), "0");

    zr_store(zr_player_key(slot, "kills"), "0");
    zr_store(zr_player_key(slot, "kill_tracker"), "0");
    zr_store(zr_player_key(slot, "headshots"), "0");
    zr_store(zr_player_key(slot, "downs"), "0");
    zr_store(zr_player_key(slot, "revives"), "0");
    zr_store(zr_player_key(slot, "zombie_gibs"), "0");
    zr_store(zr_player_key(slot, "perks_stat"), "0");

    zr_clear_saved_perks(slot);

    for (w = 0; w < 3; w++)
    {
        zr_clear_saved_weapon(slot, w);
    }
}

zr_clear_world_save()
{
    zr_store("zr_sv_world_adapter", "none");
    zr_store("zr_sv_kino_power", "0");
    zr_store("zr_sv_kino_magic_box_foyer1", "0");
    zr_store("zr_sv_kino_magic_box_crematorium1", "0");
    zr_store("zr_sv_kino_vip_to_dining", "0");
    zr_store("zr_sv_kino_magic_box_alleyway1", "0");
    zr_store("zr_sv_kino_dining_to_dressing", "0");
    zr_store("zr_sv_kino_magic_box_dressing1", "0");
    zr_store("zr_sv_kino_magic_box_west_balcony2", "0");
    zr_store("zr_sv_kino_magic_box_west_balcony1", "0");
    zr_store("zr_sv_kino_curtains_done", "0");
    zr_store("zr_sv_kino_teleporter_linked", "0");
}

zr_clear_round_scheduler_save()
{
    zr_store("zr_sv_dog_rounds_enabled", "0");
    zr_store("zr_sv_dog_round_active", "0");
    zr_store("zr_sv_dog_round_count", "0");
    zr_store("zr_sv_next_dog_round", "0");
}

zr_clear_save()
{
    zr_store("zr_sv_valid", "0");
    zr_store("zr_sv_format", "7");
    zr_store("zr_sv_mod_version", level.zr_mod_version);
    zr_store("zr_sv_map", "");
    zr_store("zr_sv_round", "0");
    zr_store("zr_sv_reason", "cleared");
    zr_store("zr_sv_player_count", "0");
    zr_store("zr_sv_total_time_seconds", "0");
    zr_clear_round_scheduler_save();
    zr_clear_world_save();

    for (i = 0; i < 4; i++)
    {
        zr_clear_saved_player(i);
    }

    println("[T5ZR] Save cleared.");
    zr_show_message("^2T5ZR:^7 sauvegarde effacee");
}

zr_save_perk_if_present(slot, player, perk, perk_count)
{
    if (perk_count >= 16)
    {
        return perk_count;
    }

    if (player HasPerk(perk))
    {
        zr_store(zr_perk_key(slot, perk_count), perk);
        return perk_count + 1;
    }

    return perk_count;
}

zr_save_player_perks(slot, player)
{
    perk_count = 0;

    perk_count = zr_save_perk_if_present(slot, player, "specialty_armorvest", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_quickrevive", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_fastreload", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_rof", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_longersprint", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_flakjacket", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_deadshot", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_additionalprimaryweapon", perk_count);

    perk_count = zr_save_perk_if_present(slot, player, "specialty_armorvest_upgrade", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_quickrevive_upgrade", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_fastreload_upgrade", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_rof_upgrade", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_longersprint_upgrade", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_flakjacket_upgrade", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_deadshot_upgrade", perk_count);
    perk_count = zr_save_perk_if_present(slot, player, "specialty_additionalprimaryweapon_upgrade", perk_count);

    zr_store(zr_player_key(slot, "perk_count"), "" + perk_count);

    for (p = perk_count; p < 16; p++)
    {
        zr_store(zr_perk_key(slot, p), "");
    }
}

zr_save_player_stats(slot, player)
{
    stats_kills = 0;
    stats_downs = 0;
    stats_revives = 0;
    stats_headshots = 0;
    zombie_gibs = 0;
    perks_stat = 0;

    if (IsDefined(player.stats))
    {
        stats_kills = zr_int_or(player.stats["kills"], 0);
        stats_downs = zr_int_or(player.stats["downs"], 0);
        stats_revives = zr_int_or(player.stats["revives"], 0);
        stats_headshots = zr_int_or(player.stats["headshots"], 0);
        zombie_gibs = zr_int_or(player.stats["zombie_gibs"], 0);
        perks_stat = zr_int_or(player.stats["perks"], 0);
    }

    // BO1's coop scoreboard reads the networked player fields, while scoring
    // and leaderboard bookkeeping also keep stats[] / kill_tracker mirrors.
    kill_tracker = zr_int_or(player.kill_tracker, stats_kills);
    kills = zr_int_or(player.kills, kill_tracker);
    headshots = zr_int_or(player.headshots, stats_headshots);
    downs = zr_int_or(player.downs, stats_downs);
    revives = zr_int_or(player.revives, stats_revives);

    zr_store(zr_player_key(slot, "kills"), "" + kills);
    zr_store(zr_player_key(slot, "kill_tracker"), "" + kill_tracker);
    zr_store(zr_player_key(slot, "headshots"), "" + headshots);
    zr_store(zr_player_key(slot, "downs"), "" + downs);
    zr_store(zr_player_key(slot, "revives"), "" + revives);
    zr_store(zr_player_key(slot, "zombie_gibs"), "" + zombie_gibs);
    zr_store(zr_player_key(slot, "perks_stat"), "" + perks_stat);
}


zr_save_player_offhand(slot, player)
{
    melee_weapon = "";

    if (IsDefined(player.current_melee_weapon))
    {
        melee_weapon = player.current_melee_weapon;
    }

    if (player HasWeapon("bowie_knife_zm"))
    {
        melee_weapon = "bowie_knife_zm";
    }

    tactical_weapon = "";

    if (IsDefined(player.current_tactical_grenade))
    {
        tactical_weapon = player.current_tactical_grenade;
    }

    zr_store(zr_player_key(slot, "melee_weapon"), melee_weapon);
    zr_store(zr_player_key(slot, "tactical_weapon"), tactical_weapon);

    if (tactical_weapon != "" && tactical_weapon != "none" && player HasWeapon(tactical_weapon))
    {
        zr_store(zr_player_key(slot, "tactical_clip"), "" + player GetWeaponAmmoClip(tactical_weapon));
        zr_store(zr_player_key(slot, "tactical_stock"), "" + player GetWeaponAmmoStock(tactical_weapon));
    }
    else
    {
        zr_store(zr_player_key(slot, "tactical_clip"), "0");
        zr_store(zr_player_key(slot, "tactical_stock"), "0");
    }
}

zr_save_player(slot, player)
{
    guid = zr_player_guid(player);
    score = zr_int_or(player.score, 0);
    total = zr_int_or(player.score_total, score);
    weapons = player GetWeaponsListPrimaries();
    weapon_count = weapons.size;

    if (weapon_count > 3)
    {
        weapon_count = 3;
    }

    zr_store(zr_player_key(slot, "guid"), guid);
    zr_store(zr_player_key(slot, "name"), player.name);
    zr_store(zr_player_key(slot, "score"), "" + score);
    zr_store(zr_player_key(slot, "score_total"), "" + total);
    zr_store(zr_player_key(slot, "current_weapon"), player GetCurrentWeapon());
    zr_store(zr_player_key(slot, "weapon_count"), "" + weapon_count);

    zr_save_player_stats(slot, player);
    zr_save_player_perks(slot, player);
    zr_save_player_offhand(slot, player);

    if (guid == "" || guid == "0")
    {
        println("[T5ZR] WARNING: player slot " + slot + " has no usable GUID; it will not be auto-restored.");
    }

    for (w = 0; w < 3; w++)
    {
        if (w < weapon_count)
        {
            weapon = weapons[w];
            zr_store(zr_weapon_key(slot, w, "name"), weapon);
            zr_store(zr_weapon_key(slot, w, "clip"), "" + player GetWeaponAmmoClip(weapon));
            zr_store(zr_weapon_key(slot, w, "stock"), "" + player GetWeaponAmmoStock(weapon));
        }
        else
        {
            zr_clear_saved_weapon(slot, w);
        }
    }
}

zr_save_kino_world()
{
    zr_store("zr_sv_world_adapter", "kino_v1");
    zr_store("zr_sv_kino_power", zr_bool_string(zr_flag_is_set("power_on")));

    // Kino's permanent route flags come directly from theater_zone_init().
    zr_store("zr_sv_kino_magic_box_foyer1", zr_bool_string(zr_flag_is_set("magic_box_foyer1")));
    zr_store("zr_sv_kino_magic_box_crematorium1", zr_bool_string(zr_flag_is_set("magic_box_crematorium1")));
    zr_store("zr_sv_kino_vip_to_dining", zr_bool_string(zr_flag_is_set("vip_to_dining")));
    zr_store("zr_sv_kino_magic_box_alleyway1", zr_bool_string(zr_flag_is_set("magic_box_alleyway1")));
    zr_store("zr_sv_kino_dining_to_dressing", zr_bool_string(zr_flag_is_set("dining_to_dressing")));
    zr_store("zr_sv_kino_magic_box_dressing1", zr_bool_string(zr_flag_is_set("magic_box_dressing1")));
    zr_store("zr_sv_kino_magic_box_west_balcony2", zr_bool_string(zr_flag_is_set("magic_box_west_balcony2")));
    zr_store("zr_sv_kino_magic_box_west_balcony1", zr_bool_string(zr_flag_is_set("magic_box_west_balcony1")));
    zr_store("zr_sv_kino_curtains_done", zr_bool_string(zr_flag_is_set("curtains_done")));

    // Only preserve the fully-linked state. A half-completed core/pad link is
    // intentionally reset because its UI hints are driven by transient threads.
    zr_store("zr_sv_kino_teleporter_linked", zr_bool_string(zr_flag_is_set("teleporter_linked")));
}

zr_save_world()
{
    zr_clear_world_save();

    if (zr_current_map() == "zombie_theater")
    {
        zr_save_kino_world();
    }
}

zr_save_round_scheduler()
{
    zr_clear_round_scheduler_save();

    if (!IsDefined(level.dog_rounds_enabled) || !level.dog_rounds_enabled)
    {
        return;
    }

    zr_store("zr_sv_dog_rounds_enabled", "1");
    zr_store("zr_sv_dog_round_count", "" + zr_int_or(level.dog_round_count, 1));
    zr_store("zr_sv_next_dog_round", "" + zr_int_or(level.next_dog_round, 0));
    zr_store("zr_sv_dog_round_active", zr_bool_string(zr_flag_is_set("dog_round")));
}

zr_save_game(reason)
{
    if (!IsDefined(level.round_number))
    {
        println("[T5ZR] Save skipped: round number is not initialized yet.");
        zr_show_message("^1T5ZR:^7 sauvegarde impossible, manche non initialisee");
        return;
    }

    players = GetPlayers();
    player_count = players.size;

    if (player_count > 4)
    {
        player_count = 4;
    }

    zr_store("zr_sv_valid", "0");
    zr_store("zr_sv_format", "7");
    zr_store("zr_sv_mod_version", level.zr_mod_version);
    zr_store("zr_sv_map", zr_current_map());
    zr_store("zr_sv_round", "" + level.round_number);
    zr_store("zr_sv_reason", reason);
    zr_store("zr_sv_player_count", "" + player_count);
    zr_store("zr_sv_total_time_seconds", "" + zr_total_elapsed_seconds());

    zr_save_round_scheduler();
    zr_save_world();

    for (i = 0; i < 4; i++)
    {
        if (i < player_count)
        {
            zr_save_player(i, players[i]);
        }
        else
        {
            zr_clear_saved_player(i);
        }
    }

    zr_store("zr_sv_valid", "1");

    println("[T5ZR] Saved " + zr_current_map() + " -> round " + level.round_number + " (" + reason + "), players=" + player_count + ", world=" + GetDvar("zr_sv_world_adapter"));
    zr_show_save_toast("^2T5ZR:^7 sauvegarde OK - prochaine manche " + level.round_number);
}

zr_watch_round_number()
{
    while (!IsDefined(level.round_number))
    {
        wait 0.05;
    }

    last_round = level.round_number;
    println("[T5ZR] Round watcher armed at round " + last_round);

    for (;;)
    {
        wait 0.10;

        if (!IsDefined(level.round_number))
        {
            continue;
        }

        current_round = level.round_number;

        if (current_round != last_round)
        {
            advanced = current_round > last_round;
            last_round = current_round;

            if (advanced && !level.zr_suppress_autosave)
            {
                wait 0.25;
                zr_save_game("autosave");
            }
        }
    }
}

zr_print_status()
{
    println("[T5ZR] version=" + level.zr_mod_version + " map=" + zr_current_map() + " round=" + level.round_number);
    println("[T5ZR] saved_valid=" + GetDvar("zr_sv_valid") + " format=" + GetDvar("zr_sv_format") + " saved_map=" + GetDvar("zr_sv_map") + " saved_round=" + GetDvar("zr_sv_round"));
    println("[T5ZR] saved_players=" + GetDvar("zr_sv_player_count") + " world=" + GetDvar("zr_sv_world_adapter") + " resume_request=" + GetDvar("zr_resume"));
    println("[T5ZR] dogs_enabled=" + GetDvar("zr_sv_dog_rounds_enabled") + " dog_active=" + GetDvar("zr_sv_dog_round_active") + " dog_count=" + GetDvar("zr_sv_dog_round_count") + " next_dog_round=" + GetDvar("zr_sv_next_dog_round"));
    println("[T5ZR] total_time=" + zr_format_time(zr_total_elapsed_seconds()) + " hud=" + GetDvar("zr_hud"));

    zr_show_message("^2T5ZR:^7 actif - manche " + level.round_number + " / save " + GetDvar("zr_sv_round"));
}

zr_watch_controls()
{
    for (;;)
    {
        if (GetDvarInt("zr_save_now") == 1)
        {
            SetDvar("zr_save_now", "0");
            zr_save_game("manual");
        }

        if (GetDvarInt("zr_status") == 1)
        {
            SetDvar("zr_status", "0");
            zr_print_status();
        }

        if (GetDvarInt("zr_clear_save") == 1)
        {
            SetDvar("zr_clear_save", "0");
            zr_clear_save();
        }

        wait 0.10;
    }
}

zr_find_saved_slot(player)
{
    guid = zr_player_guid(player);

    if (guid == "" || guid == "0")
    {
        return -1;
    }

    player_count = GetDvarInt("zr_sv_player_count");

    if (player_count > 4)
    {
        player_count = 4;
    }

    for (i = 0; i < player_count; i++)
    {
        if (level.zr_slot_claimed[i])
        {
            continue;
        }

        saved_guid = GetDvar(zr_player_key(i, "guid"));

        if (saved_guid != "" && saved_guid == guid)
        {
            return i;
        }
    }

    return -1;
}

zr_restore_player_perks(slot)
{
    perk_count = GetDvarInt(zr_player_key(slot, "perk_count"));

    if (perk_count < 0)
    {
        perk_count = 0;
    }

    if (perk_count > 16)
    {
        perk_count = 16;
    }

    if (!IsDefined(self.num_perks))
    {
        self.num_perks = 0;
    }

    restored = 0;

    for (p = 0; p < perk_count; p++)
    {
        perk = GetDvar(zr_perk_key(slot, p));

        if (perk == "" || self HasPerk(perk))
        {
            continue;
        }

        self maps\_zombiemode_perks::give_perk(perk, false);
        restored++;
        wait 0.05;
    }

    println("[T5ZR] Restored " + restored + " perk(s) for " + self.name + ".");
}

zr_restore_player_stats(slot)
{
    if (!IsDefined(self.stats))
    {
        self.stats = [];
    }

    saved_kills = GetDvarInt(zr_player_key(slot, "kills"));
    saved_kill_tracker = GetDvarInt(zr_player_key(slot, "kill_tracker"));
    saved_headshots = GetDvarInt(zr_player_key(slot, "headshots"));
    saved_downs = GetDvarInt(zr_player_key(slot, "downs"));
    saved_revives = GetDvarInt(zr_player_key(slot, "revives"));

    // Restore the fields used by the in-game coop scoreboard.
    self.kills = saved_kills;
    self.headshots = saved_headshots;
    self.downs = saved_downs;
    self.revives = saved_revives;

    // Restore the mirrors used by Zombies scoring / match stat bookkeeping.
    self.kill_tracker = saved_kill_tracker;
    if (self.kill_tracker < 0)
    {
        self.kill_tracker = 0;
    }

    self.stats["kills"] = self.kill_tracker;
    self.stats["score"] = GetDvarInt(zr_player_key(slot, "score_total"));
    self.stats["downs"] = saved_downs;
    self.stats["revives"] = saved_revives;
    self.stats["perks"] = GetDvarInt(zr_player_key(slot, "perks_stat"));
    self.stats["headshots"] = saved_headshots;
    self.stats["zombie_gibs"] = GetDvarInt(zr_player_key(slot, "zombie_gibs"));

    // Stock callback/laststand code mirrors downs into this dvar.
    downs_dvar = "player" + self GetEntityNumber() + "downs";
    SetDvar(downs_dvar, "" + self.downs);
}


zr_restore_player_offhand(slot)
{
    melee_weapon = GetDvar(zr_player_key(slot, "melee_weapon"));

    if (melee_weapon != "" && melee_weapon != "none")
    {
        if (!self HasWeapon(melee_weapon))
        {
            self GiveWeapon(melee_weapon);
        }

        self maps\_zombiemode_utility::set_player_melee_weapon(melee_weapon);

        if (melee_weapon == "bowie_knife_zm")
        {
            if (self HasWeapon("knife_zm"))
            {
                self TakeWeapon("knife_zm");
            }

            self._bowie_zm_equipped = 1;
        }
    }

    tactical_weapon = GetDvar(zr_player_key(slot, "tactical_weapon"));

    if (tactical_weapon == "" || tactical_weapon == "none")
    {
        return;
    }

    if (tactical_weapon == "zombie_cymbal_monkey")
    {
        self maps\_zombiemode_weap_cymbal_monkey::player_give_cymbal_monkey();
    }
    else
    {
        if (!self HasWeapon(tactical_weapon))
        {
            self GiveWeapon(tactical_weapon);
        }

        self maps\_zombiemode_utility::set_player_tactical_grenade(tactical_weapon);
    }

    self SetWeaponAmmoClip(tactical_weapon, GetDvarInt(zr_player_key(slot, "tactical_clip")));
    self SetWeaponAmmoStock(tactical_weapon, GetDvarInt(zr_player_key(slot, "tactical_stock")));
}

zr_restore_player_slot(slot)
{
    level.zr_slot_claimed[slot] = true;
    self.zr_restore_applied = true;

    // Mule Kick needs to exist before a possible third primary is rebuilt.
    self zr_restore_player_perks(slot);

    self.score = GetDvarInt(zr_player_key(slot, "score"));
    self.score_total = GetDvarInt(zr_player_key(slot, "score_total"));
    self.old_score = self.score;

    current_primaries = self GetWeaponsListPrimaries();

    for (i = 0; i < current_primaries.size; i++)
    {
        self TakeWeapon(current_primaries[i]);
    }

    weapon_count = GetDvarInt(zr_player_key(slot, "weapon_count"));

    if (weapon_count > 3)
    {
        weapon_count = 3;
    }

    for (i = 0; i < weapon_count; i++)
    {
        weapon = GetDvar(zr_weapon_key(slot, i, "name"));

        if (weapon == "" || weapon == "none")
        {
            continue;
        }

        self GiveWeapon(weapon);
        self SetWeaponAmmoClip(weapon, GetDvarInt(zr_weapon_key(slot, i, "clip")));
        self SetWeaponAmmoStock(weapon, GetDvarInt(zr_weapon_key(slot, i, "stock")));
    }

    self zr_restore_player_offhand(slot);

    current = GetDvar(zr_player_key(slot, "current_weapon"));

    if (current != "" && current != "none" && self HasWeapon(current))
    {
        self SwitchToWeapon(current);
    }

    // give_perk updates the perk-consumption stat, so restore the exact saved
    // scoreboard values only after all perks have been rebuilt.
    self zr_restore_player_stats(slot);

    self iPrintLnBold("^2T5ZR:^7 partie restauree - manche " + level.round_number);
    println("[T5ZR] Restored player " + self.name + " from save slot " + slot + ": kills=" + self.kills + ", headshots=" + self.headshots + ", downs=" + self.downs + ", revives=" + self.revives + ", perks=" + self.num_perks + ".");
}

zr_entity_uses_flag(entity, flag_name)
{
    if (!IsDefined(entity) || !IsDefined(entity.script_flag))
    {
        return false;
    }

    tokens = StrTok(entity.script_flag, ",");

    for (i = 0; i < tokens.size; i++)
    {
        if (tokens[i] == flag_name)
        {
            return true;
        }
    }

    return false;
}

zr_force_open_door(trigger)
{
    if (!IsDefined(trigger))
    {
        return;
    }

    if (IsDefined(trigger._door_open) && trigger._door_open)
    {
        return;
    }

    // Stop the normal purchase loop, move the classified door pieces using the
    // stock blocker helper, disable both-side triggers, then run the stock
    // door_opened bookkeeping (script flags / paths / zone notifications).
    trigger notify("kill_door_think");

    if (IsDefined(trigger.doors))
    {
        for (i = 0; i < trigger.doors.size; i++)
        {
            trigger.doors[i] maps\_zombiemode_blockers::door_activate(0.05);
        }
    }

    if (IsDefined(trigger.target))
    {
        all_trigs = GetEntArray(trigger.target, "target");

        for (i = 0; i < all_trigs.size; i++)
        {
            all_trigs[i] common_scripts\utility::trigger_off();
        }
    }

    trigger maps\_zombiemode_blockers::door_opened();
    trigger._door_open = true;
    trigger notify("door_opened");
}

zr_force_clear_debris(trigger)
{
    if (!IsDefined(trigger) || !IsDefined(trigger.target))
    {
        return;
    }

    if (IsDefined(trigger.script_flag))
    {
        tokens = StrTok(trigger.script_flag, ",");

        for (i = 0; i < tokens.size; i++)
        {
            zr_set_flag(tokens[i]);
        }
    }

    // At load time there is no reason to replay a purchased debris animation.
    // Reconnect paths and remove the blocker pieces immediately.
    junk = GetEntArray(trigger.target, "targetname");

    for (i = 0; i < junk.size; i++)
    {
        if (IsDefined(junk[i]))
        {
            junk[i] ConnectPaths();
            junk[i] Delete();
        }
    }

    all_trigs = GetEntArray(trigger.target, "target");

    for (i = 0; i < all_trigs.size; i++)
    {
        if (IsDefined(all_trigs[i]))
        {
            all_trigs[i] Delete();
        }
    }
}

zr_restore_kino_route_flag(flag_name)
{
    doors = GetEntArray("zombie_door", "targetname");

    for (i = 0; i < doors.size; i++)
    {
        if (zr_entity_uses_flag(doors[i], flag_name))
        {
            zr_force_open_door(doors[i]);
        }
    }

    debris = GetEntArray("zombie_debris", "targetname");

    for (i = 0; i < debris.size; i++)
    {
        if (zr_entity_uses_flag(debris[i], flag_name))
        {
            zr_force_clear_debris(debris[i]);
        }
    }

    // Some route flags may not have a directly matching trigger on every map
    // revision. Setting it still keeps the stock zone manager in sync.
    zr_set_flag(flag_name);
}

zr_restore_kino_world()
{
    if (GetDvar("zr_sv_world_adapter") != "kino_v1")
    {
        return;
    }

    // _zombiemode::main initializes blockers/perks before round play. Give its
    // threaded blocker setup a short head start so door.doors is classified.
    wait 0.75;

    if (GetDvarInt("zr_sv_kino_power") == 1)
    {
        power_trigger = GetEnt("use_elec_switch", "targetname");

        if (IsDefined(power_trigger))
        {
            power_trigger Delete();
        }

        zr_set_flag("power_on");
        Objective_State(8, "done");
    }

    if (GetDvarInt("zr_sv_kino_magic_box_foyer1") == 1)
        zr_restore_kino_route_flag("magic_box_foyer1");
    if (GetDvarInt("zr_sv_kino_magic_box_crematorium1") == 1)
        zr_restore_kino_route_flag("magic_box_crematorium1");
    if (GetDvarInt("zr_sv_kino_vip_to_dining") == 1)
        zr_restore_kino_route_flag("vip_to_dining");
    if (GetDvarInt("zr_sv_kino_magic_box_alleyway1") == 1)
        zr_restore_kino_route_flag("magic_box_alleyway1");
    if (GetDvarInt("zr_sv_kino_dining_to_dressing") == 1)
        zr_restore_kino_route_flag("dining_to_dressing");
    if (GetDvarInt("zr_sv_kino_magic_box_dressing1") == 1)
        zr_restore_kino_route_flag("magic_box_dressing1");
    if (GetDvarInt("zr_sv_kino_magic_box_west_balcony2") == 1)
        zr_restore_kino_route_flag("magic_box_west_balcony2");
    if (GetDvarInt("zr_sv_kino_magic_box_west_balcony1") == 1)
        zr_restore_kino_route_flag("magic_box_west_balcony1");

    if (GetDvarInt("zr_sv_kino_curtains_done") == 1)
    {
        zr_set_flag("curtains_done");
    }

    if (GetDvarInt("zr_sv_kino_teleporter_linked") == 1)
    {
        zr_set_flag("core_linked");
        zr_set_flag("teleporter_linked");

        if (IsDefined(level.link_cable_on) && IsDefined(level.link_cable_off))
        {
            level.link_cable_off Hide();
            level.link_cable_on Show();
        }
    }

    println("[T5ZR] Kino world restored: power=" + GetDvar("zr_sv_kino_power") + ", teleporter_linked=" + GetDvar("zr_sv_kino_teleporter_linked") + ".");
}

zr_restore_world()
{
    if (zr_current_map() == "zombie_theater")
    {
        zr_restore_kino_world();
    }
}

zr_restore_round_scheduler()
{
    if (GetDvarInt("zr_sv_dog_rounds_enabled") != 1)
    {
        return;
    }

    // Wait for the stock dog tracker to initialize its fields. On Kino this
    // happens before normal round play begins.
    tries = 0;
    while ((!IsDefined(level.dog_rounds_enabled) || !level.dog_rounds_enabled || !IsDefined(level.next_dog_round)) && tries < 300)
    {
        wait 0.01;
        tries++;
    }

    if (!IsDefined(level.dog_rounds_enabled) || !level.dog_rounds_enabled)
    {
        println("[T5ZR] Dog scheduler restore skipped: stock dog rounds are not ready.");
        return;
    }

    saved_count = GetDvarInt("zr_sv_dog_round_count");
    if (saved_count < 1)
    {
        saved_count = 1;
    }

    saved_next = GetDvarInt("zr_sv_next_dog_round");
    saved_active = GetDvarInt("zr_sv_dog_round_active") == 1;

    level.dog_round_count = saved_count;
    if (saved_next > 0)
    {
        level.next_dog_round = saved_next;
    }

    if (saved_active)
    {
        // The autosave is taken after between_round_over, so an active flag
        // means the saved round itself is the dog round. Rebuild the stock
        // special-round state before round_think starts spawning enemies.
        if (!zr_flag_is_set("dog_round"))
        {
            maps\_zombiemode_ai_dogs::dog_round_start();
        }

        level.round_spawn_func = maps\_zombiemode_ai_dogs::dog_round_spawning;
    }

    println("[T5ZR] Dog scheduler restored: active=" + GetDvar("zr_sv_dog_round_active") + ", count=" + level.dog_round_count + ", next=" + level.next_dog_round + ".");
}

zr_restore_on_spawn()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        if (!IsDefined(self.zr_announced))
        {
            self.zr_announced = true;
            self iPrintLnBold("^2T5ZR " + level.zr_mod_version + "^7 actif");
        }

        if (!IsDefined(self.zr_hud_started))
        {
            self.zr_hud_started = true;
            self thread zr_hud_loop();
        }

        if (!IsDefined(level.zr_pending_resume) || !level.zr_pending_resume)
        {
            continue;
        }

        if (IsDefined(self.zr_restore_attempted) && self.zr_restore_attempted)
        {
            continue;
        }

        self.zr_restore_attempted = true;
        wait 0.30;

        slot = zr_find_saved_slot(self);

        if (slot < 0)
        {
            println("[T5ZR] No GUID-matched save slot for player " + self.name + "; leaving stock state untouched.");
            self iPrintLnBold("^3T5ZR:^7 aucune sauvegarde associee a ce joueur");
            continue;
        }

        self zr_restore_player_slot(slot);
    }
}

zr_watch_players()
{
    for (;;)
    {
        level waittill("connecting", player);
        player thread zr_restore_on_spawn();
    }
}

zr_prepare_resume()
{
    if (GetDvarInt("zr_resume") != 1)
    {
        return;
    }

    if (GetDvarInt("zr_sv_valid") != 1)
    {
        println("[T5ZR] Resume aborted: no valid save.");
        SetDvar("zr_resume", "0");
        return;
    }

    save_format = GetDvarInt("zr_sv_format");

    if (save_format != 6 && save_format != 7)
    {
        println("[T5ZR] Resume aborted: unsupported save format " + GetDvar("zr_sv_format") + ".");
        SetDvar("zr_resume", "0");
        return;
    }

    if (GetDvar("zr_sv_map") != zr_current_map())
    {
        println("[T5ZR] Resume aborted: saved map=" + GetDvar("zr_sv_map") + " current=" + zr_current_map());
        SetDvar("zr_resume", "0");
        return;
    }

    saved_round = GetDvarInt("zr_sv_round");

    if (saved_round < 1)
    {
        println("[T5ZR] Resume aborted: invalid saved round.");
        SetDvar("zr_resume", "0");
        return;
    }

    level.zr_pending_resume = true;
    level.zr_suppress_autosave = true;

    if (save_format >= 7)
    {
        level.zr_total_time_base_seconds = GetDvarInt("zr_sv_total_time_seconds");
    }
    else
    {
        level.zr_total_time_base_seconds = 0;
    }

    level.zr_session_start_time = 0;

    while (!IsDefined(level.round_number))
    {
        wait 0.01;
    }

    level.round_number = saved_round;

    // Restore special-round scheduling before normal gameplay has a chance to
    // consume the resumed round.
    zr_restore_round_scheduler();

    SetDvar("zr_resume", "0");

    println("[T5ZR] Prepared v" + save_format + " resume at round " + level.round_number + " for " + GetDvar("zr_sv_player_count") + " saved player(s).");

    // World restoration is separate from player spawn restoration.
    level thread zr_restore_world();

    wait 1.25;
    level.zr_suppress_autosave = false;
}

main()
{
    level.zr_mod_version = "0.7.0-beta.1";
    level.zr_pending_resume = false;
    level.zr_suppress_autosave = false;
    level.zr_total_time_base_seconds = 0;
    level.zr_session_start_time = 0;
    level.zr_slot_claimed = [];

    for (i = 0; i < 4; i++)
    {
        level.zr_slot_claimed[i] = false;
    }

    if (GetDvar("zr_save_now") == "")
        SetDvar("zr_save_now", "0");
    if (GetDvar("zr_status") == "")
        SetDvar("zr_status", "0");
    if (GetDvar("zr_resume") == "")
        SetDvar("zr_resume", "0");
    if (GetDvar("zr_clear_save") == "")
        SetDvar("zr_clear_save", "0");
    if (GetDvar("zr_hud") == "")
        SetDvar("zr_hud", "1");
    if (GetDvar("zr_hud_round_time") == "")
        SetDvar("zr_hud_round_time", "1");
    if (GetDvar("zr_hud_total_time") == "")
        SetDvar("zr_hud_total_time", "1");
    if (GetDvar("zr_hud_zombies") == "")
        SetDvar("zr_hud_zombies", "1");

    level thread zr_watch_round_number();
    level thread zr_watch_controls();
    level thread zr_watch_players();
    level thread zr_prepare_resume();

    println("[T5ZR] T5 Zombies Resume v" + level.zr_mod_version + " loaded (save format v7, HUD + offhand + scoreboard + dog scheduler + Kino world)");
}
