// T5 Zombies Resume
// Host-only save/resume for Plutonium T5 / BO1 Zombies.
// Native GSC only: no external DLL.
//
// v0.4.0-rc1
// - save format v4
// - strict player matching by engine GetGuid()
// - round, score, primary weapons and ammo
// - active Zombies perks restored through stock _zombiemode_perks::give_perk
// - perks restored before weapons so Mule Kick can safely precede a third gun
// - each saved slot and player can be restored only once per resumed session
// - persistent zr_sv_* dvars are archived by install.ps1

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

zr_show_message(message)
{
    players = GetPlayers();

    for (i = 0; i < players.size; i++)
    {
        players[i] iPrintLnBold(message);
    }
}

zr_store(key, value)
{
    // install.ps1 pre-registers zr_sv_* through `seta`, giving the dvars the
    // archive flag. SetDvar updates the live archived value. SetSavedDvar is
    // also kept because it is a native T5 builtin validated by the 0.2.x tests.
    SetDvar(key, value);
    SetSavedDvar(key, value);
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
    zr_clear_saved_perks(slot);

    for (w = 0; w < 3; w++)
    {
        zr_clear_saved_weapon(slot, w);
    }
}

zr_clear_save()
{
    zr_store("zr_sv_valid", "0");
    zr_store("zr_sv_format", "4");
    zr_store("zr_sv_mod_version", level.zr_mod_version);
    zr_store("zr_sv_map", "");
    zr_store("zr_sv_round", "0");
    zr_store("zr_sv_reason", "cleared");
    zr_store("zr_sv_player_count", "0");

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

    // Base BO1 Zombies perks.
    perk_count = zr_save_perk_if_present(slot, player, "specialty_armorvest", perk_count);                 // Jugger-Nog
    perk_count = zr_save_perk_if_present(slot, player, "specialty_quickrevive", perk_count);              // Quick Revive
    perk_count = zr_save_perk_if_present(slot, player, "specialty_fastreload", perk_count);               // Speed Cola
    perk_count = zr_save_perk_if_present(slot, player, "specialty_rof", perk_count);                      // Double Tap
    perk_count = zr_save_perk_if_present(slot, player, "specialty_longersprint", perk_count);             // Stamin-Up
    perk_count = zr_save_perk_if_present(slot, player, "specialty_flakjacket", perk_count);               // PHD Flopper
    perk_count = zr_save_perk_if_present(slot, player, "specialty_deadshot", perk_count);                 // Deadshot Daiquiri
    perk_count = zr_save_perk_if_present(slot, player, "specialty_additionalprimaryweapon", perk_count);  // Mule Kick

    // The stock perk script also defines upgrade variants. They are uncommon
    // in normal BO1 Zombies but saving them costs little and avoids silently
    // dropping one if a map/mutator exposes it.
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
    zr_save_player_perks(slot, player);

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

    // Invalidate first so a partial write is never considered resumable.
    zr_store("zr_sv_valid", "0");
    zr_store("zr_sv_format", "4");
    zr_store("zr_sv_mod_version", level.zr_mod_version);
    zr_store("zr_sv_map", zr_current_map());
    zr_store("zr_sv_round", "" + level.round_number);
    zr_store("zr_sv_reason", reason);
    zr_store("zr_sv_player_count", "" + player_count);

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

    println("[T5ZR] Saved " + zr_current_map() + " -> round " + level.round_number + " (" + reason + "), players=" + player_count);
    zr_show_message("^2T5ZR:^7 sauvegarde OK - prochaine manche " + level.round_number);
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
    println("[T5ZR] saved_players=" + GetDvar("zr_sv_player_count") + " resume_request=" + GetDvar("zr_resume"));

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

    // Safety rule: never fall back to player.name.
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

        if (perk == "")
        {
            continue;
        }

        if (self HasPerk(perk))
        {
            continue;
        }

        // Reuse Treyarch's stock Zombies path. This applies the actual perk,
        // HUD/icon, perk_think lifecycle and perk-specific side effects such as
        // Jugger-Nog max health and Deadshot's client flag. Passing false avoids
        // purchase VO while keeping the gameplay setup.
        self maps\_zombiemode_perks::give_perk(perk, false);
        restored++;
        wait 0.05;
    }

    println("[T5ZR] Restored " + restored + " perk(s) for " + self.name + ".");
}

zr_restore_player_slot(slot)
{
    level.zr_slot_claimed[slot] = true;
    self.zr_restore_applied = true;

    // Restore perks before weapons. Mule Kick must exist before a possible
    // third primary is rebuilt.
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

    current = GetDvar(zr_player_key(slot, "current_weapon"));

    if (current != "" && current != "none" && self HasWeapon(current))
    {
        self SwitchToWeapon(current);
    }

    self iPrintLnBold("^2T5ZR:^7 partie restauree - manche " + level.round_number);
    println("[T5ZR] Restored player " + self.name + " from save slot " + slot + ".");
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

        if (!IsDefined(level.zr_pending_resume) || !level.zr_pending_resume)
        {
            continue;
        }

        if (IsDefined(self.zr_restore_attempted) && self.zr_restore_attempted)
        {
            continue;
        }

        self.zr_restore_attempted = true;

        // Let the stock Zombies starting loadout and perk bookkeeping initialize.
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

    if (GetDvarInt("zr_sv_format") != 4)
    {
        println("[T5ZR] Resume aborted: save format " + GetDvar("zr_sv_format") + " is not v4. Create a new autosave with v0.4.x.");
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

    while (!IsDefined(level.round_number))
    {
        wait 0.01;
    }

    level.round_number = saved_round;
    SetDvar("zr_resume", "0");

    println("[T5ZR] Prepared v4 resume at round " + level.round_number + " for " + GetDvar("zr_sv_player_count") + " saved player(s).");

    wait 0.75;
    level.zr_suppress_autosave = false;
}

main()
{
    level.zr_mod_version = "0.4.0-rc1";
    level.zr_pending_resume = false;
    level.zr_suppress_autosave = false;
    level.zr_slot_claimed = [];

    for (i = 0; i < 4; i++)
    {
        level.zr_slot_claimed[i] = false;
    }

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

    if (GetDvar("zr_clear_save") == "")
    {
        SetDvar("zr_clear_save", "0");
    }

    level thread zr_watch_round_number();
    level thread zr_watch_controls();
    level thread zr_watch_players();
    level thread zr_prepare_resume();

    println("[T5ZR] T5 Zombies Resume v" + level.zr_mod_version + " loaded (save format v4, GUID + perks)");
}
