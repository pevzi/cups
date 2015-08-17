local class = require "libs.middleclass"

local function initData(columns, rows)
    local data = {}

    local i = 1

    for r = 1, rows do
        data[r] = {}

        for c = 1, columns do
            data[r][c] = i
            i = i + 1
        end
    end

    return data
end

local function initBalls(balls, cups)
    assert(balls <= cups, "the ball number must not exceed the number of cups")

    local result = {}

    if balls == 1 then
        result[math.random(cups)] = true
        return result
    end

    local numbers = {}

    for i = 1, cups do
        numbers[i] = i
    end

    -- essentially a Fisher–Yates shuffle
    for i = 1, balls do
        local j = math.random(i, cups)
        numbers[i], numbers[j] = numbers[j], numbers[i]
        result[numbers[i]] = true
    end

    return result
end

local Field = class("Field")

function Field:initialize(columns, rows, balls)
    columns = columns or 3
    rows = rows or 1
    balls = balls or 1

    self.columns = columns
    self.rows = rows
    self.balls = balls

    self.data = initData(columns, rows)
    self.balls = initBalls(balls, columns * rows)
end

function Field:swap(n)
    -- TODO:
    -- choose n random pairs of adjacent cups
    -- swap these pairs
    -- return a table of affected IDs
end

function Field:hasBall(c, r)
    local id = self.data[r][c]
    return self.balls[id] or false, id
end

return Field
