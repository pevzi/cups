local res = require "resources"

local Cup = require "entities.cup"
local Ball = require "entities.ball"

local class = require "libs.middleclass"
local flux = require "libs.flux"

local ANGLE = math.pi * 0.8
local EASING = "quadinout"

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
    self.cupsBatch = love.graphics.newSpriteBatch(res.images.cup, field.columns * field.rows)
    self.ballsBatch = love.graphics.newSpriteBatch(res.images.ball)

    self.cups = {}
    self.balls = {}

    local cupWidth = res.images.cup:getWidth()
    local cupHeight = res.images.cup:getHeight()

    local xStep = cupWidth * 1.3
    local yStep = cupHeight * 1.55

    for r = 1, field.rows do
        for c = 1, field.columns do
            local id = field.cups[r][c]
            local cup = Cup((c - 1) * xStep, (r - 1) * yStep, self.cupsBatch)

            self.cups[id] = cup

            local ballColor = field:getBall(id)
            if ballColor then
                self.balls[cup] = Ball(res.colors[ballColor], self.ballsBatch)
            end
        end
    end

    local width = xStep * (field.columns - 1) + cupWidth
    local height = yStep * (field.rows - 1) + cupHeight

    self.x, self.y, self.scale = fitRect(width, height, l,t,w,h)

    self.tweens = flux.group()

    self.showingBalls = false
end

function FieldView:swap(swappedPairs, duration)
    if #self.tweens > 0 then
        self:completeTweens()
    end

    if self.showingBalls then
        self:showBalls(false, 0)
    end

    local swapper = Swapper(ANGLE)

    for _, pair in ipairs(swappedPairs) do
        local id1, id2 = pair[1], pair[2]

        local cup1 = self.cups[id1]
        local cup2 = self.cups[id2]

        swapper:addPair(cup1, cup2)
    end

    local tween = self.tweens:to(swapper, duration, {p = 1}):ease(EASING)

    tween:onupdate(function ()
        swapper:update()
    end)
end

function FieldView:showBalls(show, duration)
    if #self.tweens > 0 then
        self:completeTweens()
    end

    duration = duration or 0.5

    local easing, yoffset

    if show then
        easing = "backout"
        yoffset = -res.images.cup:getWidth() / 2
    else
        easing = "quadinout"
        yoffset = 0
    end

    if duration == 0 then
        for cup, ball in pairs(self.balls) do
            ball:updateSprite(cup)

            cup.yoffset = yoffset
            cup:updateSprite()

            self.showingBalls = show
        end

        return
    end

    local maxDelay = -1
    local lastTween

    for cup, ball in pairs(self.balls) do
        ball:updateSprite(cup)

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

    if show then
        self.showingBalls = true
    elseif lastTween then
        lastTween:oncomplete(function ()
            self.showingBalls = false
        end)
    end
end

function FieldView:completeTweens()
    self.tweens:update(math.huge)
end

function FieldView:update(dt)
    self.tweens:update(dt)
end

function FieldView:draw()
    love.graphics.push()

        love.graphics.translate(self.x, self.y)
        love.graphics.scale(self.scale)

        if self.showingBalls then
            love.graphics.draw(self.ballsBatch)
        end

        love.graphics.draw(self.cupsBatch)

    love.graphics.pop()
end

return FieldView
