local class = require "libs.middleclass"
local flux = require "libs.flux"

local res = require "resources"

local HUD = class("HUD")

function HUD:initialize(game, height)
    self.game = game

    self.x = 0
    self.y = love.graphics.getHeight() - height
    self.width = love.graphics.getWidth()
    self.height = height

    self.query = {x = self.width / 2, y = self.height / 2,
        ox = res.images.question:getWidth() / 2,
        oy = res.images.question:getHeight() / 2,
        scale = self.height * 0.6 / res.images.question:getHeight(),
        color = {255, 255, 255, 0},
        icon = "question"
    }

    self.tweens = flux.group()
end

function HUD:askColor(color)
    self.query.color = {color[1], color[2], color[3], 0}
    self.tweens:to(self.query.color, 0.2, {[4] = 255})

    self.query.icon = "question"
end

function HUD:hide()
    self.tweens:to(self.query.color, 0.2, {[4] = 0})
end

function HUD:sayCorrect()
    self.query.icon = "correct"
end

function HUD:sayIncorrect()
    self.query.icon = "incorrect"
end

function HUD:update(dt)
    self.tweens:update(dt)
end

function HUD:draw()
    love.graphics.push()

        love.graphics.translate(self.x, self.y)

        local query = self.query

        love.graphics.setColor(query.color)
        love.graphics.draw(res.images[query.icon], query.x, query.y, 0,
            query.scale, query.scale, query.ox, query.oy)

    love.graphics.pop()
end

return HUD
