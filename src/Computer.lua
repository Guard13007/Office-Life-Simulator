local class = require "lib.middleclass"
local beholder = require "lib.beholder"
local cron = require "lib.cron"
local serialize = require "lib.ser"

local load = require "util.load"
local save = require "util.save"
local log = require "util.log"

local Computer = class("Computer")

function Computer:initialize(OS, Programs)
    self.os = OS or {               --just access directly as needed
        name = "Doors OS 2",
        publisher = "Titanhard LTD"
    }

    self._cron = {}                 --stores timed tasks to be completed
    self._programs = Programs or {} --table of references

    self._observeLogIn = beholder.observe("LogInProgram", "logged in", function()
        self:getProgram("StartMenu", true):open()
        self:getProgram("ProductivityTrackerProgram", true):open()
    end)
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

    local data = serialize{
        os = self.os,
        programs = programNames
    }

    save(path .. file, data)
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
        end
    else
        --TODO some sort of flag so user is warned when overwriting save after failed load
        --defaults...so nothing is changed
    end
end

return Computer
