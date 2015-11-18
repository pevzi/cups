local res = require "resources"

local class = require "libs.middleclass"

local function initCups(columns, rows)
    local cups = {}

    local id = 1

    for r = 1, rows do
        cups[r] = {}

        for c = 1, columns do
            cups[r][c] = id
            id = id + 1
        end
    end

    return cups
end

local function initBalls(nballs, ncups)
    assert(nballs <= ncups, "the number of balls must not exceed the number of cups")

    local result = {}

    if nballs == 1 then
        result[math.random(ncups)] = next(res.colors)
        return result
    end

    local numbers = {}

    for i = 1, ncups do
        numbers[i] = i
    end

    local color

    -- essentially a Fisher–Yates shuffle
    for i = 1, nballs do
        color = next(res.colors, color) or next(res.colors)

        local j = math.random(i, ncups)
        numbers[i], numbers[j] = numbers[j], numbers[i]

        result[numbers[i]] = color
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

function Field:initialize(columns, rows, nballs)
    self.columns = columns or 3
    self.rows = rows or 1

    nballs = nballs or 1

    self.cups = initCups(self.columns, self.rows)
    self.balls = initBalls(nballs, self.columns * self.rows)
end

function Field:swap(n)
    -- TODO: probably think of a more efficient way to generate non-overlapping random pairs of adjacent cups
    -- because at the moment it's just a naive brute force with limited number of trials

    n = n or 1

    local swapped = {}

    for i = 1, n do
        local c1, r1, c2, r2
        local id1, id2

        local maxTrials = 10
        local trials = 0

        repeat
            if trials >= maxTrials then
                return swapped
            end

            c1, r1, c2, r2 = choosePair(self.columns, self.rows)
            id1, id2 = self.cups[r1][c1], self.cups[r2][c2]

            trials = trials + 1

        until i == 1 or (swapped[id1] == nil and swapped[id2] == nil)

        self.cups[r1][c1], self.cups[r2][c2] = id2, id1

        swapped[id1] = {c2, r2}
        swapped[id2] = {c1, r1}
    end

    return swapped
end

function Field:getBall(c, r)
    local id = r and self.cups[r][c] or c
    return self.balls[id], id
end

return Field
