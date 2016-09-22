local class = require "libs.middleclass"

local res = require "resources"

local function timer(t)
    return function (dt)
        t = t - dt
        return t <= 0
    end
end

local function mouseDown(button)
    return function ()
        return love.mouse.isDown(button)
    end
end

------------------------------------------

local Operator = class("Operator")

function Operator:act()
    ::show::

    self:showBalls()
    self:sleep(self.ballDelay)
    self:hideBalls()

    ::shuffle::

    for i = 1, self.rounds do
        self:swap()
        self:sleep(self.swapDelay)
    end

    local requested = res.colors[love.math.random(self.field.nballs)]

    self.hud:askColor(requested)

    local id, ball = self:queryPlayer()
    local correct = ball == requested

    if correct then
        self.hud:sayCorrect()
    else
        self.hud:sayIncorrect()
    end

    self:openCup(id)
    self:sleep(self.ballDelay)
    self:closeCup(id)

    self.hud:hide()

    if correct then
        goto shuffle
    else
        goto show
    end
end

------------------------------------------

function Operator:initialize(field, fieldView, hud, swapDelay, swapDuration, rounds, simultaneous, ballDelay)
    self.field = field
    self.fieldView = fieldView
    self.hud = hud
    self.swapDelay = swapDelay
    self.swapDuration = swapDuration
    self.rounds = rounds
    self.simultaneous = simultaneous
    self.ballDelay = ballDelay

    self.co = coroutine.create(self.act)
    self:resume(self)
end

function Operator:resume(...)
    local ok, msg = coroutine.resume(self.co, ...)

    if not ok then
        error(msg)
    end
end

function Operator:wait(worker)
    self.worker = worker
    coroutine.yield()
end

function Operator:update(dt)
    if self.worker and self.worker(dt) then
        self.worker = nil
        self:resume()
    end
end

------------------------------------------

function Operator:sleep(duration)
    self:wait(timer(duration))
end

function Operator:showBalls()
    self.fieldView:openCups(true, self.field.balls, function () self:resume() end)
    self:wait()
end

function Operator:hideBalls()
    self.fieldView:openCups(false, self.field.balls, function () self:resume() end)
    self:wait()
end

function Operator:openCup(id)
    self.fieldView:openCups(true, {[id] = true}, function () self:resume() end)
    self:wait()
end

function Operator:closeCup(id)
    self.fieldView:openCups(false, {[id] = true}, function () self:resume() end)
    self:wait()
end

function Operator:swap()
    local moved = self.field:swap(self.simultaneous)
    self.fieldView:moveCups(moved, self.swapDuration, function () self:resume() end)
    self:wait()
end

function Operator:queryPlayer()
    while true do
        self:wait(mouseDown(1))

        local ok, c, r = self.fieldView:query(love.mouse.getPosition())

        if ok then
            return self.field:get(c, r)
        end
    end
end

return Operator
