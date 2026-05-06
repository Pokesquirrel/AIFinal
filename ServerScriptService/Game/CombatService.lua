--Handles what should happen if the player was to be touched by the AI
local Players = game:GetService("Players")
local GameState = require(script.Parent.GameStateManager)

local playersLost = {}
local connections = {}

local Combat = {}

function Combat:Reset()
	playersLost = {}
end

local function onTouch(otherPart, npcModel)
	local character = otherPart.Parent
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	
	if not humanoid then return end
	if humanoid.Health <= 0 then return end
	
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end
	if playersLost[player] then return end
	
	playersLost[player] = true
	humanoid.Health = 0
	GameState:Lose(player)
end

local function setupTouchForNPC(npcModel)
	if connections[npcModel] then return end
	
	for _, part in ipairs(npcModel:GetDescendants()) do
		if part:IsA("BasePart") then
			local conn = part.Touched:Connect(function(otherPart)
				onTouch(otherPart, npcModel)
			end)
			table.insert(connections, conn)
		end
	end
	
	connections[npcModel] = true
end

function Combat:Start()
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") then
			setupTouchForNPC(descendant)
		end
	end
	
	workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") then
			setupTouchForNPC(descendant)
		end
	end)
end

return Combat
