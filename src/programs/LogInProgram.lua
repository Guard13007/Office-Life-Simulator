local class = require "lib.middleclass"
local Program = require "programs.Program"
local lf = require "lib.LoveFrames"
--local lg = love.graphics
local beholder = require "lib.beholder"
local computer = computer

local LogInProgram = class("LogInProgram", Program)

function LogInProgram:initialize()
    Program.initialize(self)

    self._programName = "Log In"

    self._username = nil
    self._password = nil
    self._logInButton = nil
end

function LogInProgram:open()
    if not self._open then
        self.mainLF = lf.Create("frame")

        self.mainLF:SetName(computer.os.name .. " | Log In")
        self.mainLF:SetIcon(self._icon)
        self.mainLF:SetDraggable(false)
        self.mainLF:ShowCloseButton(false) --pretty sure I wanted to make this a quit button!
        self.mainLF:SetResizable(false)
        --self.mainLF:SetAlwaysOnTop(true) --shit went wrong with prompts when this was used
        self.mainLF:SetSize(210, 120) --TODO stop hardcoding
        self.mainLF:Center()

        local function textChanged(self, textEntered, switchTo)
            if textEntered == "tab" then
                local text = self:GetText()
                self:SetText(text:sub(1, -9)) --remove the tab spaces
                self:SetFocus(false) --apparently involved in bug?? wat?
                switchTo:SetFocus(true)
            end
        end

        self._username = lf.Create("textinput", self.mainLF)
        self._username:SetPos(5, 30)
        self._username:SetFocus(true)
        self._username:SetPlaceholderText("Username")

        self._password = lf.Create("textinput", self.mainLF)
        self._password:SetPos(5, 60)
        self._password:SetMasked(true)
        self._password:SetPlaceholderText("Password")

        self._username.OnTextChanged = function(s, text) textChanged(s, text, self._password) end
        self._password.OnTextChanged = function(s, text) textChanged(s, text, self._username) end

        self._logInButton = lf.Create("button", self.mainLF)
        self._logInButton:SetPos(65, 90) --TODO stop hardcoding
        self._logInButton:SetText("Log In")

        local function submit()
            local function logInError(message)
                local frame = lf.Create("frame")
                frame:SetName("Failed to log in.")
                frame:SetDraggable(false)
                frame:SetAlwaysOnTop(true) --somehow made it impossible to close? Oo
                frame:Center()

                local list = lf.Create("list", frame)
                list:SetPos(5, 30)
                local frameWidth, frameHeight = frame:GetSize()
                list:SetSize(frameWidth - 10, frameHeight - (35+30)) --TODO stop using magic numbers
                list:SetPadding(5)

                local text = lf.Create("text", list)
                text:SetText(message)

                local button = lf.Create("button", frame)
                button:SetText("Try Again")
                local buttonWidth, _ = button:GetSize()
                button:SetPos(frameWidth/2 - buttonWidth/2, frameHeight - 30)

                button.OnClick = function()
                    button:Remove()
                    text:Remove()
                    list:Remove()
                    frame:Remove()
                end
            end

            --
end

--[[
        if self.User:getUsername() == "" and self.username:GetText() == "" then
            logInError("You need to choose a username!\n\n(This will also be how you load a saved game.)")
            return
        end
        if self.User:getPassword() == "" and self.password:GetText() == "" then
            logInError("You need to choose a password!\n\n(This will also be how you load a saved game.)")
            return
        end
        if self.User:getUsername() == self.username:GetText() then
            if self.User:getPassword() == self.password:GetText() then
                beholder.trigger("LogInProgram", "logged in")
                self:Close()
            else
                -- this condition shouldn't be possible but hey, the first time I tried to test this, I ended up needing it
                -- it is possible because "" == "" I need to rewrite this whole thing!
                if self.User.password == "" then
                    self.User.password = self.password:GetText()
                    beholder.trigger("LogInProgram", "logged in")
                    self:Close()
                else
                    self.password:SetText("")
                    logInError("Invalid password!")
                end
            end
        else
            if self.User.username == "" then
                self.User:setUsername(self.username:GetText())
                self.User:setPassword(self.password:GetText())
                beholder.trigger("LogInProgram", "logged in")
                self:Close()
            else
                --NOTE BUG: Somehow this condition is triggered with a null username input by user.
                self.username:SetText("")
                logInError("Invalid username!\n\n(In the future, this would simply create a new save.)")
            end
        end
        --]-]
    end

    self.logInButton.OnClick = submit
    self.logInButton.OnEnter = submit

    self.open = true
end

---[[
function LogInProgram:Show()
    if self.open then
        self.mainLF:SetVisible(true)
    else
        print("LogInProgram tried to Show when not open.")
    end
end

function LogInProgram:Hide()
    if self.open then
        self.mainLF:SetVisible(false)
    else
        print("LogInProgram tried to Hide when not open.")
    end
end
--]-]

function LogInProgram:Close()
    if self:isOpen() then
        self.logInButton:Remove()
        self.password:Remove()
        self.username:Remove()
        self.mainLF:Remove()
        --self.mainLF = false --just in case?

        self.open = false
    end
end
]]

return LogInProgram
