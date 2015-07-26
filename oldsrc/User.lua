local class = require "lib.middleclass"
local lume = require "lib.lume"
local serialize = require "lib.ser"
local filesystem = love.filesystem
local load = require "util.load"

local User = class('User')

function User:initialize()
    self.uuid = lume.uuid()
    --self.name = "" -- will be adding this at some point
    self.username = ""
    self.sanitizedUsername = "default"
    self.password = ""
end

function User:getUUID()
    return self.uuid
end

function User:setUsername(username)
    self.username = username
    self.sanitizedUsername = string.gsub(username, "%A", "%-") --replace all non-characters with "-"
end

function User:getUsername()
    return self.username
end

-- no setSanitizedUsername, it manages that itself
function User:getSanitizedUsername()
    return self.sanitizedUsername
end

function User:setPassword(password)
    self.password = password
end

function User:getPassword()
    return self.password
end

local defaultSaveFile = "save/default/user.lua"

function User:save(file)
    if not file then file = defaultSaveFile end
    local data = {
        uuid = self.uuid,
        username = self.username,
        sanitizedUsername = self.sanitizedUsername,
        password = self.password
    }
    data = serialize(data)
    --create dir / write data
    if file:find("^.+/") then
        local fdir = file:sub(file:find("^.+/"))
        filesystem.createDirectory(fdir)
    end
    filesystem.write(file, data)
end

function User:load(file)
    if not file then file = defaultSaveFile end
    if filesystem.exists(file) then
        local data = load(file)
        self.uuid = data.uuid
        self.username = data.username
        self.sanitizedUsername = data.sanitizedUsername
        self.password = data.password
    end
end

return User
