--Initially used to test a noninteractive version of the hacking and lockpicking minigame
local Objective = require(script.Parent.ObjectiveSystem)

local InteractionSystem = {}

function InteractionSystem:Lockpick(player)
	return math.random() > 0.5
end

function InteractionSystem:Hack(player)
	return math.random() > 0.3
end

return InteractionSystem
