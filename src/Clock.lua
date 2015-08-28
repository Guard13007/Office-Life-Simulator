local class = require "lib.middleclass"
local serialize = require "lib.ser"

local load = require "util.load"
local save = require "util.save"

local Clock = class("Clock")

function Clock:initialize(time)
    self._realStartTime = os.time()
    self._lastRealStartTime = self.realStartTime
    self._realPlayTime = 0

    -- accepts Clock objects or Unix time (in seconds)
    if time then
        if type(time) == "number" then
            self._startTime = time
        else
            self._startTime = time:getTime()
        end
    else
        self._startTime = self._realStartTime
    end

    self._time = self._startTime
end

function Clock:update(seconds)
    if not seconds then seconds = 1 end
    self._time = self._time + seconds
end

function Clock:setTime(time)
    assert(time, "called Clock:setTime() with a false (or nil) time")

    -- accepts Clock objects or Unix time (in seconds)
    if time then
        if type(time) == "number" then
            self._time = time
        else
            self._time = time:getTime()
        end
    end
end

function Clock:getTime()
    return self._time
    --[[ NOTE used to contain alternate functionality:
    -> if a seconds value is passed,
    return os.date("*t", seconds)
    TODO IMPLEMENT ELSEWHERE, as util / DO IT WHERE NEEDED INSTEAD OF WRAPPING IT IN SOMETHING UNRELATED
    ]]
end

function Clock:getPrettyTime(seconds)
    if not seconds then seconds = self._time end
    return os.date("%H:%M", seconds)
end

function Clock:getPrettyDate(seconds)
    if not seconds then seconds = self._time end
    return os.date("%Y/%m/%d", seconds)
end

function Clock:getStartTime()
    return self._startTime
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

local defaultSaveFile = "clock.lua"

function Clock:save(file)
    if not file then file = defaultSaveFile end

    local data = {
        realStartTime = self._realStartTime,
        realPlayTime = self._realPlayTime + (os.time() - self._lastRealStartTime),
        startTime = self._startTime,
        time = self._time
    }

    save(file, serialize(data))
end

function Clock:load(file)
    if not file then file = defaultSaveFile end

    data = load(file)

    if data == nil then
        --TODO ERROR MESSAGE
    elseif data then
        self._realStartTime = data.realStartTime
        self._realPlayTime = data.realPlayTime
        self._startTime = data.startTime
        self._time = data.time
    else
        --TODO some sort of flag so user is warned when overwriting save after failed load
    end
end

return Clock
