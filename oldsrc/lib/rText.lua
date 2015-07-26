local random = math.random
math.randomseed(os.time())
random()

local rText = {}

function rText.word(minLength, maxLength)
    local length = random(minLength, maxLength)
    local result = ""
    for i=1,length do
        local r = random(1, 37)
        if r == 1 or r == 2 or r == 3 then
            result = result .. "a"
        elseif r == 4 then
            result = result .. "b"
        elseif r == 5 then
            result = result .. "c"
        elseif r == 6 then
            result = result .. "d"
        elseif r == 7 or r == 8 or r == 9 then
            result = result .. "e"
        elseif r == 10 then
            result = result .. "f"
        elseif r == 11 then
            result = result .. "g"
        elseif r == 12 then
            result = result .. "h"
        elseif r == 13 or r == 14 or r == 15 then
            result = result .. "i"
        elseif r == 16 then
            result = result .. "j"
        elseif r == 17 then
            result = result .. "k"
        elseif r == 18 then
            result = result .. "l"
        elseif r == 19 then
            result = result .. "m"
        elseif r == 20 then
            result = result .. "n"
        elseif r == 21 or r == 22 or r == 23 then
            result = result .. "o"
        elseif r == 24 then
            result = result .. "p"
        elseif r == 25 then
            result = result .. "q"
        elseif r == 26 then
            result = result .. "r"
        elseif r == 27 then
            result = result .. "s"
        elseif r == 28 then
            result = result .. "t"
        elseif r == 29 or r == 30 or r == 31 then
            result = result .. "u"
        elseif r == 32 then
            result = result .. "v"
        elseif r == 33 then
            result = result .. "w"
        elseif r == 34 then
            result = result .. "x"
        elseif r == 35 or r == 36 then
            result = result .. "y"
        elseif r == 37 then
            result = result .. "z"
        else
            result = result .. "guh"
            print("rText.word error: invalid random number: " .. r .. " (should be in range 1 to 37, an integer)")
        end
    end
    return result
end

-- pass this tables for how many words to have in the name,
--  with two values in each table for range of letters in names
function rText.name(...)
    local args = {...}

    local name = ""
    for i=1,#args do
        name = name .. rText.word(args[i][1], args[i][2]):gsub("^%l", string.upper) .. " "
    end

    name = name:sub(1,-2)

    return name
end

-- pass in as many arguments as you want, numbers generate that many words,
--  strings insert that string at that point
function rText.sentence(...)
    local args = {...}

    local sentence = ""

    -- make sure first word is capitalized
    if type(args[1]) == "number" then
        sentence = rText.word(1, 11):gsub("^%l", string.upper)
        for i=2,args[1] do
            sentence = sentence .. " " .. rText.word(1, 11)
        end
    elseif type(args[1]) == "string" then
        sentence = args[1]:gsub("^%l", string.upper)
    else
        error("FUCK EVERYTHING")
    end

    -- now get the rest in there
    for i=2,#args do
        if type(args[i]) == "number" then
            for j=1,args[i] do
                sentence = sentence .. " " .. rText.word(1, 11)
            end
        elseif type(args[i]) == "string" then
            sentence = sentence .. " " .. args[i]
        else
            error("FUCK EVERYFHUEIKW")
        end
    end

    return sentence .. "."
end

return rText
