love.math.setRandomSeed(os.time()) --give us a seed for randomization!
love.math.random()                 --call it once to make sure it's randomized..apparently this matters

local Gamestate = require "lib.gamestate"
local lf = require "lib.LoveFrames"

local desktop = require "gamestates.desktop"

function love.update(dt)
    lf.update(dt)
end
function love.draw()
    lf.draw()
end
function love.mousepressed(x, y, button)
    lf.mousepressed(x, y, button)
end
function love.mousereleased(x, y, button)
    lf.mousereleased(x, y, button)
end
function love.keypressed(key, unicode)
    lf.keypressed(key, unicode)
end
function love.keyreleased(key)
    lf.keyreleased(key)
end
function love.textinput(text)
    lf.textinput(text)
end

Gamestate.registerEvents()
Gamestate.switch(desktop)
