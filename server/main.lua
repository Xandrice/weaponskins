local ox_inventory = exports.ox_inventory

local lastAction = {}

local blockedHostTokens = {
    'imgur',
    'discord',
}

---@param source number
---@return boolean
local function isGunsmith(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    local job = player.PlayerData.job
    if not job or job.name ~= Config.Job then return false end
    if Config.RequireDuty and not job.onduty then return false end

    return true
end

---@param source number
---@return boolean
local function canSkinWeapon(source)
    return Config.Debug or isGunsmith(source)
end

---@param source number
---@return boolean, string?
local function consumeCooldown(source)
    local now = GetGameTimer()
    if lastAction[source] and (now - lastAction[source]) < 2000 then
        return false, 'Please wait a moment before doing that again.'
    end

    lastAction[source] = now
    return true
end

---@param url string
---@return string? host
---@return string? extension
---@return string? cleaned
local function parseImageUrl(url)
    if type(url) ~= 'string' then return end

    url = url:gsub('^%s+', ''):gsub('%s+$', '')

    local host, path = url:match('^https://([^/]+)(/[^%s]*)$')
    if not host or not path then return end

    host = host:lower()
    host = host:match('@([^@]+)$') or host
    host = host:match('^([^:]+)') or host

    local pathNoQuery = path:match('^([^?#]+)') or path
    local ext = pathNoQuery:match('%.([%a%d]+)$')
    if ext then ext = ext:lower() end

    return host, ext, url
end

---@param url string
---@return boolean
---@return string? cleaned
---@return string? error
local function isAllowedSkinUrl(url)
    local host, ext, cleaned = parseImageUrl(url)
    if not host or not ext or not cleaned then
        return false, nil, 'Use a direct https image link (png, jpg, jpeg, webp, or apng).'
    end

    for i = 1, #blockedHostTokens do
        if host:find(blockedHostTokens[i], 1, true) then
            return false, nil, 'That image host is not allowed.'
        end
    end

    if not Config.AllowedHosts[host] then
        return false, nil, 'That image host is not allowed.'
    end

    if not Config.AllowedExtensions[ext] then
        return false, nil, 'That image type is not allowed.'
    end

    return true, cleaned
end

---@param source number
---@return table? weapon
---@return table? weaponConfig
---@return string? error
local function getEquippedSkinWeapon(source)
    local weapon = ox_inventory:GetCurrentWeapon(source)
    if not weapon or not weapon.name then
        return nil, nil, 'You need a weapon in your hands.'
    end

    local weaponConfig = Config.Weapons[weapon.name]
    if not weaponConfig then
        return nil, nil, 'This weapon cannot be skinned.'
    end

    return weapon, weaponConfig
end

AddEventHandler('playerDropped', function()
    lastAction[source] = nil
end)

lib.callback.register('weaponskins:apply', function(source, url)
    if not canSkinWeapon(source) then
        return false, 'You must be on duty as a gunsmith.'
    end

    local ready, cooldownError = consumeCooldown(source)
    if not ready then
        return false, cooldownError
    end

    local weapon, _, weaponError = getEquippedSkinWeapon(source)
    if not weapon then
        return false, weaponError
    end

    local allowed, cleaned, urlError = isAllowedSkinUrl(url)
    if not allowed then
        return false, urlError
    end

    local metadata = weapon.metadata or {}
    metadata.skinned = 'True'
    metadata.skinUrl = cleaned
    ox_inventory:SetMetadata(source, weapon.slot, metadata)

    return true, cleaned
end)

lib.callback.register('weaponskins:remove', function(source)
    if not canSkinWeapon(source) then
        return false, 'You must be on duty as a gunsmith.'
    end

    local ready, cooldownError = consumeCooldown(source)
    if not ready then
        return false, cooldownError
    end

    local weapon, _, weaponError = getEquippedSkinWeapon(source)
    if not weapon then
        return false, weaponError
    end

    local metadata = weapon.metadata or {}
    if metadata.skinned ~= 'True' and not metadata.skinUrl then
        return false, 'This weapon is not skinned.'
    end

    metadata.skinned = nil
    metadata.skinUrl = nil
    ox_inventory:SetMetadata(source, weapon.slot, metadata)

    return true
end)
