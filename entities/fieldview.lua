local res = require "resources"

local Cup = require "entities.cup"
local Ball = require "entities.ball"

local class = require "libs.middleclass"
local flux = require "libs.flux"

local ANGLE = math.pi * 0.8
local EASING = "quadinout"

local cupWidth = res.images.cup:getWidth()
local cupHeight = res.images.cup:getHeight()

local xstep = cupWidth * 1.3
local ystep = cupHeight * 1.55

local function fitRect(width, height, l,t,w,h)
    local wratio = w / width
    local hratio = h / height

    local x, y, scale

    if wratio > hratio then
        x = l + (w - hratio * width) / 2
        y = t
        scale = hratio
    else
        x = l
        y = t + (h - wratio * height) / 2
        scale = wratio
    end

    return x, y, scale
end

local function makeArc(x1, y1, x2, y2, angle)
    angle = angle or math.pi

    local dist = math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
    local radius = dist / 2 / math.sin(angle / 2)
    local offset = math.cos(angle / 2) * radius

    local mx = (x1 + x2) / 2
    local my = (y1 + y2) / 2

    local cx = -(y2 - y1) / 2 / (dist / 2) * offset + mx
    local cy =  (x2 - x1) / 2 / (dist / 2) * offset + my

    local startAngle = math.atan2(y1 - y2, x1 - x2) - (angle / 2) + (math.pi / 2)

    return function (p)
        local currentAngle = startAngle + p * angle
        local x = math.cos(currentAngle) * radius + cx
        local y = math.sin(currentAngle) * radius + cy
        return x, y
    end
end

local Mover = class("Mover")

function Mover:initialize(angle)
    self.angle = angle
    self.arcs = {}
    self.p = 0
end

function Mover:add(cup, x, y)
    self.arcs[cup] = makeArc(cup.x, cup.y, x, y, self.angle)
end

function Mover:update()
    for cup, arc in pairs(self.arcs) do
        cup:setPosition(arc(self.p))
    end
end

local FieldView = class("FieldView")

function FieldView:initialize(field, l,t,w,h)
    self.cupsBatch = love.graphics.newSpriteBatch(res.images.cup, field.columns * field.rows)
    self.ballsBatch = love.graphics.newSpriteBatch(res.images.ball)

    self.cups = {}

    for r = 1, field.rows do
        for c = 1, field.columns do
            local id = field.cups[r][c]

            local ballColor = field:getBall(id)
            local ball = ballColor and Ball(res.colors[ballColor], self.ballsBatch)

            self.cups[id] = Cup((c - 1) * xstep, (r - 1) * ystep, ball, self.cupsBatch)
        end
    end

    local width = xstep * (field.columns - 1) + cupWidth
    local height = ystep * (field.rows - 1) + cupHeight

    self.x, self.y, self.scale = fitRect(width, height, l,t,w,h)

    self.tweens = flux.group()

    self.showingBalls = false
end

function FieldView:moveCups(toMove, duration)
    local mover = Mover(ANGLE)

    for id, position in pairs(toMove) do
        local cup = self.cups[id]

        local c, r = position[1], position[2]
        local x, y = (c - 1) * xstep, (r - 1) * ystep

        mover:add(cup, x, y)
    end

    local tween = self.tweens:to(mover, duration, {p = 1}):ease(EASING)

    tween:onupdate(function ()
        mover:update()
    end)

    return tween
end

function FieldView:openCups(open, cups, duration)
    duration = duration or 0.5

    local easing, yoffset

    if open then
        easing = "backout"
        yoffset = -res.images.cup:getWidth() / 2
    else
        easing = "quadinout"
        yoffset = 0
    end

    local maxDelay = -1
    local lastTween

    for id, _ in pairs(cups) do
        local cup = self.cups[id]

        local tween = self.tweens:to(cup, duration, {yoffset = yoffset}):ease(easing)

        tween:onupdate(function ()
            cup:updateSprite()
        end)

        local delay = math.random() * duration * 0.4

        tween:delay(delay)

        if delay > maxDelay then
            maxDelay = delay
            lastTween = tween
        end
    end

    return lastTween
end

function FieldView:update(dt)
    self.tweens:update(dt)
end

function FieldView:draw()
    love.graphics.push()

        love.graphics.translate(self.x, self.y)
        love.graphics.scale(self.scale)

        love.graphics.draw(self.ballsBatch)
        love.graphics.draw(self.cupsBatch)

    love.graphics.pop()
end

return FieldView
