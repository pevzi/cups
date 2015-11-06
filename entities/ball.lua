local res = require "resources"

local class = require "libs.middleclass"

local xoffset = res.images.cup:getWidth() / 2 - res.images.ball:getWidth() / 2
local yoffset = res.images.cup:getHeight() * 0.6

local Ball = class("Ball")

function Ball:initialize(color, batch)
    self.color = color
    self.batch = batch

    self.spriteId = batch:add()
end

function Ball:setPosition(x, y)
    self.batch:setColor(self.color)
    self.batch:set(self.spriteId, x + xoffset, y + yoffset)
end

return Ball
