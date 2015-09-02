local class = require "lib.middleclass"
local lume = require "lib.lume"
local serialize = require "lib.ser"

local load = require "util.load"
local save = require "util.save"

local User = class("User")

function User:initialize()
    self._uuid = lume.uuid()
    self._name = ""
    self._username = ""
    self._sanitizedUsername = "default"
    self._password = ""
end

function User:getUUID()
    return self._uuid
end

function User:setName(name)
    self._name = name
end

function User:getName()
    return self._name
end

function User:setUsername(username)
    self._username = username
    self._sanitizedUsername = User.static.sanitize(username)
end

function User:getUsername()
    return self._username
end

function User:getSanitizedUsername()
    return self._sanitizedUsername
end

function User:setPassword(password)
    self._password = password
end

function User:getPassword()
    return self._password
end

local defaultSaveFile = "user.lua"

function User:save(file)
    if not file then file = defaultSaveFile end

    local data = {
        uuid = self._uuid,
        name = self._name,
        username = self._username,
        sanitizedUsername = self._sanitizedUsername,
        password = self._password
    }

    save(file, serialize(data))
end

function User:load(file)
    if not file then file = defaultSaveFile end

    data = load(file)

    if data == nil then
        --TODO ERROR MESSAGE
    elseif data then
        self._uuid = data.uuid
        self._name = data.name
        self._username = data.username
        self._sanitizedUsername = data.sanitizedUsername
        self._password = data.password
    else
        --TODO some sort of flag so user is warned when overwriting save after failed load
    end

    --Old Save Updating--

    --Prototype
    if self._name == nil then self._name = "" end
end

function User.static.sanitize(username)
    return string.gsub(username, "%A", "%-") --replace all non-characters with "-"
end

return User
