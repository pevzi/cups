local class = require "libs.middleclass"
local Flow = require "libs.flow"

local initialState = "Show"

local Operator = class("Operator", Flow)

------------------------------------------

local Show = Operator:addState("Show")

function Show:act()
    self:showBalls()
    self:sleep(self.ballDelay)
    self:hideBalls()

    self:runState("Shuffle")
end

local Shuffle = Operator:addState("Shuffle")

function Shuffle:act()
    -- NOTE: this code doesn't take into consideration the tween/timer lateness
    --       (so the error accumulates with every iteration)

    for i = 1, self.rounds do
        self:swap()
        self:sleep(self.swapDelay)
    end

    self:runState("Show")
end

------------------------------------------

function Operator:initialize(field, fieldView, swapDelay, swapDuration, rounds, simultaneous, ballDelay)
    Operator.super.initialize(self)

    self.field = field
    self.fieldView = fieldView
    self.swapDelay = swapDelay
    self.swapDuration = swapDuration
    self.rounds = rounds
    self.simultaneous = simultaneous
    self.ballDelay = ballDelay

    self:runState(initialState)
end

function Operator:showBalls()
    self.fieldView:openCups(true, self.field.balls):oncomplete(function () self:resume() end)
    self:wait()
end

function Operator:hideBalls()
    self.fieldView:openCups(false, self.field.balls):oncomplete(function () self:resume() end)
    self:wait()
end

function Operator:openCup(id)
    self.fieldView:openCups(true, {[id] = true}):oncomplete(function () self:resume() end)
    self:wait()
end

function Operator:closeCup(id)
    self.fieldView:openCups(false, {[id] = true}):oncomplete(function () self:resume() end)
    self:wait()
end

function Operator:swap()
    local moved = self.field:swap(self.simultaneous)
    self.fieldView:moveCups(moved, self.swapDuration):oncomplete(function () self:resume() end)
    self:wait()
end

return Operator