local duiCache = {}
local creatingDui = {}
local applied = {}
local remoteSkins = {}
local localSkin
local localWeaponName

local function notify(description, nType)
    lib.notify({
        title = 'Weapon Skin',
        description = description,
        type = nType or 'inform',
    })
end

local function isGunsmith()
    local job = QBX.PlayerData and QBX.PlayerData.job
    if not job or job.name ~= Config.Job then return false end
    if Config.RequireDuty and not job.onduty then return false end
    return true
end

---@param url string
---@return table?
local function getDui(url)
    if duiCache[url] then return duiCache[url] end

    if creatingDui[url] then
        while creatingDui[url] do
            Wait(50)
        end
        return duiCache[url]
    end

    creatingDui[url] = true

    local dui = lib.dui:new({
        url = url,
        width = 250,
        height = 250,
    })

    local timeout = GetGameTimer() + 5000
    while not IsDuiAvailable(dui.duiObject) and GetGameTimer() < timeout do
        Wait(50)
    end

    duiCache[url] = dui
    creatingDui[url] = nil
    return dui
end

---@param weaponName string
local function restoreSkin(weaponName)
    local current = applied[weaponName]
    if not current then return end

    RemoveReplaceTexture(current.ytd, current.texture)
    applied[weaponName] = nil
end

---@param weaponName string
---@param url string
local function applySkin(weaponName, url)
    local weapon = Config.Weapons[weaponName]
    if not weapon or not url then return end

    local current = applied[weaponName]
    if current and current.url == url then return end

    if current then
        RemoveReplaceTexture(weapon.ytd, weapon.texture)
        applied[weaponName] = nil
    end

    local dui = getDui(url)
    if not dui then return end

    if localWeaponName == weaponName then
        if not (localSkin and localSkin.url == url) then return end
    else
        local remoteWantsUrl = false
        for _, skin in pairs(remoteSkins) do
            if skin.name == weaponName and skin.url == url then
                remoteWantsUrl = true
                break
            end
        end
        if not remoteWantsUrl then return end
    end

    AddReplaceTexture(weapon.ytd, weapon.texture, dui.dictName, dui.txtName)
    applied[weaponName] = {
        url = url,
        ytd = weapon.ytd,
        texture = weapon.texture,
    }
end

---@param weaponName string
local function refreshWeaponModel(weaponName)
    if not weaponName or not Config.Weapons[weaponName] then return end

    if localSkin and localSkin.name == weaponName and localSkin.url then
        applySkin(weaponName, localSkin.url)
        return
    end

    -- Keep the vanilla texture while this client is holding that model
    if localWeaponName == weaponName then
        restoreSkin(weaponName)
        return
    end

    for _, skin in pairs(remoteSkins) do
        if skin.name == weaponName and skin.url then
            applySkin(weaponName, skin.url)
            return
        end
    end

    restoreSkin(weaponName)
end

local function setLocalSkin(weaponName, url)
    local previous = localSkin
    if url and weaponName then
        localSkin = { name = weaponName, url = url }
        LocalPlayer.state:set('weaponSkin', localSkin, true)
    else
        localSkin = nil
        LocalPlayer.state:set('weaponSkin', nil, true)
    end

    if previous and previous.name then
        refreshWeaponModel(previous.name)
    end

    if weaponName and (not previous or previous.name ~= weaponName) then
        refreshWeaponModel(weaponName)
    end
end

local function getHeldWeapon()
    local weapon = exports.ox_inventory:getCurrentWeapon()
    if not weapon or not weapon.name then
        return nil, 'You need a weapon in your hands.'
    end

    if not Config.Weapons[weapon.name] then
        return nil, 'This weapon cannot be skinned.'
    end

    return weapon
end

local function openApplyDialog()
    if not isGunsmith() then
        notify('You must be on duty as a gunsmith.', 'error')
        return
    end

    local weapon, err = getHeldWeapon()
    if not weapon then
        notify(err, 'error')
        return
    end

    local input = lib.inputDialog('Weapon Skin', {
        {
            type = 'input',
            label = 'Image URL',
            description = 'Direct https image link',
            required = true,
        },
    })

    if not input or not input[1] then return end

    local success, result = lib.callback.await('weaponskins:apply', false, input[1])
    if not success then
        notify(result or 'Could not apply that skin.', 'error')
        return
    end

    setLocalSkin(weapon.name, result)
    notify('Skin applied.', 'success')
end

