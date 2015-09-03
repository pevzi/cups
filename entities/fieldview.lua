local r = require "resources"

local Cup = require "entities.cup"

local class = require "libs.middleclass"
local tween = require "libs.tween"

local ANGLE = math.pi * 0.8
local EASING = "inOutQuad"

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

local function makeArcMover(x1, y1, x2, y2, subject, angle)
    angle = angle or math.pi

    local dist = math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
    local radius = dist / 2 / math.sin(angle / 2)
    local offset = math.cos(angle / 2) * radius

    local mx = (x1 + x2) / 2
    local my = (y1 + y2) / 2

    local cx = -(y2 - y1) / 2 / (dist / 2) * offset + mx
    local cy =  (x2 - x1) / 2 / (dist / 2) * offset + my

    local startAngle = math.atan2(y1 - y2, x1 - x2) - (angle / 2) + (math.pi / 2)

    return {
        p = 0,

        updatePosition = function (self)
            local currentAngle = startAngle + self.p * angle
            subject.x = math.cos(currentAngle) * radius + cx
            subject.y = math.sin(currentAngle) * radius + cy
            subject:updatePosition()
        end
    }
end

local FieldView = class("FieldView")

function FieldView:initialize(field, l,t,w,h)
    self.batch = love.graphics.newSpriteBatch(r.images.cup, field.columns * field.rows)

    self.cups = {}

    local cupWidth = r.images.cup:getWidth()
    local cupHeight = r.images.cup:getHeight()

    local xStep = cupWidth * 1.3
    local yStep = cupHeight * 1.3

    for r = 1, field.rows do
        for c = 1, field.columns do
            table.insert(self.cups, Cup((c - 1) * xStep, (r - 1) * yStep, self.batch))
        end
    end

    local width = xStep * (field.columns - 1) + cupWidth
    local height = yStep * (field.rows - 1) + cupHeight

    self.x, self.y, self.scale = fitRect(width, height, l,t,w,h)

    self.tweens = {}
end

function FieldView:startSwap(id1, id2, duration)
    local cup1 = self.cups[id1]
    local cup2 = self.cups[id2]

    local mover1 = makeArcMover(cup1.x, cup1.y, cup2.x, cup2.y, cup1, ANGLE)
    local mover2 = makeArcMover(cup2.x, cup2.y, cup1.x, cup1.y, cup2, ANGLE)

    local t1 = tween.new(duration, mover1, {p = 1}, EASING)
    local t2 = tween.new(duration, mover2, {p = 1}, EASING)

    self.tweens[t1] = true
    self.tweens[t2] = true
end

function FieldView:stopTweens()
    for t in pairs(self.tweens) do
        t:set(t.duration)
        t.subject:updatePosition()
    end

    self.tweens = {}
end

function FieldView:update(dt)
    for t in pairs(self.tweens) do
        local complete = t:update(dt)

        t.subject:updatePosition()

        if complete then
            self.tweens[t] = nil
        end
    end
end

function FieldView:draw()
    love.graphics.push()

        love.graphics.translate(self.x, self.y)
        love.graphics.scale(self.scale)

        love.graphics.draw(self.batch)

    love.graphics.pop()
end

return FieldView
