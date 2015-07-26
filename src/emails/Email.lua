local class = require "lib.middleclass"
local serialize = require "lib.ser"

local load = require "util.load"
local save = require "util.save"

local Email = class("Email")

function Email:initialize(data, time)
    if data then
        self._subject = data.subject
        self._from = data.from
        self._text = data.text
        self._time = data.time
        self._type = data.type
    else
        self._subject = "Invalid Email"
        self._from = "Nobody"
        self._text = "Nothing."
        self._time = 0
        self._type = "Unknown"
    end

    -- accepts Clock objects or Unix time (in seconds)
    if time then
        if type(time) == "number" then
            self._time = time
        else
            self._time = time:getTime()
        end
    end
end

function Email:setSubject(subject)
    self._subject = subject
end
function Email:getSubject()
    return self._subject
end

function Email:setFrom(from)
    self._from = from
end
function Email:getFrom()
    return self._from
end

function Email:setText(text)
    self._text = text
end
function Email:getText()
    return self._text
end

function Email:setTime(time)
    -- accepts Clock objects or Unix time (in seconds)
    if time then
        if type(time) == "number" then
            self._time = time
        else
            self._time = time:getTime()
        end
    end
end
function Email:getTime()
    return self._time
end

function Email:setType(type)
    self._type = type
end
function Email:getType()
    return self._type
end

local defaultSaveFile = "email.lua"

-- ":return:" file means the raw data will be returned instead of saved to file
function Email:save(file)
    if not file then file = defaultSaveFile end

    local data = {
        subject = self._subject,
        from = self._from,
        text = self._text,
        time = self._time,
        type = self._type
    }

    if file == ":return:" then
        return data
    else
        save(file, serialize(data))
    end
end

-- can load from table of data as well as file
function Email:load(file)
    if not file then file = defaultSaveFile end

    if type(file) == "table" then
        data = file
    else
        data = load(file)
    end

    if data == nil then
        --TODO ERROR MESSAGE
    elseif data then
        self._subject = data.subject
        self._from = data.from
        self._text = data.text
        self._time = data.time
        self._type = data.type
    else
        --TODO some sort of flag so user is warned when overwriting save after failed load
    end
end

return Email
