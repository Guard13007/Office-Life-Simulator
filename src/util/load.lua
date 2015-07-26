local filesystem = love.filesystem

--[[  Return values:
    false: File doesn't exist.
    nil:   Error loading data.
    table: Loaded data.
]]
return function(file)
    if filesystem.exists(file) then
        local ok, chunk, result
        ok, chunk = pcall(filesystem.load, file) --safely load chunk
        if not ok then
            print("ERROR: " .. tostring(chunk))
            return nil --nil on error
        else
            ok, result = pcall(chunk) --execute safely
            if not ok then
                print("ERROR: " .. tostring(result))
                return nil --nil on error
            else
                return result --success
            end
        end
    else
        return false --file doesn't exist
    end
end
