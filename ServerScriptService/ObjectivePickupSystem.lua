--Handles objective pickup collection
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local PICKUP_FOLDER_NAME = "ObjectivePickups"
-- Debounce to stop multiple collections of the same pickup
local collectedPickups = {}

local Objective = require(game.ServerScriptService.Game.ObjectiveSystem)

local function onPickupTouched(pickup, otherPart)
	if collectedPickups[pickup] then return end
	collectedPickups[pickup] = true
	
	local character = otherPart.Parent
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	
	if not humanoid then
		collectedPickups[pickup] = nil -- Reset if not a valid touch
		return
	end
	
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		collectedPickups[pickup] = nil -- Reset if not a player
		return
	end
	
	Objective:Collect(player)
	
	print(player.Name .. " collected an objective! Total: " .. Objective.Collected .. "/" .. Objective.Total)
	
	pickup:Destroy()
end

local function setupPickup(pickup)
	if pickup:IsA("BasePart") and pickup.Name == "ObjectivePickup" then
		pickup.Touched:Connect(function(otherPart)
			onPickupTouched(pickup, otherPart)
		end)
	end
end

local pickupFolder = Workspace:FindFirstChild(PICKUP_FOLDER_NAME)
if pickupFolder then
	for _, child in pickupFolder:GetChildren() do
		setupPickup(child)
	end
	
	pickupFolder.ChildAdded:Connect(setupPickup)
end

Workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("BasePart") and descendant.Name == "ObjectivePickup" then
		descendant.Touched:Connect(function(otherPart)
			onPickupTouched(descendant, otherPart)
		end)
	end
end)

print("ObjectivePickupSystem initialized!")
