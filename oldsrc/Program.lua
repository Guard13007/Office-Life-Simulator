local class = require "lib.middleclass"
--local lf = require "lib.LoveFrames"

local Program = class('Program')

function Program:initialize()
    self._programName = "'programName' is not set!" -- Should be the name of this program as shown to user.
    self._icon = "images/ProgramIconDefault.png" -- Should be the path to an 18x18 image file representing the program.
    self._mainLF = "'mainLF' is not set!" -- Should be the main LoveFrames object that is needed.
    self._open = false -- Should be set to whether or not the program is open (aka 'does mainLF exist?' basically).
end

function Program:setProgramName(name)
    self._programName = name
end

function Program:getProgramName()
    return self._programName
end

function Program:setIcon(icon)
    self._icon = icon
end

function Program:getIcon()
    return self._icon
end

function Program:setMainLF(LFobject)
    self._mainLF = LFobject
end

function Program:getMainLF()
    return self._mainLF
end

function Program:isOpen()
    return self._open
end

-- no getter/setter for open, because it is simple and should only be handled by a program itself

function Program:Open()
    -- Should make this Program open (new GUI, load data). NOTE ignore loading for now
    error("Subclass of Program did not implement :Open() method.")
end

function Program:Show()
    -- Should make this Program visisble.
    print("Subclass of Program did not implement :Show() method.")
    if self._open then
        self._mainLF:SetVisible(true)
    else
        print("Subclass of Program tried to Show when not open.")
    end
end

function Program:Hide()
    -- Should make this Program hidden.
    print("Subclass of Program did not implement :Hide() method.")
    if self._open then
        self._mainLF:SetVisible(false)
    else
        print("Subclass of Program tried to Hide when not open.")
    end
end

function Program:Close()
    -- Should make this Program close (delete GUI, save data). NOTE ingore saving for now
    error("Subclass of Program did not implement :Close() method.")
end

return Program
