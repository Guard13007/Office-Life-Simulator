local class = require "lib.middleclass"
local beholder = require "lib.beholder"
local cron = require "lib.cron"
local serialize = require "lib.ser"
local User = require "User"

local load = require "util.load"
local save = require "util.save"
local log = require "util.logger"

local Computer = class("Computer")

function Computer:initialize(OS, Programs)
    self.os = OS or {               --just access directly as needed
        name = "Doors OS 2",
        publisher = "Titanhard LTD"
    }

    self._cron = {}                 --stores timed tasks to be completed
    self._programs = Programs or {} --table of references
    self._users = {}

    self._observeLogIn = beholder.observe("LogInProgram", "logged in", function()
        self:getProgram("StartMenu", true):open()
        self:getProgram("ProductivityTrackerProgram", true):open()
    end)

    self.firstRun = true
end

function Computer:getProgram(name, required)
    if type(required) == "nil" then
        required = true --required by default
    end

    if not self._programs[name] and required then
        local Program = require("programs." .. name)
        local program = Program()
        self._programs[name] = program
    end

    return self._programs[name]
end

function Computer:addProgram(name, reference)
    if reference then
        self._programs[name] = reference
    else
        local Program = require("programs." .. name)
        local program = Program()
        self._programs[name] = program
    end
end

function Computer:getUser(username)
    if not self._users[username] then
        --local Program = require("programs." .. name)
        local user = User()
        --user:load(path .. "users/" .. username)

        --TODO THIS -> self._users[username] = load(username)
        --local program = Program()
        --self._programs[name] = program
    end

    return self._users[username]
end

function Computer:after(...)
    local job = cron.after(...)
    table.insert(self._cron, job)
    --TODO save these somehow if possible, so they can be rebuilt
    return job
end

function Computer:update(dt, seconds)
    for _,program in pairs(self._programs) do
        if program.update then program:update(dt, seconds) end
    end

    log("--- CRON JOBS UPDATING ---") --NOTE debug
    for index,job in ipairs(self._cron) do
        log(index, job) --NOTE debug
        if job and job:update(seconds) then
            table.remove(self._cron, index)
        end
    end
    log("--- CRON JOBS DONE UPDATING ---") --NOTE debug
end

function Computer:hideAll()
    for _,program in pairs(self._programs) do
        if program.hide and program:isOpen() then program:hide() end
    end
end

function Computer:closeAll()
    for _,program in pairs(self._programs) do
        if program.close then program:close() end
    end
end

local defaultSavePath = "save/default/"
local defaultSaveFile = "computer.lua"

function Computer:save(file, path)
    if not path then path = defaultSavePath end
    if not file then file = defaultSaveFile end

    local programNames = {}
    for name,program in pairs(self._programs) do
        if program.save then program:save(path .. name .. ".lua") end
        table.insert(programNames, name)
    end

    local userNames = {}
    for user,data in pairs(self._users) do
        data:save(path .. "users/" .. user .. ".lua")
        table.insert(userNames, user)
    end

    local data = serialize{
        os = self.os,
        programs = programNames,
        users = userNames
    }

    save(path .. file, data)

    --Old Save Updating--

    --Prototype
    local fs = love.filesystem
    if fs.exists(path .. "user.lua") then
        fs.remove(path .. "user.lua") --old single-user save location
    end
end

function Computer:load(file, path)
    if not path then path = defaultSavePath end
    if not file then file = defaultSaveFile end

    local data = load(path .. file)

    if data == nil then
        --TODO ERROR MESSAGE
    elseif data then
        self.os = data.os
        for _,name in ipairs(data.programs) do
            --self:addProgram(name)
            local program = self:getProgram(name, true)
            if program.load then program:load(path .. name .. ".lua") end
            self._programs[name] = program
        end
        self.firstRun = false --if we successfully loaded, this obviously isn't the first run

        --Old Save Updating--

        --Prototype
        if not data.users then
            local user = User()
            user:load(path .. "user.lua")
            self._users[user:getUsername()] = user
        else
            for _,name in ipairs(data.users) do
                local user = User()
                user:load(path .. "users/" .. name .. ".lua")
                self._users[name] = user
            end
        end
    else
        --TODO some sort of flag so user is warned when overwriting save after failed load
        --defaults...so nothing is changed
    end
end

return Computer
