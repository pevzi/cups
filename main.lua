setmetatable(_G, {
    __index = function (t, k)
        error(("attempt to access an undefined global variable '%s'"):format(k), 2)
    end,

    __newindex = function (t, k, v)
        error(("attempt to assign to an undefined global variable '%s'"):format(k), 2)
    end
})

local Game = require "game"
local res = require "resources"

local game

function love.load()
    love.graphics.setFont(res.fonts.main)

    game = Game()
end

function love.focus(f)
    game:focus(f)
end

function love.keypressed(key)
    game:keypressed(key)
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end
