local class = require "libs.middleclass"
local Stateful = require "libs.stateful"
local cron = require "libs.cron"

local Show = {}

function Show:enteredState()
    self:runCoroutine(function ()
        self:showBalls()
        self:sleep(self.ballDelay)
        self:hideBalls()

        self:gotoState("Shuffle")
    end)
end

local Shuffle = {}

function Shuffle:enteredState()
    -- NOTE: this code doesn't take into consideration the tween/timer lateness
    --       (so the error accumulates with every iteration)

    self:runCoroutine(function ()
        for i = 1, self.rounds do
            self:swap()
            self:sleep(self.swapDelay)
        end

        self:gotoState("Show")
    end)
end

local Operator = class("Operator"):include(Stateful)

function Operator:initialize(field, fieldView, swapDelay, swapDuration, rounds, simultaneous, ballDelay)
    self.field = field
    self.fieldView = fieldView
    self.swapDelay = swapDelay
    self.swapDuration = swapDuration
    self.rounds = rounds
    self.simultaneous = simultaneous
    self.ballDelay = ballDelay

    self:gotoState("Show")
end

function Operator:runCoroutine(body)
    self.continue = coroutine.wrap(body)
    self.continue(self.continue)
end

function Operator:sleep(duration)
    self.timer = cron.after(duration, self.continue)
    coroutine.yield()
end

function Operator:showBalls()
    self.fieldView:showBalls(true):oncomplete(self.continue)
    coroutine.yield()
end

function Operator:hideBalls()
    self.fieldView:showBalls(false):oncomplete(self.continue)
    coroutine.yield()
end

function Operator:swap()
    local swappedPairs = self.field:swap(self.simultaneous)
    self.fieldView:swap(swappedPairs, self.swapDuration):oncomplete(self.continue)
    coroutine.yield()
end

function Operator:update(dt)
    if self.timer then
        self.timer:update(dt)
    end
end

Operator:addState("Show", Show)
Operator:addState("Shuffle", Shuffle)

return Operator
