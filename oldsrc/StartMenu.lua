local class = require "lib.middleclass"
local Program = require "Program"
local lf = require "lib.LoveFrames"
local lg = love.graphics
local beholder = require "lib.beholder"

local StartMenu = class('StartMenu', Program)

function StartMenu:initialize(computer, taskbar)
    Program.initialize(self)
    self._programName = "StartMenu"
    self._icon = "images/StartMenuIconDefault.png"

    self._Computer = computer
    self._Taskbar = taskbar or computer:GetTaskbar()

    self._programs = {}
end

function StartMenu:SetComputer(computer)
    self._Computer = computer
end

function StartMenu:GetComputer()
    return self._Computer
end

function StartMenu:SetTaskbar(taskbar)
    self._Taskbar = taskbar
end

function StartMenu:GetTaskbar()
    return self._Taskbar
end

--[[ TODO determine usefulness / how to work
function StartMenu:setPrograms(programs)
    self._programs = programs
end
--]]

-- not useful probably
function StartMenu:getPrograms()
    return self._programs
end

function StartMenu:AddProgram(Program)
    table.insert(self._programs, Program)
end

-- TODO RemoveProgram() need to be implemented somehow
function StartMenu:RemoveProgram(Program)
    for i=1,#self._programs do
        if self._programs[i] == Program then
            table.remove(self._programs, i)
            break
        end
    end
end

function StartMenu:Open()
    if self:isOpen() then
        print("StartMenu tried to open when alredy open.")
        return
    end

    self:setMainLF(lf.Create("imagebutton"))
    self:getMainLF():SetText("")
    self:getMainLF():SetImage(self._icon)
    self:getMainLF():SizeToImage()
    self:getMainLF().OnClick = function()
        local menu = lf.Create("menu")
        --menu:SetVisible(false)

        for i=1,#self._programs do
            menu:AddOption(self._programs[i]:getProgramName(), self._programs[i]:getIcon(), function()
                self._programs[i]:Open()
            end)
        end

        menu:AddOption("Log Out", "images/LogOutButtonIconDefault.png", function()
            -- TODO This closes out anything open (except Taskbar, Clock, ClockProgram). Opens the LogInProgram.
            self._Computer:CloseAll()
            self._Taskbar:Open()
            self._Computer:GetClockProgram():Open()
            self._Computer:GetLogInProgram():Open()

            beholder.trigger("StartMenu", "logged out")
        end)

        local _, h = menu:GetSize()
        menu:SetPos(0, lg.getHeight() - self._Taskbar:getHeight() - h*(#self._programs+1))

        --menu:SetVisible(true)
    end

    self._Taskbar:SetStartMenu(self)

    self._open = true
end

function StartMenu:Show()
    if self._open then
        self:getMainLF():SetVisible(true)
    else
        print("StartMenu tried to Show when not open.")
    end
end

function StartMenu:Hide()
    if self._open then
        self:getMainLF():SetVisible(false)
    else
        print("StartMenu tried to Hide when not open.")
    end
end

function StartMenu:Close()
    --TODO see if this needs to remove other references
    if self:isOpen() then
        self:getMainLF():Remove()

        self._open = false
    else
        print("StartMenu tried to close when already not open.")
    end
end

return StartMenu
