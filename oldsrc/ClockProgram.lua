local class = require "lib.middleclass"
local Program = require "Program"
local lf = require "lib.LoveFrames"
local lg = love.graphics

local ClockProgram = class('ClockProgram', Program)

function ClockProgram:initialize(computer, clock, taskbar)
    Program.initialize(self)
    self._programName = "Clock"
    --self._icon = "images/ClockProgramIconDefault.png"

    self._Computer = computer
    self._Clock = clock or computer.Clock
    self._Taskbar = taskbar or computer.Taskbar

    self._width = 60
    self._height = 18
end

function ClockProgram:setWidth(width)
    self._width = width
    if self:isOpen() then
        self:getMainLF():SetSize(self._width, self._height)
    end
end

function ClockProgram:getWidth()
    return self._width
end

function ClockProgram:setHeight(height)
    self._height = height
    if self.isOpen() then
        self:getMainLF():SetSize(self._width, self._height)
    end
end

function ClockProgram:getHeight()
    return self._height
end

function ClockProgram:setDate(...)
    if self._Clock then
        return self._Clock:setDate(...)
    end
end

function ClockProgram:getDate(...)
    if self._Clock then
        return self._Clock:getDate(...)
    end
end

function ClockProgram:setTime(...)
    if self._Clock then
        return self._Clock:setTime(...)
    end
end

function ClockProgram:getTime(...)
    if self._Clock then
        return self._Clock:getTime(...)
    end
end

function ClockProgram:getPrettyDate(...)
    if self._Clock then
        return self._Clock:getPrettyDate(...)
    end
end

function ClockProgram:getPrettyTime(...)
    if self._Clock then
        return self._Clock:getPrettyTime(...)
    end
end

function ClockProgram:update(seconds)
    if seconds then
        if self._Clock then
            self._Clock:update(seconds)
            self._text:SetText(self._Clock:getPrettyTime())
        end
    end
end

function ClockProgram:SetComputer(computer)
    self._Computer = computer
end

function ClockProgram:GetComputer()
    return self._Computer
end

function ClockProgram:SetClock(clock)
    self._Clock = clock
end

function ClockProgram:GetClock()
    return self._Clock
end

function ClockProgram:SetTaskbar(taskbar)
    self._Taskbar = taskbar
end

function ClockProgram:GetTaskbar()
    return self._Taskbar
end

function ClockProgram:Open()
    if self:isOpen() then
        print("ClockProgram tried to open when already open.")
        return
    end
    self:setMainLF(lf.Create("panel"))
    self:getMainLF():SetSize(self._width, self._height)

    self._text = lf.Create("text", self:getMainLF())
    if self._Clock then
        self._text:SetText(self._Clock:getPrettyTime())
    end
    self._text:Center()

    if self._Taskbar then self._Taskbar:SetClockProgram(self) end

    self._open = true
end

function ClockProgram:Show()
    if self:isOpen() then
        self:getMainLF():SetVisible(true)
    else
        print("ClockProgram tried to Show when not open.")
    end
end

function ClockProgram:Hide()
    if self:isOpen() then
        self:getMainLF():SetVisible(false)
    else
        print("ClockProgram tried to Hide when not open.")
    end
end

function ClockProgram:Close()
    if self:isOpen() then
        self._text:Remove()
        self:getMainLF():Remove()

        self._open = false
    end
end

return ClockProgram
