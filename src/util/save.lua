local filesystem = love.filesystem

return function(file, data)
    --create directory if needed
    if file:find("^.+/") then
        local directory = file:sub(file:find("^.+/"))
        filesystem.createDirectory(directory)
    end

    --write data
    filesystem.write(file, data)
end
