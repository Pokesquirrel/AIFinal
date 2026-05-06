--Starts the game loop, and has a system for if a reset function was ever added
local Players = game:GetService("Players")
local GameState = require(script.Parent.GameStateManager)

local Round = {}

function Round:Start()
	print("Round Started")
end

function Round:Reset()
	for _, p in ipairs(Players:GetPlayers()) do
		p:LoadCharacter()
	end
end

return Round
