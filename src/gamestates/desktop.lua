--TODO clean this file the fuck up
-- GAME DEBUG SETTINGS --
local bypassLogIn = false
local saveEnabled = false

local random = love.math.random

local Gamestate = require "lib.gamestate"
local lf = require "lib.LoveFrames"
local beholder = require "lib.beholder"
local cron = require "lib.cron"

local Computer = require "Computer"
local Email = require "emails.Email"
local LoremIpsumEmail = require "emails.LoremIpsumEmail"

local story = require "emails.story"

local secondsInRealTime, timing = 0.02, 0 --used in update loop to keep time correct
local lateEmailCronJob, emailCronJob      --used to track when certain emails should be sent

computer = Computer()
local computer = computer

local desktop = {}

local function sendEmails()
    for i=1,random(1,3) do
        local time = computer:getProgram("ClockProgram", true):getTime()
        computer:getProgram("EmailProgram", true):receiveEmail(LoremIpsumEmail(random(time - 4*60, time + 10))) --intentionally weird
    end

    --TODO replace with normalized value
    emailCronJob = cron.after(random(15*60, 60*60), sendEmails)
end

function desktop:init()
    computer:getProgram("Taskbar", true):open()
    computer:getProgram("StartMenu", true):open()

    if saveEnabled then
        computer:load()
    end

    beholder.observe("LogInProgram", "logged in", function()
        if computer.firstRun then
            --load intro Email (1.1 to 1.6 hours before now)
            --TODO redo with normalized ?
            local receiveEmail, time = computer:getProgram("EmailProgram", true).receiveEmail, computer:getProgram("ClockProgram", true):getTime()

            -- welcome email
            receiveEmail(Email(story.welcomeToJob, time - random(4000, 6000)))
            -- starting emails
            for i=1,5 do
                receiveEmail(LoremIpsumEmail(random(time - 120*60, time + 13))) --intentionally weird
            end
            -- half an hour in, if you haven't replied to an email, you can an email about it
            lateEmailCronJob = cron.after(30*60, function()
                receiveEmail(Email(story.firstLateEmail, time))
            end)

            -- patch notes
            computer:getProgram("PatchNotesProgram", true):open()

            -- now make sure we don't do this again
            computer.firstRun = false
        end

        --TODO replace with normalized value
        emailCronJob = cron.after(random(15*60, 60*60), sendEmails)
    end)

    beholder.observe("StartMenu", "logged out", function()
        emailCronJob = false --NOTE might be temporary (no rest for the weary?)
    end)

    beholder.observe("EmailProgram", function() --if EmailProgram throws any event (NOTE temporary!), an email has been read
        if lateEmailCronJob then lateEmailCronJob = false end
    end)

    if bypassLogIn then
        beholder.trigger("LogInProgram", "logged in")
    end
end

function desktop:update(dt)
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

function desktop:keypressed(key)
    --HACK emergency escape! TEMPORARY
    if key == "escape" then
        love.event.quit()
    end
end

function desktop:quit()
    if saveEnabled then
        computer:save()
    end
end

return desktop
