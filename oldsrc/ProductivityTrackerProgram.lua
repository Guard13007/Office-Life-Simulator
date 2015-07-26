local class = require "lib.middleclass"
local Program = require "Program"
local lf = require "lib.LoveFrames"
local beholder = require "lib.beholder"
local inspect = require "lib.inspect"
local serialize = require "lib.ser"
local lg = love.graphics
local filesystem = love.filesystem
local load = require "util.load"

local Email = require "Email"
local story = require "emails.story"

local ProductivityTrackerProgram = class("ProductivityTrackerProgram", Program)

function ProductivityTrackerProgram:initialize(computer, clock, taskbar)
    Program.initialize(self)
    self._programName = "Productivity Tracker"
    self._icon = "images/ProductivityTrackerProgramIconDefault.png"

    self.Computer = computer
    self.Clock = clock or computer:GetClock()
    self.Taskbar = taskbar or computer:GetTaskbar()

    self.score = 1000
    self.records = {} -- used for showing records

    beholder.observe("EmailProgram", function(...) self:observe(...) end)
end

function ProductivityTrackerProgram:add_record(record)
    local RECORDS_LIMIT = 7 --NOTE SHIT AND TEMP AND THIS WHOLE THING SUCKS RIGHT NOW ARGH
    table.insert(self.records, record)
    if #self.records > RECORDS_LIMIT then
        table.remove(self.records, 1)
    end
end

function ProductivityTrackerProgram:observe(loremIpsum, email)
    --remember, score is based on correctness (+/-), time took, scaled by position of person who sent it
    --3600 seconds is how long you have to Lorem/Ipsum an email (1 hour) (72 seconds IRL)
    local points = 3600 - (self.Clock:getTime() - email:getTime())

    -- TODO rewrite this whole thing to make more sense
    if email:getText():find(loremIpsum) == nil and email:getText():find(loremIpsum:gsub("^%u", string.lower)) == nil then
        -- wrong, you get a down
        points = points * -0.1
        if points > 0 then --this is probably a shit way to do this
            points = -points
        end
        print("wrong", points)

        self.Computer:after(60*30, function()
            self.Computer:GetEmailProgram():receiveEmail(Email(story.incorrectEmail, self.Computer:getClock():getTime()))
        end)
    else
        -- correct, you get an up
        points = points * 0.13
        if points < 0 then
            points = 100 / -points --if late, you get a small amount of points, but almost nothing
        end
        print("right", points)
    end

    if email:getFrom():find("Manager") then
        points = points * 1.3
    elseif email:getFrom():find("Project") then -- Project Lead / Project Follow
        points = points * 1.2
    elseif email:getFrom():find("Q/A") then
        points = points * 1.1
    elseif email:getFrom():find("Customer") then
        points = points * 1
    elseif email:getFrom():find("CEO") then
        points = points * 2
    end
    -- Q/Q and Emailer are ignored (aka 1)

    if points > 0 then
        points = math.max(points, 1) --minimum of 1 point
    end

    self.score = self.score + points
    --self:add_record(points .. " | " .. email.subject .. " | " .. email.from)
    self:add_record{points, email:getSubject(), email:getFrom()}
end

function ProductivityTrackerProgram:setScore(score)
    self.score = score
end

function ProductivityTrackerProgram:getScore()
    return self.score
end

--[[ TODO figure out if would work right / make work correctly
function ProductivityTrackerProgram:setRecords(records)
    self.records = records
end
--]]

function ProductivityTrackerProgram:getRecords()
    return self.records
end

function ProductivityTrackerProgram:SetComputer(computer)
    self.Computer = computer
end

function ProductivityTrackerProgram:GetComputer()
    return self.Computer
end

function ProductivityTrackerProgram:SetClock(clock)
    self.Clock = clock
end

function ProductivityTrackerProgram:GetClock()
    return self.Clock
end

function ProductivityTrackerProgram:SetTaskbar(taskbar)
    self.Taskbar = taskbar
end

function ProductivityTrackerProgram:GetTaskbar()
    return self.Taskbar
end

