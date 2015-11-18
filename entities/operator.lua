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

local function resume(co)
    local ok, msg = coroutine.resume(co)

    if not ok then
        error(msg)
    end
end

local function makeContinue()
    local co = coroutine.running()

    local function continue()
        resume(co)
    end

    return continue, co
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

    self.timers = {}

    self:gotoState("Show")
end

function Operator:runCoroutine(body)
    local co = coroutine.create(body)
    resume(co)
end

function Operator:sleep(duration)
    local continue, co = makeContinue()

    local timer = cron.after(duration, function ()
        self.timers[co] = nil
        continue()
    end)

    self.timers[co] = timer

    coroutine.yield()
end

function Operator:showBalls()
    self.fieldView:openCups(true, self.field.balls):oncomplete(makeContinue())
    coroutine.yield()
end

function Operator:hideBalls()
    self.fieldView:openCups(false, self.field.balls):oncomplete(makeContinue())
    coroutine.yield()
end

function Operator:openCup(id)
    self.fieldView:openCups(true, {[id] = true}):oncomplete(makeContinue())
    coroutine.yield()
end

function Operator:closeCup(id)
    self.fieldView:openCups(false, {[id] = true}):oncomplete(makeContinue())
    coroutine.yield()
end

function Operator:swap()
    local moved = self.field:swap(self.simultaneous)
    self.fieldView:moveCups(moved, self.swapDuration):oncomplete(makeContinue())
    coroutine.yield()
end

function Operator:update(dt)
    for _, timer in pairs(self.timers) do
        timer:update(dt)
    end
end

Operator:addState("Show", Show)
Operator:addState("Shuffle", Shuffle)

return Operator
