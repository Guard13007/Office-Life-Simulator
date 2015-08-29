local class = require "lib.middleclass"
local Email = require "emails.Email"

local spam --table of functions to generate spam emails, defined below

local SpamEmail = class("SpamEmail", Email)

function SpamEmail:initialize(time)
    --[[
        subject =
        from =
        text =
    --]]
    local data = spam[random(#spam)]()
    data.time = 0
    data.type = "SpamEmail"

    Email.initialize(self, data)
end

spam = {
    function()
        local data = {}

        --wad
    end,
    function()
        --
    end
}

--[[ TODO text substitution
function interp(s, tab)
    return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end
print( interp("${name} is ${value}", {name = "foo", value = "bar"}))

getmetatable("").__mod = interp --allows following:
print("${osName}, ${username}" % {osName = "Titanhard", username = "Guard13007"})
-- outputs "Titanhard, Guard13007"
--]]

--[[ TODO better text substitution ONLY USE IF NEEDED, DO NOT USER METATABLE MANIPULATION ON "" !!!
function interp(s, tab)
    return (s:gsub('%%%((%a%w*)%)([-0-9%.]*[cdeEfgGiouxXsq])',
        function(k, fmt) return tab[k] and ("%"..fmt):format(tab[k]) or '%('..k..')'..fmt end))
end
getmetatable("").__mod = interp
print("%(key)s is %(val)7.2f%" % {key = "concentration", val = 56.2795})
-- outputs "concentration is      56.28%"
--]]

return SpamEmail
