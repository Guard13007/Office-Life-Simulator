local class = require "lib.middleclass"
local serialize = require "lib.ser"
local filesystem = love.filesystem
local load = require "util.load"

local Clock = class('Clock')

function Clock:initialize(clockTime)
    self._realStartTime = os.time()
    self._lastRealStartTime = self._realStartTime
    self._realPlayTime = 0

    if clockTime then
        -- this is so we can pass a Clock object or Unix time in seconds
        if type(clockTime) == "number" then
            self._startTime = clockTime
        else
            self._startTime = clockTime:getTime()
        end
    else
        self._startTime = self._realStartTime
    end
    self._time = self._startTime
end

function Clock:getRealStartTime()
    return self._realStartTime
end

function Clock:getLastRealStartTime()
    return self._lastRealStartTime
end

function Clock:getRealPlayTime()
    return self._realPlayTime + (os.time() - self._lastRealStartTime)
end

function Clock:getStartTime()
    return self._startTime
end

function Clock:setDate(value)
    -- accepts Clock objects or Unix time (in seconds)
    if value then
        if type(value) == "number" then
            self._time = value
        else
            self._time = value:getTime()
        end
    end
end

-- NOTE hopefully works as intended / a good compromise
--  this should be replaced?
function Clock:getDate(seconds)
    if seconds then
        return os.date("*t", seconds)
    else
        return self._time
    end
end

function Clock:setTime(value)
    -- accepts Clock objects or Unix time (in seconds)
    if value then
        if type(value) == "number" then
            self._time = value
        else
            self._time = value:getTime()
        end
    end
end

-- NOTE hopefully works as intended / a good compromise
--  this should be replaced?
function Clock:getTime(seconds)
    if seconds then
        return os.date("*t", seconds)
    else
        return self._time
    end
end

function Clock:getPrettyDate(seconds)
    if not seconds then seconds = self._time end
    return os.date("%Y/%m/%d", seconds)
end

function Clock:getPrettyTime(seconds)
    if not seconds then seconds = self._time end
    return os.date("%H:%M", seconds)
end

function Clock:update(seconds)
    if not seconds then seconds = 1 end
    self._time = self._time + seconds
end

local defaultSaveFile = "save/default/clock.lua"

function Clock:save(file)
    if not file then file = defaultSaveFile end
    local data = {
        realStartTime = self._realStartTime,
        --self._lastRealStartTime does not need to be saved
        realPlayTime = self._realPlayTime + (os.time() - self._lastRealStartTime),
        startTime = self._startTime,
        time = self._time
    }
    data = serialize(data)
    --create dir / write data
    if file:find("^.+/") then
        local fdir = file:sub(file:find("^.+/"))
        filesystem.createDirectory(fdir)
    end
    filesystem.write(file, data)
end

function Clock:load(file)
    if not file then file = defaultSaveFile end
    if filesystem.exists(file) then
        local data = load(file)
        self._realStartTime = data.realStartTime
        --self._lastRealStartTime doesn't need to be modified
        self._realPlayTime = data.realPlayTime
        self._startTime = data.startTime
        self._time = data.time
    end
end

return Clock
