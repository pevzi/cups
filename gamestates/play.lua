local Cup = require "entities.cup"
local Field = require "entities.field"
local FieldView = require "entities.fieldview"

local cron = require "libs.cron"

local function makeSwapper(field, fieldView, duration, delay, simultaneous)
    return cron.every(duration + delay, function ()
        fieldView:stopTweens()

        local swappedPairs = field:swap(simultaneous)

        for _, pair in ipairs(swappedPairs) do
            fieldView:startSwap(pair[1], pair[2], duration)
        end
    end)
end

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

    self.swapper = makeSwapper(self.field, self.fieldView, 0.5, 0.5, 5)
end

function Play:update(dt)
    if self.swapper then
        self.swapper:update(dt)
    end

    self.fieldView:update(dt)
end

function Play:draw()
    self.fieldView:draw()
end

return Play
