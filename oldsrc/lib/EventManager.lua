-- This is really for O5, even though I'm designing it here.

local Manager = {}

Manager.events = {}
Manager.repeatable = {}

local _id = -1
local function id()
    _id = _id + 1
    return _id
end

function Manager:after(seconds, fn)
    --table.insert(self.events, {os.time() + seconds, fn})
    self.events[id()] = {os.time() + seconds, fn}
end

function Manager:repeat(seconds, fn)
    --table.insert(self.repeatable, {os.time(), seconds, fn})
    self.repeatable[id()] = {os.time(), seconds, fn}
end

function Manager:afterRandom(fn, low, high, normal)
    --
end

function Manager:repeatRandom(fn, low, high, normal)
    --
end
