local class = require "libs.middleclass"

local Cup = class("Cup")

function Cup:initialize(x, y, batch)
    self.x = x
    self.y = y
    self.batch = batch

    self.yoffset = 0

    self.spriteId = batch:add(x, y)
end

function Cup:setPosition(x, y)
    self.x = x
    self.y = y

    self:updateSprite()
end

function Cup:updateSprite()
    self.batch:set(self.spriteId, self.x, self.y + self.yoffset)
end

return Cup
