local res = require "resources"

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

local Swapper = class("Swapper")

function Swapper:initialize(angle)
    self.angle = angle
    self.funcs = {}
    self.p = 0
end

function Swapper:addPair(cup1, cup2)
    local arc1 = makeArc(cup1.x, cup1.y, cup2.x, cup2.y, self.angle)
    local arc2 = makeArc(cup2.x, cup2.y, cup1.x, cup1.y, self.angle)

    local func = function (p)
        cup1:setPosition(arc1(p))
        cup2:setPosition(arc2(p))
    end

    table.insert(self.funcs, func)
end

function Swapper:update()
    for _, func in ipairs(self.funcs) do
        func(self.p)
    end
end

local FieldView = class("FieldView")

function FieldView:initialize(field, l,t,w,h)
    self.batch = love.graphics.newSpriteBatch(res.images.cup, field.columns * field.rows)

    self.cups = {}

    local cupWidth = res.images.cup:getWidth()
    local cupHeight = res.images.cup:getHeight()

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
end

function FieldView:swap(swappedPairs, duration)
    local swapper = Swapper(ANGLE)

    for _, pair in ipairs(swappedPairs) do
        local id1, id2 = pair[1], pair[2]

        local cup1 = self.cups[id1]
        local cup2 = self.cups[id2]

        swapper:addPair(cup1, cup2)
    end

    self.swapTween = tween.new(duration, swapper, {p = 1}, EASING)
end

function FieldView:stopTweens()
    if self.swapTween then
        self.swapTween:set(self.swapTween.duration)
        self.swapTween.subject:update()
    end

    self.swapTween = nil
end

function FieldView:update(dt)
    if self.swapTween then
        local complete = self.swapTween:update(dt)

        self.swapTween.subject:update()

        if complete then
            self.swapTween = nil
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
