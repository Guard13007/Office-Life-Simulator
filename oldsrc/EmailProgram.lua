local class = require "lib.middleclass"
local Program = require "Program"
local lf = require "lib.LoveFrames"
local beholder = require "lib.beholder"
local inspect = require "lib.inspect"
local serialize = require "lib.ser"
local lume = require "lib.lume"
local lg = love.graphics
local filesystem = love.filesystem
local load = require "util.load"
local LoremIpsumEmail = require "LoremIpsumEmail" --NOTE where is this even used??
local Email = require "Email"

local EmailProgram = class('EmailProgram', Program)

function EmailProgram:initialize(computer, clock, user, taskbar, startMenu)
    Program.initialize(self)
    self._programName = "Macrohard Inseen"
    --self._icon = "images/EmailProgramIconDefault.png"

    self._Computer = computer
    self._Clock = clock or computer.Clock
    self._User = user or computer.User
    self._Taskbar = taskbar or computer.Taskbar
    self._StartMenu = startMenu or computer.StartMenu

    -- where Email object references are stored (non-numerically!)
    self._emails = {}
    -- where Email object references are stored that aren't in the first 16
    self._pending_emails = {}
    self._visible_emails = 0 --how many emails are currently visible
    self._email_count = 0 --how many total emails are here

    --NOTE these are internal, no getters/setters
    -- where email LF object headers (with UUIDs) are stored
    -- (so any open can be collapsed when another is opened)
    self._headers = {}
    -- size / position of mainLF when it is available
    self._frame = {
        size = {520, 600},
        pos = {20, 20}
    }

    self._StartMenu:AddProgram(self) --TODO ? fix the fact that we assume we have been passed a StartMenu ?
end

function EmailProgram:updateTitle()
    if self:getMainLF() then self:getMainLF():SetName(self._email_count .. " emails" .. " | " .. self._programName) end
end

function EmailProgram:add_pending_email()
    if #self._pending_emails > 0 then
        self:add_email(table.remove(self._pending_emails, 1))
    end
end

function EmailProgram:add_email(email)
    -- START DEBUG CODE
    local count = 0
    for k,v in pairs(self._emails) do
        count = count + 1
    end
    local pending = 0
    for k,v in pairs(self._pending_emails) do
        pending = pending + 1
    end
    print("Emails counted: " .. count+pending, "Reported email count: " .. self._email_count)
    print("Visible emails counted: " .. count, "Reported visible emails: " .. self._visible_emails)
    print("Pending emails counted: " .. pending)
    -- END DEBUG CODE

    self._email_count = self._email_count + 1
    self:updateTitle()
    if self._visible_emails >= 16 then
        table.insert(self._pending_emails, email)
        return
    else
        self._visible_emails = self._visible_emails + 1
    end

    local header = lf.Create("collapsiblecategory", self.list)
    header:SetText(email:getSubject() .. " | " .. email:getFrom())

    local list = lf.Create("list", header)
    list:SetPadding(5)
    list:SetSpacing(5)

    header:SetObject(list)

    local uuid = lume.uuid()
    header.OnOpenedClosed = function()
        if header:GetOpen() then
            print("DEBUG EmailProgram LINE 79, verifying email headers auto-close others (which doesn't work)")
            --collapse everything else
            for i=1,#self._headers do
                if not self._headers[i][1] == uuid then
                    self._headers[i][2]:SetOpen(false)
                end
            end
        end
    end
    table.insert(self._headers, {uuid, header})

    local text = lf.Create("text", list)
    text:SetText(email:getSubject() .. "\n  from: " .. email:getFrom() .. "\n  to:     " .. self:GetUser():getUsername() .. "\n  date: " .. self._Clock:getPrettyDate(email:getTime()) .. "\n  time:  " .. self._Clock:getPrettyTime(email:getTime()) .. "\n\n" .. email:getText())

    list:AddItem(text)

    local Close, button1, button2 --defined below, but needs reference here
    button1 = lf.Create("button", list)
    button2 = lf.Create("button", list)

    if email:getType() == "Story" then
        -- NOTE in future, Reply brings up textinput email sender thing where you can type whatever
        button1:SetText("Reply")
        list:AddItem(button1)

        -- NOTE in future, Delete just..deletes the email..like it does now
        button2:SetText("Delete")
        list:AddItem(button2)

        button1.OnClick = function()
            Close()
        end

        button2.OnClick = function()
            Close()
        end
    elseif email:getType() == "LoremIpsum" then
        button1:SetText("Lorem")
        list:AddItem(button1)

        button2:SetText("Ipsum")
        list:AddItem(button2)

        button1.OnClick = function()
            beholder.trigger("EmailProgram", "Lorem", email)
            Close()
        end

        button2.OnClick = function()
            beholder.trigger("EmailProgram", "Ipsum", email)
            Close()
        end
    end

    Close = function()
        self._emails[email] = nil

        for i=1,#self._headers do
            if self._headers[i][1] == uuid then
                table.remove(self._headers, i)
                break
            end
        end

        button2:Remove()
        button1:Remove()
        text:Remove()
        list:Remove()
        header:Remove()

        self.list:CalculateSize()
        self.list:RedoLayout()
        email = nil

        self._visible_emails = self._visible_emails - 1
        self._email_count = self._email_count - 1
        self:add_pending_email()
    end
