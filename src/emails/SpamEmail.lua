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

return SpamEmail
