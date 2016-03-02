setmetatable(_G, {
    __index = function (t, k)
        error(("attempt to access an undefined global variable '%s'"):format(k), 2)
    end,

    __newindex = function (t, k, v)
        error(("attempt to assign to an undefined global variable '%s'"):format(k), 2)
    end
})

local Game = require "game"

local game

function love.load()
    math.randomseed(os.time())

    game = Game()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
