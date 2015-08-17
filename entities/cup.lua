local class = require "libs.middleclass"

local Cup = class("Cup")

function Cup:initialize(x, y, batch)
    self.x = x
    self.y = y
    self.batch = batch

    self.id = self.batch:add(self.x, self.y)
end

return Cup