local random = love.math.random
love.math.setRandomSeed(os.time())
random()

local class = require "lib.middleclass"
local serialize = require "lib.ser"
local filesystem = love.filesystem
local load = require "util.load"

local Email = class('Email')

function Email:initialize(data, clockTime)
    if data then
        self._subject = data.subject
        self._from = data.from
        self._text = data.text
        self._time = data.time
        self._type = data.type
    else
        self._subject = "Invalid Email"
        self._from = "Nobody"
        self._text = "Nothing"
        self._time = 0
        self._type = "Unknown"
    end

    -- this is so we can pass a clock object or Unix time in seconds
    if clockTime then
        if type(clockTime) == "number" then
            self._time = clockTime
        else
            self._time = clockTime:getTime()
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

function Email:setTime(clockTime)
    -- accepts Clock objects or Unix time (in seconds)
    if clockTime then
        if type(clockTime) == "number" then
            self._time = clockTime
        else
            self._time = clockTime:getTime()
        end
    end
end

function Email:getTime()
    return self._time
end

function Email:setType(emailType)
    self._type = emailType
end

function Email:getType()
    return self._type
end

-- defaults to ":return:" which means return the data that needs to be saved
function Email:save(file)
    if not file then file = ":return:" end
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
        data = serialize(data)
        --create dir / write data
        if file:find("^.+/") then
            local fdir = file:sub(file:find("^.+/"))
            filesystem.createDirectory(fdir)
        end
        filesystem.write(file, data)
    end
end

-- file is either a filename or a table of data
function Email:load(file)
    local data
    if type(file) ~= "table" then
        if filesystem.exists(file) then
            data = load(file)
        else
            error("Tried to load Email from non-existant file: " .. file)
        end
    else
        data = file
    end

    self._subject = data.subject
    self._from = data.from
    self._text = data.text
    self._time = data.time
    self._type = data.type
end

return Email