---[[
function ProductivityTrackerProgram:Open()
    if self:isOpen() then
        print("ProductivityTrackerProgram tried to open when already open.")
        return
    end

    self._mainLF = lf.Create("imagebutton")
    --self.mainLF:SetVisible(false)
    self._mainLF:SetText("")
    self._mainLF:SetImage(self._icon)
    self._mainLF:SizeToImage()
    --self.mainLF:SetPadding(1) -- not a real thing..

    self.tooltip = lf.Create("tooltip", self._mainLF)
    self.tooltip:SetText("Productivity score: " .. self.score)
    self.tooltip:SetObject(self._mainLF)
    self.tooltip.Update = function()
        self.tooltip:SetText("Productivity score: " .. self.score)
    end

    self.report_visible = false
    self._mainLF.OnClick = function()
        if self.report_visible then
            --TODO store a ref to visible self.report so we can bring it to foreground
            --      but actually rebuild it or update the data instead of just bringing up old data
            -- NO, instead, it should be rebuilt if open every time something effects what should be in the report
            return
        else
            self.report_visible = true
        end
        local w, h = 300, 197
        local widthSpacing = 10
        self.report = lf.Create("frame")
        --self.report:SetVisible(false)
        self.report:SetName("Productivity Report")
        self.report:SetIcon("images/ProgramIconDefault.png")
        self.report:SetSize(w, h)
        self.report:SetPos(lg.getWidth() - w +1, lg.getHeight() - h - self.Taskbar:getHeight() +1) --sunk out of screen partially because FUCK EVERYTHING
        self.report:SetDraggable(false) --NOTE either get rid of this or make the report close when it loses focus
        self.report:SetResizable(false)
        self.report.OnClose = function()
            self.report_visible = false
        end
        --local list = lf.Create("list", self.report)
        --list:SetPos(5, 30)
        --list:SetSize(w - 10, h - 35)
        local grid = lf.Create("grid", self.report)
        grid:SetPos(5, 30)
        grid:SetSize(w - widthSpacing, h - 35)
        grid:SetColumns(3)
        --grid:SetRows(#self.records)
        grid:SetRows(7)
        grid:SetCellWidth(math.floor((w - widthSpacing) / 3) - widthSpacing)
        grid:SetCellHeight(13)
        --grid:SetItemAutoSize(true)

        for i=2,#self.records do --tmp start at 2 to prevent text object overlap
            local text = lf.Create("text")
            text:SetText(math.floor(self.records[i][1]))
            grid:AddItem(text, i, 1)

            text = lf.Create("text")
            text:SetText(self.records[i][2]:sub(1,8) .. "...")
            grid:AddItem(text, i, 2)

            text = lf.Create("text")
            text:SetText(self.records[i][3]:sub(1,8) .. "...")
            grid:AddItem(text, i, 3)
        end

        --NOTE SHITTY TEMPORARY HACK
        local text = lf.Create("text")
        text:SetText(math.floor(self.score))
        grid:AddItem(text, 1, 1)

        text = lf.Create("text")
        text:SetText("Productivity")
        grid:AddItem(text, 1, 2)

        text = lf.Create("text")
        text:SetText("Score")
        grid:AddItem(text, 1, 3)
    end

    self.Taskbar:AddItem(self)

    self._open = true
end
--]]

function ProductivityTrackerProgram:Show()
    if self._open then
        self._mainLF:SetVisible(true)
    else
        print("ProductivityTrackerProgram tried to Show when not open.")
    end
end

function ProductivityTrackerProgram:Hide()
    if self._open then
        self._mainLF:SetVisible(false)
    else
        print("ProductivityTrackerProgram tried to Hide when not open.")
    end
end

function ProductivityTrackerProgram:Close()
    if self.report then self.report:Remove() end

    if self:isOpen() then
        self._mainLF:Remove()

        self._open = false
    end
end

local defaultSaveFile = "save/default/productivityTrackerProgram.lua"

function ProductivityTrackerProgram:save(file)
    if not file then file = defaultSaveFile end
    local data = {
        score = self.score
    }
    data = serialize(data)
    --create dir / write data
    if file:find("^.+/") then
        local fdir = file:sub(file:find("^.+/"))
        filesystem.createDirectory(fdir)
    end
    filesystem.write(file, data)
end

function ProductivityTrackerProgram:load(file)
    if not file then file = defaultSaveFile end
    if filesystem.exists(file) then
        local data = load(file)
        self.score = data.score
    end
end

return ProductivityTrackerProgram
