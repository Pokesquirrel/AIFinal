local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage.GameEvents.ObjectiveUpdate

local ObjectiveSystem = {}

ObjectiveSystem.Total = 10
ObjectiveSystem.Collected = 0

function ObjectiveSystem:Collect(player)
	self.Collected += 1
	event:FireAllClients(self.Collected, self.Total)

	if self.Collected == 1 then
		local AIManager = require(game.ServerScriptService.AI.AIManager)
		AIManager:SpawnHero()
		print("[ObjectiveSystem] First objective collected! Hero spawned.")
	end

	if self.Collected >= self.Total then
		local AIManager = require(game.ServerScriptService.AI.AIManager)
		AIManager:RemoveHero()
		
		require(script.Parent.GameStateManager):Win(player)
	end
end

return ObjectiveSystem
