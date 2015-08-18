local r = require "resources"

local Cup = require "entities.cup"

local class = require "libs.middleclass"

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
            if field:hasBall(c, r) then self.batch:setColor(255, 0, 0, 255)
            else self.batch:setColor() end

            table.insert(self.cups, Cup((c - 1) * xStep, (r - 1) * yStep, self.batch))
        end
    end

    self.batch:setColor(255, 0, 0, 255) -- workaround for what is presumably a love2d bug?

    local width = xStep * (field.columns - 1) + cupWidth
    local height = yStep * (field.rows - 1) + cupHeight

    self.x, self.y, self.scale = fitRect(width, height, l,t,w,h)
end

function FieldView:startSwap(cup1id, cup2id, duration)

end

function FieldView:update(dt)

end

function FieldView:draw()
    love.graphics.push()

        love.graphics.translate(self.x, self.y)
        love.graphics.scale(self.scale)

        love.graphics.draw(self.batch)

    love.graphics.pop()
end

return FieldView
