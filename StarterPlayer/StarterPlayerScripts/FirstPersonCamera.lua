local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local isHacking = false
local originalMinZoom = 0.5
local originalMaxZoom = 400

local baseFOV = 70
local bobAmount = 0.5
local bobSpeed = 8
local time = 0

local function setFirstPerson()
	if not isHacking then
		player.CameraMode = Enum.CameraMode.LockFirstPerson
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
end

setFirstPerson()

player.CharacterAdded:Connect(function()
	task.wait(0.1)
	setFirstPerson()
end)

RunService.RenderStepped:Connect(function(dt)
	if isHacking then return end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if humanoid.MoveDirection.Magnitude > 0 then
		time += dt

		local xOffset = math.sin(time * bobSpeed) * (bobAmount * 0.6)
		local yOffset = math.abs(math.cos(time * bobSpeed)) * bobAmount

		local targetOffset = Vector3.new(xOffset, yOffset, 0)
		humanoid.CameraOffset = humanoid.CameraOffset:Lerp(targetOffset, 0.2)
	else
		humanoid.CameraOffset = humanoid.CameraOffset:Lerp(Vector3.new(0, 0, 0), 0.15)
		time = 0
	end
end)

local function setHackingMode(hacking)
	isHacking = hacking
	local player = Players.LocalPlayer

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if hacking then
		player.CameraMode = Enum.CameraMode.Classic

		originalMinZoom = player.CameraMinZoomDistance
		originalMaxZoom = player.CameraMaxZoomDistance

		player.CameraMinZoomDistance = 12
		player.CameraMaxZoomDistance = 12

		UserInputService.MouseBehavior = Enum.MouseBehavior.Default

		if humanoid then
			humanoid.CameraOffset = Vector3.new(0, 0, 0)
		end
	else
		player.CameraMinZoomDistance = originalMinZoom
		player.CameraMaxZoomDistance = originalMaxZoom

		player.CameraMode = Enum.CameraMode.LockFirstPerson
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

		if humanoid then
			humanoid.CameraOffset = Vector3.new(0, 0, 0)
		end
	end
end

_G.SetHackingMode = setHackingMode
