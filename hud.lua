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

    local scale = self.height * 0.6 / res.images.question:getHeight()

    self.query = {x = self.width / 2 - res.images.question:getWidth() * scale / 2,
        y = self.height / 2 - res.images.question:getHeight() * scale / 2,
        scale = scale,
        color = {255, 255, 255, 0}}

    self.tweens = flux.group()

    self.icon = "question"
end

function HUD:askColor(color)
    self.query.color = {color[1], color[2], color[3], 0}
    self.tweens:to(self.query.color, 0.2, {[4] = 255})

    self.icon = "question"
end

function HUD:hide()
    self.tweens:to(self.query.color, 0.2, {[4] = 0})
end

function HUD:sayCorrect()
    self.icon = "correct"
end

function HUD:sayIncorrect()
    self.icon = "incorrect"
end

function HUD:update(dt)
    self.tweens:update(dt)
end

function HUD:draw()
    love.graphics.translate(self.x, self.y)

    love.graphics.setColor(self.query.color)
    love.graphics.draw(res.images[self.icon], self.query.x, self.query.y, 0, self.query.scale)
end

return HUD
