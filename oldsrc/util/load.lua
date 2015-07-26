local function load(file)
    local ok, chunk, result
    ok, chunk = pcall(love.filesystem.load, file) -- safely load a chunk
    if not ok then
        print("An error happened: " .. tostring(chunk))
        --TODO return error ?
    else
        ok, result = pcall(chunk) -- execute chunk safely
        if not ok then
            print("An error happened: " .. tostring(result))
            --TODO return error ?
        else
            return result
        end
    end
end

return load