end

function EmailProgram:receiveEmail(email)
    self._emails[email] = email

    if self._open then        -- Is this check needed? ... I don't care
        self:add_email(email)
    end
end

--[[
function EmailProgram:setEmails(emails)
    --TODO fuck this method
end
--]]

--[[
--NOTE is this even needed for anything?
function EmailProgram:getEmails()
    return self._emails
end
--]]

function EmailProgram:SetComputer(computer)
    self._Computer = computer
end

function EmailProgram:GetComputer()
    return self._Computer
end

function EmailProgram:SetClock(clock)
    self._Clock = clock
end

function EmailProgram:GetClock()
    return self._Clock
end

function EmailProgram:SetUser(user)
    self._User = user
end

function EmailProgram:GetUser()
    return self._User
end

function EmailProgram:SetTaskbar(taskbar)
    self._Taskbar = taskbar
end

function EmailProgram:GetTaskbar()
    return self._Taskbar
end

function EmailProgram:SetStartMenu(startMenu)
    self._StartMenu = startMenu
end

function EmailProgram:GetStartMenu()
    return self._StartMenu
end

-- NOTE: This will at least partially replace initialization in some manner possibly?
--         I need to decide how to handle opening/closing / creating/destroying LoveFrames objects..
-- TODO Close can save things, open loads them (if needed, have a bool to check if loaded)
--[[
function EmailProgram:Open()
    self:getMainLF():SetVisible(true)
end
--]]

function EmailProgram:Open()
    if self._open then
        print("EmailProgram tried to open when already open.")
        self:getMainLF():MakeTop()
        return
    end

    self:setMainLF(lf.Create("frame"))
    --self:getMainLF():SetVisible(false)
    self:updateTitle()
    self:getMainLF():SetIcon(self._icon)
    --self:getMainLF():SetSize(520, 600)
    --self:getMainLF():SetPos(20, 20)
    self:getMainLF():SetSize(unpack(self._frame.size))
    self:getMainLF():SetPos(unpack(self._frame.pos))
    self:getMainLF().OnClose = function()
        --[[
        self:getMainLF():SetVisible(false)
        self._Taskbar:RemoveProgram(self)
        self.open = false
        return false
        --]]
        self:Close()

        -- TODO need to add minimize button, and replace that with this
        -- TODO also need menu to open EmailProgram back up from start menu
        -- TODO also this needs to save state when closed!
    end

    self.list = lf.Create("list", self:getMainLF())
    self.list:SetPos(5, 30)
    local w, h = self:getMainLF():GetSize()
    self.list:SetSize(w - 10, h - 35)

    self._Taskbar:AddProgram(self)

    for _,v in pairs(self._emails) do
        self:add_email(v)
    end

    self._open = true
end

function EmailProgram:Show()
    self:getMainLF():SetVisible(true)
end

function EmailProgram:Hide()
    self:getMainLF():SetVisible(false)
end

-- NOTE this isn't a true 'Close'
--      either change the name of it or make it actually close the program completely ?
--[[
function EmailProgram:Close()
    self:getMainLF():SetVisible(false)
end
--]]

function EmailProgram:Close()
    if not self:isOpen() then
        print("EmailProgram tried to close when not open.")
        return
    end

    self._frame.size = {self:getMainLF():GetSize()}
    self._frame.pos = {self:getMainLF():GetPos()}

    --TODO if saveEnabled bullshit ?? should saveEnabled be global?
    ---[[
    self._Taskbar:RemoveProgram(self)
    --]]

    self.list:Remove()
    self:getMainLF():Remove()

    self._visible_emails = 0
    self._open = false
end

local defaultSaveFile = "save/default/emailProgram.lua"

function EmailProgram:save(file)
    if not file then file = defaultSaveFile end
    local data = {
        frame = self._frame,
        emails = {}
    }
    for k,v in pairs(self._emails) do
        table.insert(data.emails, self._emails[k]:save())
    end
    for i=1,#self._pending_emails do
        table.insert(data.emails, self._pending_emails[i]:save())
    end
    data = serialize(data)
    --create dir / write data
    if file:find("^.+/") then
        local fdir = file:sub(file:find("^.+/"))
        filesystem.createDirectory(fdir)
    end
    filesystem.write(file, data)
end

function EmailProgram:load(file)
    if not file then file = defaultSaveFile end
    if filesystem.exists(file) then
        local data = load(file)
        if self.open then
            self:getMainLF():SetSize(unpack(data.frame.size))
            self:getMainLF():SetPos(unpack(data.frame.pos))
            local w, h = unpack(data.frame.size)
            self.list:SetSize(w - 10, h - 35)
        end

        for i=1,#data.emails do
            --new Emails created, loaded, then receive each
            local email = Email(data.emails[i]) --NOTE this is valid as long as no subclass of Email starts adding extra data or methods
            --email:load(data.emails[i])
            self:receiveEmail(email)
        end
    end
end

return EmailProgram
