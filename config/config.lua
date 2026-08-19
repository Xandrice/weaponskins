Config = {}

Config.Job = 'gunsmith'
Config.RequireDuty = true

-- Test command `/weapon_skin` (skips job/duty). Set false on live.
Config.Debug = true
Config.DebugCommand = 'weapon_skin'

-- Paste the gunsmith station coords here
Config.Location = vec3(0.0, 0.0, 0.0)
Config.InteractDistance = 2.0

-- Direct image hosts only. Imgur and Discord CDNs are blocked even if added here.
Config.AllowedHosts = {
    ['r2.fivemanage.com'] = true,
    ['files.fivemerr.com'] = true,
    ['i.postimg.cc'] = true,
    ['ibb.co'] = true,
    ['i.ibb.co'] = true,
    ['i.vgy.me'] = true,
    ['kappa.lol'] = true,
}

Config.AllowedExtensions = {
    png = true,
    jpg = true,
    jpeg = true,
    webp = true,
    apng = true,
}

-- ytd/texture pairs from av_weaponskin, keyed by ox_inventory item name
Config.Weapons = {
    ['WEAPON_PISTOL'] = { ytd = 'w_pi_pistol', texture = 'w_pi_pistol' },
    ['WEAPON_PISTOL_MK2'] = { ytd = 'w_pi_pistolmk2', texture = 'w_pi_pistolmk2' },
    ['WEAPON_COMBATPISTOL'] = { ytd = 'w_pi_combatpistol', texture = 'w_pi_combatpistol' },
    ['WEAPON_PISTOL50'] = { ytd = 'w_pi_pistol50', texture = 'w_pl_pistol50' },
    ['WEAPON_SNSPISTOL'] = { ytd = 'w_pi_sns_pistol', texture = 'w_pi_sns_pistol' },
    ['WEAPON_HEAVYPISTOL'] = { ytd = 'w_pi_heavypistol', texture = 'w_pi_heavypistol' },
    ['WEAPON_VINTAGEPISTOL'] = { ytd = 'w_pi_vintage_pistol', texture = 'w_pi_vintage_pistol' },
    ['WEAPON_MARKSMANPISTOL'] = { ytd = 'w_pi_singleshot', texture = 'w_pi_singleshot_dm' },
    ['WEAPON_REVOLVER'] = { ytd = 'w_pi_revolver', texture = 'w_pi_revolver' },
    ['WEAPON_STUNGUN'] = { ytd = 'w_pi_stungun', texture = 'w_pi_stungun' },
    ['WEAPON_MICROSMG'] = { ytd = 'w_sb_microsmg', texture = 'w_sb_microsmg' },
    ['WEAPON_MACHINEPISTOL'] = { ytd = 'w_sb_compactsmg', texture = 'w_sb_compactsmg' },
    ['WEAPON_SMG'] = { ytd = 'w_sb_smg', texture = 'w_sb_smg' },
    ['WEAPON_SMG_MK2'] = { ytd = 'w_sb_smgmk2', texture = 'w_sb_smgmk2' },
    ['WEAPON_ASSAULTSMG'] = { ytd = 'w_sb_assaultsmg', texture = 'w_sb_assaultsmg' },
    ['WEAPON_COMBATPDW'] = { ytd = 'w_sb_pdw', texture = 'w_sb_pdw' },
    ['WEAPON_MG'] = { ytd = 'w_mg_mg', texture = 'w_mg_mg' },
    ['WEAPON_COMBATMG'] = { ytd = 'w_mg_combatmg', texture = 'w_mg_combatmg_tint' },
    ['WEAPON_COMBATMG_MK2'] = { ytd = 'w_mg_combatmgmk2', texture = 'w_mg_combatmgmk2_l1' },
    ['WEAPON_GUSENBERG'] = { ytd = 'w_sb_gusenberg', texture = 'w_sb_gusenberg' },
    ['WEAPON_MINISMG'] = { ytd = 'w_sb_minismg', texture = 'w_sb_minismg_dm' },
    ['WEAPON_ASSAULTRIFLE'] = { ytd = 'w_ar_assaultrifle', texture = 'w_ar_assaultrifle' },
    ['WEAPON_ASSAULTRIFLE_MK2'] = { ytd = 'w_ar_assaultriflemk2', texture = 'w_ar_assaultriflemk2' },
    ['WEAPON_CARBINERIFLE'] = { ytd = 'w_ar_carbinerifle', texture = 'w_ar_carbinerifle' },
    ['WEAPON_CARBINERIFLE_MK2'] = { ytd = 'w_ar_carbineriflemk2', texture = 'w_ar_carbineriflemk2' },
    ['WEAPON_SPECIALCARBINE'] = { ytd = 'w_ar_specialcarbine', texture = 'w_ar_specialcarbine_tint' },
    ['WEAPON_BULLPUPRIFLE'] = { ytd = 'w_ar_bullpuprifle', texture = 'w_ar_bullpuprifle' },
    ['WEAPON_COMPACTRIFLE'] = { ytd = 'w_ar_assaultrifle_smg', texture = 'w_ar_assaultrifle_smg_d' },
    ['WEAPON_SNIPERRIFLE'] = { ytd = 'w_sr_sniperrifle', texture = 'w_sr_sniperrifle' },
    ['WEAPON_HEAVYSNIPER'] = { ytd = 'w_sr_heavysniper', texture = 'w_sr_heavysniper' },
    ['WEAPON_HEAVYSNIPER_MK2'] = { ytd = 'w_sr_heavysnipermk2', texture = 'w_sr_heavysnipermk2' },
    ['WEAPON_MARKSMANRIFLE'] = { ytd = 'w_sr_marksmanrifle', texture = 'w_sr_marksmanrifle' },
    ['WEAPON_PUMPSHOTGUN'] = { ytd = 'w_sg_pumpshotgun', texture = 'w_sg_pumpshotgun' },
    ['WEAPON_SAWNOFFSHOTGUN'] = { ytd = 'w_sg_sawnoff', texture = 'w_sg_sawnoff' },
    ['WEAPON_BULLPUPSHOTGUN'] = { ytd = 'w_sg_bullpupshotgun', texture = 'w_sg_bullpupshotgun' },
    ['WEAPON_ASSAULTSHOTGUN'] = { ytd = 'w_sg_assaultshotgun', texture = 'w_sg_assaultshotgun' },
    ['WEAPON_MUSKET'] = { ytd = 'w_ar_musket', texture = 'w_ar_musket_d' },
    ['WEAPON_DBSHOTGUN'] = { ytd = 'w_sg_doublebarrel', texture = 'w_sg_doublebarrel_dm' },
    ['WEAPON_APPISTOL'] = { ytd = 'w_pi_appistol', texture = 'w_pi_appistol' },
    ['WEAPON_ADVANCEDRIFLE'] = { ytd = 'w_ar_advancedrifle', texture = 'w_ar_advancedrifle' },
}
