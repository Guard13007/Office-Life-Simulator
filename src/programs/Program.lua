local class = require "lib.middleclass"

local Program = class("Program")

function Program:initialize()
    self._programName = "'programName' is not set!" --set/get
    self._icon = "images/DefaultProgramIcon.png"    --set/get
    self.mainLF = "'mainLF' is not set!"            --just access directly as needed
    self._open = false                              --get -> "isOpen()"
end

function Program:setProgramName(programName)
    self._programName = programName
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

--function Program:update(dt, seconds) --optional

function Program:isOpen()
    return self._open
end

function Program:open()
    error("Program did not implement open() method.")
end

function Program:show()
    print("Program did not implement show() method.")

    if self._open then
        self.mainLF:SetVisible(true)
    else
        print("Program tried to show() when not open.")
    end
end

function Program:hide()
    print("Program did not implement hide() method.")

    if self._open then
        self.mainLF:SetVisible(false)
    else
        print("Program tried to hide() when not open.")
    end
end

function Program:close()
    error("Program did not implement close() method.")
end

--function Program:save(file) --optional
--function Program:load(file) --optional

return Program
