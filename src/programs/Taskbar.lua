local class = require "lib.middleclass"
local Program = require "programs.Program"
local lf = require "lib.LoveFrames"
local lg = love.graphics

local Taskbar = class("Taskbar", Program)

function Taskbar:initialize()
    Program.initialize(self)
    self:setProgramName("Taskbar")

    self._startButton = nil
    self._clockButton = nil

    self._programs = {}
    self._items = {}

    self._divider = lf.Create("panel")
    self._divider:SetVisible(false)

    self._height = 16
end

function Taskbar:setHeight(height)
    self._height = height

    if self._open then
        --TODO IMPLEMENT ACTUAL CHANGE
    end
end

function Taskbar:getHeight()
    return self._height
end

function Taskbar:addProgram(program)
    -- TODO replace with a panel with an image button and button next to each other?? would be ugly probably :/
    local button = lf.Create("button")
    button:SetSize(lg.getFont():getWidth(program:getProgramName()), self._height)
    button:SetText(program:getProgramName())
    button:SetProperty("Program", program) --reference saved so it can be found and removed
    button:SetVisible(false) --all start invisible, will be fixed in rebuild_list if appropriate

    button.OnClick = function()
        program.mainLF:SetVisible(not program.mainLF:GetVisible())
    end

    table.insert(self._programs, button)
    self:rebuild_list()
end

function Taskbar:removeProgram(program)
    for i=1,#self._programs do
        if self._programs[i]:GetProperty("Program") == Program then
            table.remove(self._programs, i)
            break
        end
    end

    self:rebuild_list()
end

function Taskbar:addItem(item)
    --TODO make addItem accept a reference to a program, and create an image button itself,
    --     instead of just accepting an already created button
    table.insert(self._items, item.mainLF)
    self:rebuild_list()
end

function Taskbar:removeItem(item)
    for i=1,#self._items do
        if self._items[i] == item then
            table.remove(self._items, i)
            break
        end
    end

    self:rebuild_list()
end

function Taskbar:setStartButton(button)
    self._startButton = button
    self:rebuild_list()
end

function Taskbar:getStartButton()
    return self._startButton
end

function Taskbar:setClockButton(button)
    self._clockButton = button
    self:rebuild_list()
end

function Taskbar:getClockButton()
    return self._clockButton
end

function Taskbar:rebuild_list()
    if self._open then
        -- clear list
        self.mainLF:Clear()

        -- get width of internals
        local width = 0
        if self._startButton then
            width = width + self._startButton:GetSize()
        end
        for i=1,#self._programs do
            width = width + self._programs[i]:GetSize()
        end
        for i=1,#self._items do
            width = width + self._items[i]:GetSize()
        end
        if self._clockButton then
            width = width + self._clockButton:GetSize()
        end

        -- get width needed for divider
        width = lg.getWidth() - width
        if width > 0 then
            self._divider:SetVisible(true)
            self._divider:SetSize(width, self._height)
        else
            self._divider:SetVisible(false)
        end

        -- actually rebuild list
        if self._startButton then
            self.mainLF:AddItem(self._startButton)
        end
        for i=1,#self._programs do
            self.mainLF:AddItem(self._programs[i])
        end
        if self._divider:GetVisible() then
            self.mainLF:AddItem(self._divider)
        end
        for i=1,#self._items do
            self.mainLF:AddItem(self._items[i])
        end
        if self._clockButton then
            self.mainLF:AddItem(self._clockButton)
        end
    end
end

function Taskbar:open()
    if not self._open then
        self.mainLF = lf.Create("list")
        self.mainLF:SetDisplayType("horizontal")
        self.mainLF:SetSize(lg.getWidth(), self._height)
        self.mainLF:SetPos(0, lg.getHeight() - self._height)

        self.mainLF.Update = function(self)
            self:MoveToTop()
        end

        self:rebuild_list()

        self._open = true
    end
end

function Taskbar:show()
    if self._open then
        self.mainLF:SetVisible(true)
    end
end

function Taskbar:hide()
    if self._open then
        self.mainLF:SetVisible(false)
    end
end

function Taskbar:close()
    if self._open then
        self.mainLF:Clear()
        self.mainLF:Remove()

        -- null references, not sure if good idea
        self._startButton = nil
        self._clockButton = nil
        self._programs = {}
        self._items = {}
        self._divider = nil

        self._open = false
    end
end

return Taskbar
