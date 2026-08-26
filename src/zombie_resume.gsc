// T5 Zombies Resume
// Native GSC persistence prototype for Plutonium T5 / BO1 Zombies.
// No external DLL is required.
//
// r5346 compatibility note:
// The currently distributed t5-gsc-utils DLL crashes T5 r5346 during startup
// on at least one confirmed setup (ddl/stats.ddl initialization failure).
// This version therefore uses only native BO1/T5 GSC builtins.
//
// v0.2.0-native-test saves at a stable round boundary:
// - next round number
// - player name
// - points / total score
// - up to 3 primary weapons
// - clip + reserve ammo
// - selected weapon when possible
//
// Persistence is stored in SavedDvars on the host.
// Not restored yet: perks, doors, power, box, traps, EE state, mid-round AI.

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

zr_player_key(slot, suffix)
{
    return "zr_sv_p" + slot + "_" + suffix;
}

zr_weapon_key(slot, weapon_slot, suffix)
{
    return "zr_sv_p" + slot + "_w" + weapon_slot + "_" + suffix;
}

zr_clear_saved_weapon(slot, weapon_slot)
{
    SetSavedDvar(zr_weapon_key(slot, weapon_slot, "name"), "");
    SetSavedDvar(zr_weapon_key(slot, weapon_slot, "clip"), "0");
    SetSavedDvar(zr_weapon_key(slot, weapon_slot, "stock"), "0");
}

zr_clear_saved_player(slot)
{
    SetSavedDvar(zr_player_key(slot, "name"), "");
    SetSavedDvar(zr_player_key(slot, "score"), "0");
    SetSavedDvar(zr_player_key(slot, "score_total"), "0");
    SetSavedDvar(zr_player_key(slot, "current_weapon"), "none");
    SetSavedDvar(zr_player_key(slot, "weapon_count"), "0");

    for (w = 0; w < 3; w++)
    {
        zr_clear_saved_weapon(slot, w);
    }
}

zr_save_player(slot, player)
{
    score = zr_int_or(player.score, 0);
    total = zr_int_or(player.score_total, score);
    weapons = player GetWeaponsListPrimaries();
    weapon_count = weapons.size;

    if (weapon_count > 3)
    {
        weapon_count = 3;
    }

    SetSavedDvar(zr_player_key(slot, "name"), player.name);
    SetSavedDvar(zr_player_key(slot, "score"), "" + score);
    SetSavedDvar(zr_player_key(slot, "score_total"), "" + total);
    SetSavedDvar(zr_player_key(slot, "current_weapon"), player GetCurrentWeapon());
    SetSavedDvar(zr_player_key(slot, "weapon_count"), "" + weapon_count);

    for (w = 0; w < 3; w++)
    {
        if (w < weapon_count)
        {
            weapon = weapons[w];
            SetSavedDvar(zr_weapon_key(slot, w, "name"), weapon);
            SetSavedDvar(zr_weapon_key(slot, w, "clip"), "" + player GetWeaponAmmoClip(weapon));
            SetSavedDvar(zr_weapon_key(slot, w, "stock"), "" + player GetWeaponAmmoStock(weapon));
        }
        else
        {
            zr_clear_saved_weapon(slot, w);
        }
    }
}

zr_save_game(reason)
{
    if (!IsDefined(level.round_number))
    {
        println("[T5ZR] Save skipped: round number is not initialized yet.");
        return;
    }

    players = GetPlayers();
    player_count = players.size;

    if (player_count > 4)
    {
        player_count = 4;
    }

    SetSavedDvar("zr_sv_valid", "0");
    SetSavedDvar("zr_sv_format", "2");
    SetSavedDvar("zr_sv_map", zr_current_map());
    SetSavedDvar("zr_sv_round", "" + level.round_number);
    SetSavedDvar("zr_sv_reason", reason);
    SetSavedDvar("zr_sv_player_count", "" + player_count);

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

    // Mark valid only after every field has been written.
    SetSavedDvar("zr_sv_valid", "1");

    println("[T5ZR] Saved " + zr_current_map() + " -> round " + level.round_number + " (" + reason + ")");
}

zr_watch_round_end()
{
    for (;;)
    {
        level waittill("between_round_over");
        wait 0.05;
        zr_save_game("autosave");
    }
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
            println("[T5ZR] version=" + level.zr_mod_version + " map=" + zr_current_map());
            println("[T5ZR] saved_valid=" + GetDvar("zr_sv_valid") + " saved_map=" + GetDvar("zr_sv_map") + " saved_round=" + GetDvar("zr_sv_round"));
            println("[T5ZR] resume_request=" + GetDvar("zr_resume"));
        }

        wait 0.10;
    }
}

zr_find_saved_slot(player)
{
    player_count = GetDvarInt("zr_sv_player_count");

    if (player_count > 4)
    {
        player_count = 4;
    }

    for (i = 0; i < player_count; i++)
    {
        if (GetDvar(zr_player_key(i, "name")) == player.name)
        {
            return i;
        }
    }

    return -1;
}

zr_restore_player_slot(slot)
{
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

    current = GetDvar(zr_player_key(slot, "current_weapon"));
    if (current != "" && current != "none" && self HasWeapon(current))
    {
        self SwitchToWeapon(current);
    }

    self iPrintLnBold("^2T5 Zombies Resume:^7 partie restauree (round " + level.round_number + ")");
    println("[T5ZR] Restored " + self.name + " from slot " + slot + " score=" + self.score);
}

zr_restore_on_spawn()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("spawned_player");

        if (!IsDefined(level.zr_pending_resume) || !level.zr_pending_resume)
        {
            continue;
        }

        // Let the stock Zombies loadout finish first.
        wait 0.10;

        slot = zr_find_saved_slot(self);
        if (slot < 0)
        {
            println("[T5ZR] No saved slot matched player name: " + self.name);
            continue;
        }

        self zr_restore_player_slot(slot);
    }
}

zr_watch_players()
{
    for (;;)
    {
        // Stock T5 Zombies uses the connecting notification.
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
        println("[T5ZR] Resume aborted: no valid native save.");
        SetDvar("zr_resume", "0");
        return;
    }

    if (GetDvarInt("zr_sv_format") != 2)
    {
        println("[T5ZR] Resume aborted: unsupported save format " + GetDvar("zr_sv_format"));
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

    // Critical timing point: validate on Kino first.
    while (!IsDefined(level.round_number))
    {
        wait 0.01;
    }

    level.round_number = saved_round;
    SetDvar("zr_resume", "0");
    println("[T5ZR] Prepared native resume at round " + level.round_number);
}

main()
{
    level.zr_mod_version = "0.2.0-native-test";
    level.zr_pending_resume = false;

    // Console control dvars. They are intentionally simple native dvars so
    // no command-registration plugin is required.
    if (GetDvar("zr_save_now") == "")
    {
        SetDvar("zr_save_now", "0");
    }

    if (GetDvar("zr_status") == "")
    {
        SetDvar("zr_status", "0");
    }

    if (GetDvar("zr_resume") == "")
    {
        SetDvar("zr_resume", "0");
    }

    level thread zr_watch_round_end();
    level thread zr_watch_controls();
    level thread zr_watch_players();
    level thread zr_prepare_resume();

    println("[T5ZR] T5 Zombies Resume v" + level.zr_mod_version + " loaded (native GSC, no DLL)");
}