local function removeSkin()
    if not isGunsmith() then
        notify('You must be on duty as a gunsmith.', 'error')
        return
    end

    local weapon, err = getHeldWeapon()
    if not weapon then
        notify(err, 'error')
        return
    end

    local success, result = lib.callback.await('weaponskins:remove', false)
    if not success then
        notify(result or 'Could not remove that skin.', 'error')
        return
    end

    setLocalSkin(nil)
    notify('Skin removed.', 'success')
end

if Config.Debug then
    RegisterCommand(Config.DebugCommand, function()
        local weapon, err = getHeldWeapon()
        if not weapon then
            notify(err, 'error')
            return
        end

        local input = lib.inputDialog('Weapon Skin (Debug)', {
            {
                type = 'input',
                label = 'Image URL',
                description = 'Direct https image link',
            },
            {
                type = 'checkbox',
                label = 'Remove current skin',
            },
        })

        if not input then return end

        if input[2] then
            local success, result = lib.callback.await('weaponskins:remove', false)
            if not success then
                notify(result or 'Could not remove that skin.', 'error')
                return
            end

            setLocalSkin(nil)
            notify('Skin removed.', 'success')
            return
        end

        if not input[1] or input[1] == '' then
            notify('Enter an image URL, or check remove.', 'error')
            return
        end

        local success, result = lib.callback.await('weaponskins:apply', false, input[1])
        if not success then
            notify(result or 'Could not apply that skin.', 'error')
            return
        end

        setLocalSkin(weapon.name, result)
        notify('Skin applied.', 'success')
    end, false)
end

AddEventHandler('ox_inventory:currentWeapon', function(weapon)
    localWeaponName = weapon and weapon.name or nil

    if weapon and weapon.name and weapon.metadata and weapon.metadata.skinUrl then
        setLocalSkin(weapon.name, weapon.metadata.skinUrl)
        return
    end

    setLocalSkin(nil)
end)

AddStateBagChangeHandler('weaponSkin', '', function(bagName, _, value)
    local playerId = GetPlayerFromStateBagName(bagName)
    if not playerId or playerId == 0 or playerId == cache.playerId then return end

    local serverId = GetPlayerServerId(playerId)
    local previous = remoteSkins[serverId]
    local nextSkin = (type(value) == 'table' and value.name and value.url) and {
        name = value.name,
        url = value.url,
    } or nil

    remoteSkins[serverId] = nextSkin

    if previous and previous.name then
        refreshWeaponModel(previous.name)
    end

    if nextSkin and (not previous or previous.name ~= nextSkin.name) then
        refreshWeaponModel(nextSkin.name)
    end
end)

CreateThread(function()
    while GetResourceState('ox_inventory') ~= 'started' do
        Wait(100)
    end

    exports.ox_inventory:displayMetadata({
        skinned = 'Skinned',
    })
end)

CreateThread(function()
    Wait(1500)

    local weapon = exports.ox_inventory:getCurrentWeapon()
    localWeaponName = weapon and weapon.name or nil
    if weapon and weapon.name and weapon.metadata and weapon.metadata.skinUrl then
        setLocalSkin(weapon.name, weapon.metadata.skinUrl)
    end

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= cache.playerId then
            local serverId = GetPlayerServerId(playerId)
            local state = Player(serverId).state.weaponSkin
            if type(state) == 'table' and state.name and state.url then
                remoteSkins[serverId] = {
                    name = state.name,
                    url = state.url,
                }
                refreshWeaponModel(state.name)
            end
        end
    end
end)

local targetZoneId

CreateThread(function()
    while GetResourceState('ox_target') ~= 'started' do
        Wait(100)
    end

    targetZoneId = exports.ox_target:addSphereZone({
        coords = Config.Location,
        radius = Config.InteractDistance,
        options = {
            {
                name = 'weaponskins_apply',
                label = 'Apply Weapon Skin',
                icon = 'fa-solid fa-spray-can',
                distance = Config.InteractDistance,
                canInteract = isGunsmith,
                onSelect = openApplyDialog,
            },
            {
                name = 'weaponskins_remove',
                label = 'Remove Weapon Skin',
                icon = 'fa-solid fa-eraser',
                distance = Config.InteractDistance,
                canInteract = isGunsmith,
                onSelect = removeSkin,
            },
        },
    })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= cache.resource then return end

    if targetZoneId then
        exports.ox_target:removeZone(targetZoneId)
    end

    local names = {}
    for name in pairs(applied) do
        names[#names + 1] = name
    end

    for i = 1, #names do
        restoreSkin(names[i])
    end

    LocalPlayer.state:set('weaponSkin', nil, true)
end)
