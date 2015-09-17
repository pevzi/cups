local res = require "resources"

local class = require "libs.middleclass"

local ox = res.images.cup:getWidth() / 2 - res.images.ball:getWidth() / 2
local oy = res.images.cup:getHeight() / 2

local Ball = class("Ball")

function Ball:initialize(color, batch)
    self.color = color
    self.batch = batch

    self.spriteId = batch:add()
end

function Ball:updateSprite(cup)
    self.batch:setColor(self.color)
    self.batch:set(self.spriteId, cup.x + ox, cup.y + oy)
end

return Ball
