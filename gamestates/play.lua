local Cup = require "entities.cup"
local Field = require "entities.field"
local FieldView = require "entities.fieldview"

local Play = {}

function Play:enteredState(params)
    love.graphics.setBackgroundColor(251, 247, 233)

    if params then
        self:newGame(params)
    end
end

function Play:newGame(params)
    self.params = params

    self.field = Field(10, 5, 3)
    self.fieldView = FieldView(self.field, 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

function Play:update(dt)
    self.fieldView:update(dt)
end

function Play:draw()
    self.fieldView:draw()
end

return Play
