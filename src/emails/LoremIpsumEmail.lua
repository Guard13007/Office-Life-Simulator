local random = love.math.random
local class = require "lib.middleclass"
local Email = require "emails.Email"
local Markov = require "lib.Markov"
local lume = require "lib.lume"

local randomText = require "util.randomText"

local subject, from, text --local random generation function defined below

local LoremIpsumEmail = class("LoremIpsumEmail", Email)

function LoremIpsumEmail:initialize(time)
    local r = random(2)
    local word
    if r == 1 then
        word = "lorem"
    else
        word = "ipsum"
    end

    local data = {
        subject = subject(),
        from = from(),
        text = text(word),
        time = 0,
        type = "LoremIpsum"
    }

    Email.initialize(self, data, time)
end

function subject()
    local buzzWords = {"Innovation", "Scability", "Bug", "Synergy", "Report", "Flagship", "Stagnant", "Technical", "Order", "Failure", "Update", "Stuff", "salad", "lunch", "Q/A", "Manager", "Lead", "Project", "Issue", "Wow", "Such", "Program", "Office", "Life", "Simulator", "Staff", "Fire", "Sir/Madam", "Mantis", "git", "CM"}

    local subject = buzzWords[random(1, #buzzWords)]
    local r = random(1, 5)
    for i=1,r do
        local w = random(1, #buzzWords)
        subject = subject .. " " .. buzzWords[w]
    end

    return subject
end

function from()
    local titles = {
        [randomText.name{4, 8} .. ", Manager"] = 0.36,
        [randomText.name({2, 5}, {3, 9}) .. ", Project Lead"] = 0.14,
        [randomText.name({8, 13}) .. ", Project Follow"] = 0.01,
        [randomText.name{6, 9} .. ", Q/A"] = 0.3,
        [randomText.name({1, 4}, {2, 3}) .. ", Q/Q"] = 0.01,
        [randomText.name({4, 7}, {4, 10}) .. ", Customer"] = 0.41,
        [randomText.name{1, 5} .. ", CEO"] = 0.02,
        [randomText.name{14, 21} .. ", Emailer"] = 0.01
    }

    return lume.weightedchoice(titles)
end

function text(filler)
    --generate source if needed
    if not next(Markov.chain_source) then
        Markov.process_corpus(love.filesystem.read("emails/LoremIpsumEmails.txt"))
        Markov.dump_chain_source()
    end

    local paragraphs = love.math.randomNormal(2, 5) -- 1 to 9, mostly around 5
    local text = ""

    for i=1,paragraphs do
        local r = random()
        local paragraphLength
        -- note these are word counts!
        if r > 0.65 then
            paragraphLength = love.math.randomNormal(2, 9) --shortest!
        elseif r > 0.40 then
            paragraphLength = love.math.randomNormal(4, 24) --shorter
        else
            paragraphLength = love.math.randomNormal(6, 50) --longer
        end

        local generatedText = Markov.generate_text(paragraphLength)
        while generatedText:len() < 25 do --HACK NOTE WARNING ETC may lead to infinite loop!!
            generatedText = Markov.generate_text(paragraphLength)
        end
        text = text .. generatedText .. ".\n\n"
    end

    if text:len() == 0 then
        return "ERROR " .. filler
    end
    local r = random(1, text:len()-20) --no word should be longer than 20 characters...
    r = text:find(" ", r) --should be first space after r
    if r == nil then
        return "ERROR 2 " .. filler
    end
    text = text:sub(1,r) .. text:sub(r+1):gsub("%l+", filler, 1)
    -- NOTE needs to be smart enough to capitalize or punctuate after itself! (perhaps just change %S+ to only check for lowercase words?)
    -- %l+ would check for lowercase TMP USE THIS
    -- %u%l* would be an uppercased first letter ??
    -- %u+ would be all uppercase
    -- (how do I do OR in pattern matching ?)

    return text:sub(1,-3) --strip extra \n\n
end

return LoremIpsumEmail
