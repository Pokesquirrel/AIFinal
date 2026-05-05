local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local HackingUI = require(script.Parent:WaitForChild("HackingUI"))

local function findHackDoor()
	return workspace:FindFirstChild("HackDoor")
end

local function setupHackDoor()
	local hackDoor = findHackDoor()
	if not hackDoor then return end
	
	local prompt = hackDoor:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then return end
	
	prompt.Triggered:Connect(function()
		HackingUI.Start(hackDoor)
	end)
end

setupHackDoor()

workspace.DescendantAdded:Connect(function(descendant)
	if descendant.Name == "HackDoor" then
		task.wait(0.1)
		setupHackDoor()
	end
end)
