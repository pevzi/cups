local Field = require "entities.field"
local FieldView = require "entities.fieldview"
local HUD = require "hud"
local Operator = require "operator"
local res = require "resources"

local padding = love.graphics.getHeight() * 0.15

local Play = {}

function Play:enteredState(params)
    love.graphics.setBackgroundColor(res.colors.background)

    if params then
        self:newGame(params)
    end
end

function Play:newGame(params)
    self.params = params

    self.field = Field(3, 2, 2)
    self.fieldView = FieldView(self.field, padding, padding,
        love.graphics.getWidth() - padding * 2, love.graphics.getHeight() - padding * 2)
    self.hud = HUD(self, padding)

    self.operator = Operator(self.field, self.fieldView, self.hud, 0.1, 0.3, 3, 2, 0.8)
end

function Play:pauseGame()
    self:pushState("Pause")
end

function Play:focus(f)
    if not f then
        self:pauseGame()
    end
end

function Play:keypressed(key)
    if key == "escape" then
        self:pauseGame()
    end
end

function Play:update(dt)
    self.operator:update(dt)
    self.fieldView:update(dt)
    self.hud:update(dt)
end

function Play:draw()
    self.fieldView:draw()
    self.hud:draw()
end

return Play
