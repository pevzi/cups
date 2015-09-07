local class = require "libs.middleclass"

local Cup = class("Cup")

function Cup:initialize(x, y, batch)
    self.x = x
    self.y = y
    self.batch = batch

    self.spriteId = batch:add(x, y)
end

function Cup:setPosition(x, y)
    self.x = x
    self.y = y

    self.batch:set(self.spriteId, x, y)
end

return Cup
