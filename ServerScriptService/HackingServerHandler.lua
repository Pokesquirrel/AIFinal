--Handles what happens after the hacking minigame door is opened, preventing the interaction from staying after the door is opened
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local hackingEvent = ReplicatedStorage.GameEvents:WaitForChild("HackingEvent")

hackingEvent.OnServerEvent:Connect(function(player, targetDoor, success)
	if success and targetDoor then
		local door = workspace:FindFirstChild(targetDoor)
		if door then
			for _, part in ipairs(door:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
					part.Transparency = 0.8
				end
			end
			
			local prompt = door:FindFirstChildOfClass("ProximityPrompt")
			if prompt then
				prompt:Destroy()
			end
			
			print(player.Name .. " successfully hacked " .. targetDoor)
		end
	end
end)
