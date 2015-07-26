local random = love.math.random
love.math.setRandomSeed(os.time())
random()

local class = require "lib.middleclass"
local Email = require "Email"
local lume = require "lib.lume"
local Markov = require "lib.Markov"
local rText = require "lib.rText" --TODO Replace entirely
local serialize = require "lib.ser"
local filesystem = love.filesystem

-- functions defined below used to randomly generate emails
local subject, from, text

local LoremIpsumEmail = class('LoremIpsumEmail', Email)

function LoremIpsumEmail:initialize(clockTime)
    Email.initialize(self)
    self:setTime(clockTime)

    self._subject = subject()
    self._from = from()

    local r = random(2)
    if r == 1 then
        self._text = text("lorem")
    else
        self._text = text("ipsum")
    end

    self._type = "LoremIpsum"
end

-- :save() / :load() are unmodified from Email class

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
        [rText.name{4, 8} .. ", Manager"] = 0.36,
        [rText.name({2, 5}, {3, 9}) .. ", Project Lead"] = 0.14,
        [rText.name({8, 13}) .. ", Project Follow"] = 0.01,
        [rText.name{6, 9} .. ", Q/A"] = 0.3,
        [rText.name({1, 4}, {2, 3}) .. ", Q/Q"] = 0.01,
        [rText.name({4, 7}, {4, 10}) .. ", Customer"] = 0.41,
        [rText.name{1, 5} .. ", CEO"] = 0.02,
        [rText.name{14, 21} .. ", Emailer"] = 0.01
    }

    return lume.weightedchoice(titles)
end

-- NOTE MASSIVELY NEEDS A REWRITE PROBABLY
function text(loremIpsum)
    -- generate chain_source if needed
    if not next(Markov.chain_source) then
        Markov.process_corpus(love.filesystem.read("lib/corpus/LoremIpsumEmail.txt"))
        Markov.dump_chain_source()
    end

    --local paragraphs = random(1, 5)
    local paragraphs = love.math.randomNormal(2, 5) -- 1 to 9, mostly around 5
    local text = ""

    for i=1,paragraphs do
        local r = random()
        local paragraphLength
        if r > 0.65 then
            paragraphLength = love.math.randomNormal(2, 9)  --shortest!
        elseif r > 0.40 then
            paragraphLength = love.math.randomNormal(4, 24) --shorter
        else
            paragraphLength = love.math.randomNormal(6, 50) --longer
        end
        --local paragraphLength = love.math.randomNormal(1, 20) --stddev, mean (5, 105) stddev^2 is variance (I want between 1 or 5 or something and 21*5 words)

        -- NOTE there is a bug that caused the generated text to sometimes be nothing!
        -- NOTE this is hastily shittily fixed in the library AND here and it STILL doesn't work right...
        local generatedText = Markov.generate_text(paragraphLength)
        while generatedText == "" do
            generatedText = Markov.generate_text(paragraphLength)
        end
        text = text .. generatedText .. ".\n\n"
    end

    --TODO now I need a way to insert loremIpsum in there!
    if text:len() == 0 then
        return "ERROR"
    end
    local r = random(1, text:len())
    --local r = 2 --temporary to test for letter duplication
    r = text:find(" ", r) -- should be first space
    if r == nil then
        return "ERROR 2" -- FUCK FUCK FUCK FUCK...
    end
    --text = text:gsub("%l+", loremIpsum, 1) -- %S+ is space-separated tokens
    text = text:sub(1,r) .. text:sub(r+1):gsub("%l+", loremIpsum, 1)
    -- NOTE needs to be smart enough to capitalize or punctuate after itself! (perhaps just change %S+ to only check for lowercase words?)
    -- %l+ would check for lowercase TMP USE THIS
    -- %u%l* would be an uppercased first letter ??
    -- %u+ would be all uppercase
    -- (how do I do OR in pattern matching ?)

    return text:sub(1,-3) -- strip extra \n\n
    --return "'" .. text:sub(1,-3) .. "'" --TMP (used to varify some text strings are ENTIRELY "" NOTHING)
end

return LoremIpsumEmail
