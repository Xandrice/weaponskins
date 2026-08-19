local duiCache = {}
local creatingDui = {}
local applied = {}
local localSkin
local localWeaponName
local nearbyConflict = false

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

-- DUI replace is global per texture. If another copy of this weapon is
-- streamed, hide the skin so their gun does not pick up your image.
---@param weaponName string
---@return boolean
local function hasNearbySameWeapon(weaponName)
    local hash = joaat(weaponName)
    local myPed = cache.ped
    local peds = GetGamePool('CPed')

    for i = 1, #peds do
        local ped = peds[i]
        if ped ~= myPed and GetSelectedPedWeapon(ped) == hash then
            return true
        end
    end

    return false
end

---@param weaponName string
---@param url string
local function applySkin(weaponName, url)
    local weapon = Config.Weapons[weaponName]
    if not weapon or not url then return end

    if localWeaponName ~= weaponName then return end
    if not (localSkin and localSkin.name == weaponName and localSkin.url == url) then return end
    if nearbyConflict then return end

    local current = applied[weaponName]
    if current and current.url == url then return end

    if current then
        RemoveReplaceTexture(weapon.ytd, weapon.texture)
        applied[weaponName] = nil
    end

    local dui = getDui(url)
    if not dui then return end

    if localWeaponName ~= weaponName then return end
    if not (localSkin and localSkin.name == weaponName and localSkin.url == url) then return end
    if nearbyConflict or hasNearbySameWeapon(weaponName) then return end

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

    if localSkin and localSkin.name == weaponName and localSkin.url and not nearbyConflict then
        applySkin(weaponName, localSkin.url)
        return
    end

    restoreSkin(weaponName)
end

local function setLocalSkin(weaponName, url)
    local previous = localSkin
    if url and weaponName then
        localSkin = { name = weaponName, url = url }
        nearbyConflict = hasNearbySameWeapon(weaponName)
    else
        localSkin = nil
        nearbyConflict = false
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
end)

CreateThread(function()
    while true do
        if localSkin and localSkin.name then
            local conflict = hasNearbySameWeapon(localSkin.name)
            if conflict ~= nearbyConflict then
                nearbyConflict = conflict
                refreshWeaponModel(localSkin.name)
            end
            Wait(250)
        else
            Wait(500)
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
end)
