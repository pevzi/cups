local class = require "libs.middleclass"

local Cup = class("Cup")

function Cup:initialize(x, y, ball, batch)
    self.x = x
    self.y = y
    self.ball = ball
    self.batch = batch
    self.yoffset = 0
    self.spriteId = batch:add(x, y)

    self:updateBall()
end

function Cup:setPosition(x, y)
    self.x = x
    self.y = y

    self:updateSprite()
    self:updateBall()
end

function Cup:updateSprite()
    self.batch:set(self.spriteId, self.x, self.y + self.yoffset)
end

function Cup:updateBall()
    if self.ball then
        self.ball:setPosition(self.x, self.y)
    end
end

return Cup
