local class = require "libs.middleclass"
local Stateful = require "libs.stateful"

local Timer = class("Timer")

function Timer:initialize(t)
    self.t = t or 0
end

function Timer:set(t)
    self.t = t
end

function Timer:update(dt)
    self.t = self.t - dt
    return self.t <= 0
end

local Flow = class("Flow"):include(Stateful)

function Flow:initialize()
    self.timer = Timer()
end

function Flow:runState(stateName, ...)
    self:gotoState(stateName, ...)

    if self.act then
        if self.co and coroutine.running() == self.co then
            self:act(...)
        else
            self.co = coroutine.create(self.act)
            self:resume(self, ...)
        end
    end
end

function Flow:resume(...)
    local ok, msg = coroutine.resume(self.co, ...)

    if not ok then
        error(msg)
    end
end

function Flow:wait(worker)
    self.worker = worker
    coroutine.yield()
end

function Flow:sleep(duration)
    self.timer:set(duration)
    self:wait(self.timer)
end

function Flow:update(dt)
    if self.worker and self.worker:update(dt) then
        self.worker = nil
        self:resume()
    end

    if self.listen then
        self:listen(dt)
    end
end

return Flow
