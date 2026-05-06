--To play a jumpscare if the player gets caught by the "Hero"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local JumpscareEvent = ReplicatedStorage.GameEvents.JumpscareEvent
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function createJumpscareScreen()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "JumpscareScreen"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.Position = UDim2.new(0, 0, 0, 0)
	bg.BackgroundColor3 = Color3.new(0, 0, 0)
	bg.BorderSizePixel = 0
	bg.Visible = false
	bg.Parent = screenGui

	local image = Instance.new("ImageLabel")
	image.Name = "JumpscareImage"
	image.Size = UDim2.new(1, 0, 1, 0)
	image.Position = UDim2.new(0, 0, 0, 0)
	image.BackgroundTransparency = 1
	image.Image = "rbxassetid://7075805260"
	image.Visible = false
	image.Parent = bg

	local screamSound = Instance.new("Sound")
	screamSound.Name = "JumpscareSound"
	screamSound.SoundId = "rbxassetid://5796383890"
	screamSound.Volume = 1
	screamSound.Parent = bg

	return screenGui, bg, image, screamSound
end

local jumpscareGui, jumpscareBg, jumpscareImage, screamSound = createJumpscareScreen()

local function showJumpscare()
	jumpscareBg.Visible = true
	jumpscareImage.Visible = true
	screamSound:Play()

	local shakeInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 20, true)
	local shakeTween = TweenService:Create(jumpscareImage, shakeInfo, {
		Position = UDim2.new(0, math.random(-20, 20), 0, math.random(-20, 20)),
		Size = UDim2.new(1.2, 0, 1.2, 0)
	})
	shakeTween:Play()

	jumpscareImage.ImageTransparency = 1
	local fadeIn = TweenService:Create(jumpscareImage, TweenInfo.new(0.1), {
		ImageTransparency = 0
	})
	fadeIn:Play()

	task.delay(1.5, function()
		local fadeOut = TweenService:Create(jumpscareImage, TweenInfo.new(0.5), {
			ImageTransparency = 1
		})
		fadeOut:Play()
		fadeOut.Completed:Wait()
		jumpscareBg.Visible = false
		jumpscareImage.Size = UDim2.new(1, 0, 1, 0)
		jumpscareImage.Position = UDim2.new(0, 0, 0, 0)
	end)
end

--Checks if Jumpscare event activates
JumpscareEvent.OnClientEvent:Connect(function()
	print("[JumpscareUI] Jumpscare triggered!")
	showJumpscare()
end)

print("[JumpscareUI] Jumpscare system loaded")
