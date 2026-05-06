--Visual HeroAI Debugging Tool (Shows the HeroAI's vision cone)
--"/debug vision" or F9 activates/deactivates the debug tool
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local FOV_ANGLE = 60
local MAX_DISTANCE = 60

local debugEnabled = false
local debugParts = {}

--Used to create folder for debug visuals to spawn
local debugFolder = Instance.new("Folder")
debugFolder.Name = "VisionDebugParts"
debugFolder.Parent = workspace

--Creates the cone
local function createConePart()
	local part = Instance.new("Part")
	part.Name = "VisionConeDebug"
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.7
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 255, 0)
	part.CastShadow = false
	return part
end

--Stuff below creates line for being in the AI's vision
--The inital red line for when the player is outside the AI's vision was disabled
local function createLinePart()
	local part = Instance.new("Part")
	part.Name = "VisionLineDebug"
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.CastShadow = false
	return part
end

local function drawLine(startPos, endPos, color, thickness)
	local distance = (endPos - startPos).Magnitude
	if distance < 0.1 then return nil end
	
	local part = createLinePart()
	part.Size = Vector3.new(thickness, thickness, distance)
	part.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance/2)
	part.Color = color
	part.Parent = debugFolder
	
	return part
end

local function drawVisionCone(origin, lookVector, fovAngle, range)
	local parts = {}
	local halfAngle = math.rad(fovAngle / 2)
	local segments = 12
	
	for i = 0, segments do
		local angle = -halfAngle + (halfAngle * 2 / segments) * i
		local rotatedVector = CFrame.new(origin, origin + lookVector):ToWorldSpace(CFrame.Angles(0, angle, 0)).LookVector
		local endPoint = origin + rotatedVector * range
		
		local line = drawLine(origin, endPoint, Color3.fromRGB(255, 255, 0), 0.15)
		if line then
			table.insert(parts, line)
		end
	end
	
	for i = 0, segments - 1 do
		local angle1 = -halfAngle + (halfAngle * 2 / segments) * i
		local angle2 = -halfAngle + (halfAngle * 2 / segments) * (i + 1)
		
		local cf1 = CFrame.new(origin, origin + lookVector):ToWorldSpace(CFrame.Angles(0, angle1, 0))
		local cf2 = CFrame.new(origin, origin + lookVector):ToWorldSpace(CFrame.Angles(0, angle2, 0))
		
		local point1 = origin + cf1.LookVector * range
		local point2 = origin + cf2.LookVector * range
		
		local arcLine = drawLine(point1, point2, Color3.fromRGB(255, 255, 0), 0.15)
		if arcLine then
			table.insert(parts, arcLine)
		end
	end
	
	return parts
end

local function clearDebugParts()
	for _, part in pairs(debugParts) do
		if part and part.Parent then
			part:Destroy()
		end
	end
	debugParts = {}
end

local function findHeroAI()
	local npcsFolder = workspace:FindFirstChild("NPCs")
	if npcsFolder then
		for _, npc in pairs(npcsFolder:GetChildren()) do
			if npc.Name == "Hero" or npc:FindFirstChild("HeroAI") then
			return npc
			end
		end
	end
	
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:IsA("Model") and (descendant.Name == "Hero" or descendant.Name == "HeroAI") then
			return descendant
		end
	end
	
	return nil
end

local function canSeeTarget(viewerModel, targetModel)
	local viewerRoot = viewerModel:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
	
	if not viewerRoot or not targetRoot then 
		warn("[VisionDebug] Missing root parts")
		return false 
	end
	
	local direction = targetRoot.Position - viewerRoot.Position
	local distance = direction.Magnitude
	
	if distance > MAX_DISTANCE then 
		warn("[VisionDebug] Too far: " .. math.floor(distance) .. " > " .. MAX_DISTANCE)
		return false 
	end
	
	local dirUnit = direction.Unit
	local forward = viewerRoot.CFrame.LookVector
	local dot = forward:Dot(dirUnit)
	local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
	
	if angle > FOV_ANGLE / 2 then
		warn("[VisionDebug] Outside FOV: " .. math.floor(angle) .. "° > " .. (FOV_ANGLE / 2) .. "°")
		return false 
	end
	
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {viewerModel, debugFolder}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local result = workspace:Raycast(viewerRoot.Position, direction, rayParams)
	
	if result and not result.Instance:IsDescendantOf(targetModel) then
		warn("[VisionDebug] Blocked by: " .. result.Instance.Name .. " (" .. result.Instance.ClassName .. ")")
		return false
	end
	
	print("[VisionDebug] CAN SEE TARGET!")
	return true
end

local function updateDebug()
	if not debugEnabled then
		clearDebugParts()
		return
	end
	
	clearDebugParts()
	
	local heroModel = findHeroAI()
	if not heroModel then return end
	
	local heroRoot = heroModel:FindFirstChild("HumanoidRootPart")
	if not heroRoot then return end
	
	local coneParts = drawVisionCone(heroRoot.Position, heroRoot.CFrame.LookVector, FOV_ANGLE, MAX_DISTANCE)
	for _, part in pairs(coneParts) do
		table.insert(debugParts, part)
	end
	
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local visible = canSeeTarget(heroModel, player.Character)

			--Draws Green line when player is visible to the AI during debug
			if visible then
				local line = drawLine(
					heroRoot.Position,
					player.Character.HumanoidRootPart.Position,
					Color3.fromRGB(0, 255, 0),
					0.2
				)
				if line then
					table.insert(debugParts, line)
				end
			end
		end
	end
end

local function toggleDebug()
	debugEnabled = not debugEnabled
	print("HeroAI Vision Debug: " .. (debugEnabled and "ENABLED" or "DISABLED"))
	if not debugEnabled then
		clearDebugParts()
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.V then
		toggleDebug()
	end
end)

local player = Players.LocalPlayer
player.Chatted:Connect(function(message)
	if message:lower() == "/debug vision" then
		toggleDebug()
	end
end)

RunService.RenderStepped:Connect(updateDebug)

print("HeroAI Vision Debug loaded! Press V to toggle.")
