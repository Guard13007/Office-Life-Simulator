-- GAME DEBUG SETTINGS --
local bypassLogIn = false
local saveEnabled = false

local random = math.random --LOVE VERISOJNS
math.randomseed(os.time())

local Gamestate = require "lib.gamestate"
local lf = require "lib.LoveFrames"
local beholder = require "lib.beholder"
local cron = require "lib.cron"

local Computer = require "Computer"
local Email = require "Email"
local LoremIpsumEmail = require "LoremIpsumEmail"

local story = require "emails.story"

local secondInRealTime, timing = 0.02, 0 -- used in :update() to keep track of time
local lateEmailCronJob, emailCronJob     -- used to track when emails should come in

local computer = Computer()

local desktop = {}

local function sendEmails()
    for i=1,random(1,3) do
        local time = computer:getClock():getTime()
        computer:GetEmailProgram():receiveEmail(LoremIpsumEmail(random(time - 4*60, time + 10))) --intentionally weird
    end

    --TODO replace with normalized value
    emailCronJob = cron.after(random(15*60, 60*60), sendEmails)
end

function desktop:init()
    if saveEnabled then
        computer:load()
    end

    ---[[
    beholder.observe("LogInProgram", "logged in", function()
        if computer.firstGameRun then
            --load intro Email (1.1 to 1.6 hours before now)
            computer:GetEmailProgram():receiveEmail(Email(story.welcomeToJob, computer:getClock():getTime() - random(4000, 6000)))
            computer.firstGameRun = false --now make sure this doesn't happen again

            --TODO rewrite to be based on cron jobs and have them show up quickly??
            -- TODO rewrite using sendEmails function (which will also start cron job) ??
            for i=1,5 do
                computer:GetEmailProgram():receiveEmail(LoremIpsumEmail(random(computer:getClock():getTime() - 120*60, computer:getClock():getTime() + 13))) --intentionally weird
            end
            lateEmailCronJob = cron.after(30*60, function() --half an hour in, if you haven't replied to an email, you get an email about it.
                computer:GetEmailProgram():receiveEmail(Email(story.firstLateEmail, computer:getClock():getTime()))
            end)

            computer:GetPatchNotesProgram():Open()
        end
        -- no else at the moment...but shall be needed?

        --TODO replace with normalized value
        emailCronJob = cron.after(random(15*60, 60*60), sendEmails)
    end)

    beholder.observe("StartMenu", "logged out", function()
        emailCronJob = false --NOTE this is probably or possibly temporary...? NO REST FOR THE WEARY
    end)

    beholder.observe("EmailProgram", function() -- if EmailProgram fires any event (currently), an email has been read
        if lateEmailCronJob then lateEmailCronJob = false end
    end)
    --]]

    if bypassLogIn then
        beholder.trigger("LogInProgram", "logged in")
    end
end

function desktop:update(dt)
    lf.update(dt)

    timing = timing + dt
    if timing >= 0.02 then
        timing = timing - 0.02
        computer:update(dt, 1)
        if lateEmailCronJob then lateEmailCronJob:update(1) end
        if emailCronJob then emailCronJob:update(1) end
    else
        computer:update(dt, 0)
    end
end

function desktop:draw()
    lf.draw()
end

function desktop:mousepressed(x, y, button)
    lf.mousepressed(x, y, button)
end

function desktop:mousereleased(x, y, button)
    lf.mousereleased(x, y, button)
end

function desktop:keypressed(key, unicode)
    lf.keypressed(key, unicode)

    --tmp(?) emergency exit
    if key == "escape" then
        love.event.quit()
    end
end

function desktop:keyreleased(key)
    lf.keyreleased(key)
end

function desktop:textinput(text)
    lf.textinput(text)
end

function desktop:quit()
    if saveEnabled then
        computer:save()
    end
end

return desktop
