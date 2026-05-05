local event = game.ReplicatedStorage.GameEvents.HackingEvent
local Threat = require(game.ServerScriptService.AI.Systems.ThreatSystem)
local Objective = require(script.Parent.ObjectiveSystem)

event.OnServerEvent:Connect(function(player, door, success)
	if success then
      
		if door and door:IsA("BasePart") then
			door.Transparency = 0.8
			door.CanCollide = false
			
			local prompt = door:FindFirstChildOfClass("ProximityPrompt")
			if prompt then
				prompt.Enabled = false
			end
			
			task.delay(5, function()
				door:Destroy()
			end)
		end
	else
		Threat:AddStress(player, 15)
	end
end)
