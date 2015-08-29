local class = require "lib.middleclass"
local Program = require "programs.Program"
local Clock = require "Clock"
local lf = require "lib.LoveFrames"
local lg = love.graphics

local ClockProgram = class("ClockProgram", Program)

function ClockProgram:initialize()
    Program.initialize(self)
    self:setProgramName("Clock")

    self._clock = Clock()
    self._text = nil

    self._width = 60
    self._height = 16
end

function ClockProgram:update(seconds)
    if seconds then
        if self._clock then
            self._clock:update(seconds)
            self._text:SetText(self._clock:getPrettyTime())
        end
    end
end

function ClockProgram:setTime(...)
    if self._clock then
        return self._clock:setTime(...)
    end
end

function ClockProgram:getTime(...)
    if self._clock then
        return self._clock:getTime(...)
    end
end

function ClockProgram:getPrettyTime(...)
    if self._clock then
        return self._clock:getPrettyTime(...)
    end
end

function ClockProgram:getprettyDate(...)
    if self._clock then
        return self._clock:getprettyDate(...)
    end
end

function ClockProgram:setClock(clock)
    self._clock = clock
end

function ClockProgram:getClock()
    return self._clock
end

function ClockProgram:setWidth(width)
    self._width = width
    if self._open then
        self.mainLF:SetSize(self._width, self._height)
    end
end

function ClockProgram:getWidth()
    return self._width
end

function ClockProgram:setHeight(height)
    self._height = height
    if self._open then
        self.mainLF:SetSize(self._width, self._height)
    end
end

function ClockProgram:getHeight()
    return self._height
end

function ClockProgram:save(...)
    if self._clock then
        return self._clock:save(...)
    end
end

function ClockProgram:load(...)
    if self._clock then
        return self._clock:load(...)
    end
end

--TODO previously open() added it to a Taskbar it knows about, this needs to be handled elsewhere
function ClockProgram:open()
    if not self._open then
        self.mainLF = lf.Create("panel")
        self.mainLF:SetSize(self._width, self._height)

        self._text = lf.Create("text", self.mainLF)
        if self._clock then
            self._text:SetText(self._clock:getPrettyTime())
        end
        self._text:Center()

        self._open = true
    end
end

function ClockProgram:show()
    if self._open then
        self.mainLF:SetVisible(true)
    end
end

function ClockProgram:hide()
    if self._open then
        self.mainLF:SetVisible(false)
    end
end

function ClockProgram:close()
    if self._open then
        self._text:Remove()
        self.mainLF:Remove()

        self._open = false
    end
end

return ClockProgram
