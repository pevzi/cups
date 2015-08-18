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

local function choosePair(columns, rows)
    local c1, r1, c2, r2

    local h = rows * (columns - 1) -- total number of horizontal pairs
    local v = columns * (rows - 1) -- total number of vertical pairs

    if math.random(h + v) <= h then -- choose a horizontal pair
        c1 = math.random(columns - 1)
        r1 = math.random(rows)
        c2 = c1 + 1
        r2 = r1
    else -- choose a vertical pair
        c1 = math.random(columns)
        r1 = math.random(rows - 1)
        c2 = c1
        r2 = r1 + 1
    end

    return c1, r1, c2, r2
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
    -- TODO: probably think of a more efficient way to generate non-overlapping random pairs of adjacent cups
    -- because at the moment it's just a naive brute force with limited number of trials

    n = n or 1

    local swapped = {}
    local swappedPairs = {}

    for i = 1, n do
        local c1, r1, c2, r2
        local id1, id2

        local maxTrials = 10
        local trials = 0

        repeat
            if trials >= maxTrials then
                return
            end

            c1, r1, c2, r2 = choosePair(self.columns, self.rows)
            id1, id2 = self.data[r1][c1], self.data[r2][c2]

            trials = trials + 1

        until i == 1 or (swapped[id1] == nil and swapped[id2] == nil)

        swapped[id1] = true
        swapped[id2] = true

        self.data[r1][c1], self.data[r2][c2] = id2, id1

        table.insert(swappedPairs, {id1, id2})
    end

    return swappedPairs
end

function Field:hasBall(c, r)
    local id = self.data[r][c]
    return self.balls[id] or false, id
end

return Field
