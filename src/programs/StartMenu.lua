local class = require "lib.middleclass"
local Program = require "programs.Program"
local lf = require "lib.LoveFrames"
local lg = love.graphics
local beholder = require "lib.beholder"
local computer = computer

local StartMenu = class("StartMenu", Program)

function StartMenu:initialize()
    Program.initialize(self)
    self:setProgramName("Start Menu")
    self:setIcon("images/DefaultStartMenuIcon.png")

    self._programs = {}
end

function StartMenu:addProgram(program)
    table.insert(self._programs, program)
end

function StartMenu:removeProgram(program)
    for i=1,#self._programs do
        if self._programs[i] == program then
            table.remove(self._programs, i)
            break
        end
    end
end

function StartMenu:open()
    if not self._open then
        self.mainLF = lf.Create("imagebutton")
        self.mainLF:SetText("")
        self.mainLF:SetImage(self._icon)
        self.mainLF:SizeToImage()

        self.mainLF.OnClick = function()
            local menu = lf.Create("menu")

            for i=1,#self._programs do
                local program = self._programs[i]
                menu:AddOption(program:getProgramName(), program:getIcon(), function() program:Open() end)
            end

            local taskbar = computer:getProgram("Taskbar", false)

            menu:AddOption("Log Out", "images/DefaultLogOutButtonIcon.png", function()
                --TODO closes anything open, and opens LogInProgram

                computer:closeAll()

                if taskbar then
                    taskbar:open()
                    computer:getProgram("ClockProgram", true):open()
                    computer:getProgram("LogInProgram", true):open()
                end

                beholder.trigger("StartMenu", "logged out")
            end)

            local taskbarHeight = 0
            if taskbar then
                taskbarHeight = taskbar:getHeight()
            end

            local _, h = menu:GetSize()
            menu:SetPos(0, lg.getHeight() - taskbarHeight - h*(#self._programs+1))
        end
        computer:getProgram("Taskbar", true):setStartButton(self.mainLF) --TODO refactor this shit

        self._open = true
    end
end

function StartMenu:show()
    if self._open then
        self.mainLF:SetVisible(true)
    end
end

function StartMenu:hide()
    if self._open then
        self.mainLF:SetVisible(false)
    end
end

function StartMenu:close()
    if self._open then
        self.mainLF:Remove()

        self._open = false
    end
end

return StartMenu
