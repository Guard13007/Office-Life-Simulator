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
                --don't forget to return after calling this... o.o
            end

            local function logIn()
                beholder.trigger("LogInProgram", "logged in")
                self:close()
                --don't forget to return after calling this... o.o
            end

            if (self._username:GetText() == "") or (self._password:GetText() == "") then
                logInError("You need to enter a username and/or password!")
                return
            end

            if computer:usersExist() then
                local user = computer:getUser(User.static.sanitize(self._username:GetText()))
                if user:getPassword() == "" then
                    -- this user didn't exist (because there ARE users, just not this one)
                    computer:removeUser(user:getSanitizedUsername())
                    logInError("Invalid username and/or password!")
                    return
                else
                    -- this user exists, check password
                    if self._password:GetText() == user:getPassword() then
                        logIn()
                        return
                    else
                        logInError("Invalid username and/or password!")
                        return
                    end
                end
            else
                -- this user doesn't exist, create them (by getting them from computer), then set their password
                local user = computer:getUser(User.static.sanitize(self._username:GetText()))
                user:setPassword(self._password:GetText())
                logIn()
            end
        end

        self._logInButton.OnClick = submit
        self._logInButton.OnEnter = submit

        self._open = true
    end
end

function LogInProgram:show()
    if self._open then
        self.mainLF:SetVisible(true)
    end
end

function LogInProgram:hide()
    if self._open then
        self.mainLF:SetVisible(false)
    end
end

function LogInProgram:close()
    if self._open then
        self._logInButton:Remove()
        self._password:Remove()
        self._username:Remove()
        self.mainLF:Remove()

        self._open = false
    end
end

return LogInProgram
