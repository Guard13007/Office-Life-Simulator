local class = require "lib.middleclass"
--local lf = require "lib.LoveFrames"
local beholder = require "lib.beholder"
local cron = require "lib.cron"
local serialize = require "lib.ser"
local filesystem = love.filesystem
local load = require "util.load"
local inspect = require "lib.inspect" -- NOTE DEBUG

local Computer = class('Computer')

function Computer:initialize()
    self._os = {
        name = "Doors OS 2",
        publisher = "Titanhard LTD"
    }
    self._cronJobs = {} --internal, no set/get

    --no set/get, should not be accessed
    self._observe_log_in = beholder.observe("LogInProgram", "logged in", function()
        self._StartMenu:Open()
        --self._EmailProgram:Open()
        self._ProductivityTrackerProgram:Open()
        --self._PatchNotesProgram:Open()
    end)

    --overwritten by loading a save, bool if game has been run before
    self.firstGameRun = true -- NO SETTER/GETTER
end

function Computer:update(dt, seconds)
    self._ClockProgram:update(seconds)

    --TODO verify this loop (with it conditionally modifying itself) works correctly
    for i=1,#self._cronJobs do
        if self._cronJobs[i] and self._cronJobs[i]:update(seconds) then --cron.lua jobs return true if expired
            table.remove(self._cronJobs, i)
            i = i - 1                            -- make sure we don't skip one
        end
    end
end

function Computer:after(...)
    local job = cron.after(...)
    table.insert(self._cronJobs, job)
    --print("DEBUG Computer : NEW CRONJOB: (line 153)", inspect(job))
    --  data that needs to be saved from a cron job are it's callback function, running val, and time val
    --we can't serialize certain references and functions, so we can't properly save these
    --  SO I need a special saveable version of this (especially since right now, this is only used for "Hey you're doing it wrong." emails right now, which would be really easy to rebuild)
    return job
end

function Computer:CloseAll()
    self._LogInProgram:Close()
    self._Taskbar:Close()
    self._ClockProgram:Close()
    self._StartMenu:Close()
    self._EmailProgram:Close()
    self._ProductivityTrackerProgram:Close()
    self._PatchNotesProgram:Close()
end

local defaultSavePath = "save/default/"
local defaultSaveFile = "computer.lua"

function Computer:save(file, path)
    --if not path then path = "save/" .. self._User:getSanitizedUsername() .. "/" end
    if not path then path = defaultSavePath end
    self._User:save(path .. "user.lua")
    self._Clock:save(path .. "clock.lua")
    self._EmailProgram:save(path .. "emailProgram.lua")
    self._ProductivityTrackerProgram:save(path .. "productivityTrackerProgram.lua")

    if not file then file = defaultSaveFile end
    local data = {
        os = self._os,
        --somehow save cron jobs and state of computer
        firstGameRun = false
    }
    data = serialize(data)
    --create dir / write data
    if file:find("^.+/") then
        local fdir = file:sub(file:find("^.+/"))
        filesystem.createDirectory(fdir)
    end
    filesystem.write(file, data)
end

function Computer:load(file, path)
    if not path then path = defaultSavePath end
    self._User:load(path .. "user.lua")
    self._Clock:load(path .. "clock.lua")
    self._EmailProgram:load(path .. "emailProgram.lua")
    self._ProductivityTrackerProgram:load(path .. "productivityTrackerProgram.lua")

    if not file then file = defaultSaveFile end
    if filesystem.exists(file) then
        local data = load(file)
        self._os = data.os
        self.firstGameRun = false
    end
end

return Computer
