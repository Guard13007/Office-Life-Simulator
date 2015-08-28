local lf = love.filesystem
local type, ipairs = type, ipairs
local logFile = "logs/" .. os.date("%Y.%m.%d-%H.%M.log", os.time())

return function(...)
    local strings = ""
    if type(arg) == "table" then
        for _,v in ipairs(arg) do
            strings = strings .. v
        end
    else
        strings = arg
    end

    -- make sure logs directory exists
    if lf.exists("logs") then
        if not lf.isDirectory("logs") then
            lf.remove("logs")
            lf.createDirectory("logs")
        end
    else
        lf.createDirectory("logs")
    end

    -- append new data to logFile
    local success, errorMsg = lf.append(logFile, strings)
    if not success then
        print("Failed to write to log file!", errorMsg)
    end

    -- print to console
    print(...)
end
