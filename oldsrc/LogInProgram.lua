local class = require "lib.middleclass"
local Program = require "Program"
local lf = require "lib.LoveFrames"
local beholder = require "lib.beholder"

local LogInProgram = class('LogInProgram', Program)

function LogInProgram:initialize(computer, user)
    Program.initialize(self)
    self.programName = "Log In"
    --self.icon = "images/LogInProgramIconDefault.png"

    self.Computer = computer
    self.User = user or computer.User
end

function LogInProgram:SetComputer(computer)
    self.Computer = computer
    if self.open then
        self.mainLF:SetName(self.Computer:getOS().name .. " | Log In")
    end
end

function LogInProgram:GetComputer()
    return self.Computer
end

function LogInProgram:SetUser(user)
    self.User = user
end

function LogInProgram:GetUser()
    return self.User
end

function LogInProgram:Open()
    if self.open then
        print("LogInProgram tried to open when already open.")
        return
    end
    self.mainLF = lf.Create("frame")

    if self.Computer then
        self.mainLF:SetName(self.Computer:getOS().name .. " | Log In")
    else
        self.mainLF:SetName("Log In")
    end

    self.mainLF:SetIcon(self.icon)
    self.mainLF:SetDraggable(false)
    self.mainLF:ShowCloseButton(false)
    self.mainLF:SetResizable(false)
    --self.mainLF:SetAlwaysOnTop(true) --shit goes wrong if this is left on and we use that on the invalid prompts xD
    self.mainLF:SetSize(210, 120)
    self.mainLF:Center()

    local function textChanged(self, textEntered, switchTo)
        if textEntered == "tab" then
            local text = self:GetText()
            self:SetText(text:sub(1, -9))
            --self:SetFocus(false) -- NOTE TESTING IF TURNING THIS OFF FIXES THAT ONE BUG
            switchTo:SetFocus(true)
        end
    end

    self.username = lf.Create("textinput", self.mainLF)
    self.username:SetPos(5, 30)
    self.username:SetFocus(true)
    --self.username:SetTabReplacement("") --removed to make OnTextChanged work with switching focus
    self.username:SetPlaceholderText("Username")

    self.password = lf.Create("textinput", self.mainLF)
    self.password:SetPos(5, 60)
    --self.password:SetTabReplacement("")
    self.password:SetMasked(true)
    self.password:SetPlaceholderText("Password")

    self.username.OnTextChanged = function(s, text) textChanged(s, text, self.password) end
    self.password.OnTextChanged = function(s, text) textChanged(s, text, self.username) end

    self.logInButton = lf.Create("button", self.mainLF)
    self.logInButton:SetPos(65, 90)
    self.logInButton:SetText("Log In")

    local function submit()
        -- TODO this whole section needs refactoring
        ---[[
        if not self.User then
            error("LogInProgram does not have a User set.")
        end
        local function logInError(errorText)
            --error popup
            local frame = lf.Create('frame')
            frame:SetName("Failed to Log In")
            frame:SetDraggable(false)
            frame:SetResizable(false)
            --frame:SetAlwaysOnTop(true) -- this somehow makes it impossible to close, dafuq?
            frame:Center()

            local list = lf.Create('list', frame)
            list:SetPos(5, 30)
            local frameWidth, frameHeight = frame:GetSize()
            list:SetSize(frameWidth - 10, frameHeight - (35+30))
            list:SetPadding(5)

            local text = lf.Create('text', list)
            text:SetText(errorText)

            local button = lf.Create('button', frame)
            button:SetText("Try Again")
            --button:Center()
            --local w, _ = button:GetPos() -- for some reason, w ends up 0
            local buttonWidth, _ = button:GetSize()
            button:SetPos(frameWidth/2 - buttonWidth/2, frameHeight - 30)
            button.OnClick = function()
                button:Remove()
                text:Remove()
                list:Remove()
                frame:Remove()
            end
        end
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
        --]]
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
--]]

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

return LogInProgram
