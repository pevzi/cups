local Play = require "gamestates.play"
local Pause = require "gamestates.pause"

local class = require "libs.middleclass"
local Stateful = require "libs.stateful"

local Game = class("Game"):include(Stateful)

function Game:initialize()
    self:gotoState("Play", {})
end

function Game:focus(f) end
function Game:keypressed(key) end
function Game:update(dt) end
function Game:draw() end

Game:addState("Play", Play)
Game:addState("Pause", Pause)

return Game
