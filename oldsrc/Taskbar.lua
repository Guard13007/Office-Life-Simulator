local class = require "lib.middleclass"
local Program = require "Program"
local lf = require "lib.LoveFrames"
local lg = love.graphics

local Taskbar = class('Taskbar', Program)

-- NOTE Taskbar needs to be looked at very carefully, it seems to be non-standard in several places?

function Taskbar:initialize(computer, startMenu)
    Program.initialize(self)
    self._programName = "Taskbar"
    --self._icon = "images/TaskbarIconDefault.png"

    --self.Computer = computer --NOTE not being used right now
    --self.startMenu = -- is set later
    --self.Computer = computer
    --self.startMenu = startMenu or computer.StartMenu
    -- NOTE those are going to error........as they would anywhere else I've done this

    self._height = 16
end

function Taskbar:getHeight()
    return self._height
end

function Taskbar:setHeight(height)
    --TODO IMPLEMENT ACTUALLY CHANING THE HEIGHT!!
    self._height = height
end

function Taskbar:create_divider()
    self.divider = lf.Create("panel")
end

function Taskbar:rebuild_list()
    self._mainLF:Clear() -- clear list to rebuild it

    -- Get width of internal objects
    local width = 0
    if self.startMenu then
        width = width + self.startMenu:GetSize()
    end
    for i=1,#self.programs do
        width = width + self.programs[i]:GetSize()
    end
    for i=1,#self.items do
        width = width + self.items[i]:GetSize()
    end
    if self.clockProgram then
        width = width + self.clockProgram:GetSize()
    end

    -- Get width of divider needed, create / resize / destroy as needed
    width = lg.getWidth() - width
    if width > 0 then
        if not self.divider then
            self:create_divider()
        end
        self.divider:SetSize(width, self._height)
    else
        if self.divider then
            self.divider:Remove()
            self.divider = nil -- unneeded ?
        end
    end

    -- Actually rebuild the list object
    if self.startMenu then
        self._mainLF:AddItem(self.startMenu)
    end
    for i=1,#self.programs do
        self._mainLF:AddItem(self.programs[i])
    end
    if self.divider then
        self._mainLF:AddItem(self.divider)
    end
    for i=1,#self.items do
        self._mainLF:AddItem(self.items[i])
    end
    if self.clockProgram then
        self._mainLF:AddItem(self.clockProgram)
    end
end

function Taskbar:AddItem(Item)
    table.insert(self.items, Item._mainLF)
    self:rebuild_list()
end

function Taskbar:RemoveItem(Item)
    for i=1,#self.items do
        if self.items[i] == Item then
            table.remove(self.items, i)
            break
        end
    end

    self:rebuild_list()
end

function Taskbar:AddProgram(Program)
    local button = lf.Create("button")
    button:SetSize(lg.getFont():getWidth(Program._programName), self._height)
    button:SetText(Program._programName)
    --button:SetIcon(Program.icon) --TODO make panel parent object here with a button and image button right next to each other ??
    button.OnClick = function()
        Program._mainLF:SetVisible(not Program._mainLF:GetVisible())
    end
    button:SetProperty("Program", Program) --this is so it can be found and removed

    table.insert(self.programs, button)
    self:rebuild_list()
end

function Taskbar:RemoveProgram(Program)
    for i=1,#self.programs do
        if self.programs[i]:GetProperty("Program") == Program then
            table.remove(self.programs, i)
            break
        end
    end

    self:rebuild_list()
end

function Taskbar:SetStartMenu(startMenu)
    self.startMenu = startMenu._mainLF
    self:rebuild_list()
end

function Taskbar:GetStartMenu()
    return self.startMenu
end

function Taskbar:SetClockProgram(clockProgram)
    self.clockProgram = clockProgram._mainLF
    self:rebuild_list()
end

--NOTE these functions do not check against _open
function Taskbar:Open()
    if self:isOpen() then
        print("Taskbar tried to open when already open.")
        return
    end

    self._mainLF = lf.Create("list")
    self._mainLF:SetDisplayType("horizontal")
    self._mainLF:SetSize(lg.getWidth(), self._height)
    self._mainLF:SetPos(0, lg.getHeight() - self._height)
    self._mainLF.Update = function(self)
        self:MoveToTop()
    end

    --self.startMenu = false
    self.programs = {}
    --self.divider = false
    self.items = {}
    --self.clockProgram = false

    self:create_divider()
    self:rebuild_list()

    self._open = true
end

function Taskbar:Show()
    self._mainLF:SetVisible(true)
end

function Taskbar:Hide()
    self._mainLF:SetVisible(false)
end

function Taskbar:Close()
    if self:isOpen() then
        self._mainLF:Clear()
        self._mainLF:Remove()

        self._open = false

        ---[[
        --remove all references (just in case)
        self.startMenu = nil
        self.programs = {}
        self.divider = nil
        self.items = {}
        self.clockProgram = nil
        --this probably completely breaks the Taskbar if it is called and then you try to recover the Taskbar in any way
        --]]
    end
end

return Taskbar
