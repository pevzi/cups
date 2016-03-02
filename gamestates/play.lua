local Field = require "entities.field"
local FieldView = require "entities.fieldview"
local Operator = require "operator"

local Play = {}

function Play:enteredState(params)
    love.graphics.setBackgroundColor(251, 247, 233)

    if params then
        self:newGame(params)
    end
end

function Play:newGame(params)
    self.params = params

    self.field = Field(4, 2, 2)
    self.fieldView = FieldView(self.field, 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    self.operator = Operator(self.field, self.fieldView, 0.1, 0.4, 3, 2, 1)
end

function Play:update(dt)
    self.operator:update(dt)
    self.fieldView:update(dt)
end

function Play:draw()
    self.fieldView:draw()
end

return Play
