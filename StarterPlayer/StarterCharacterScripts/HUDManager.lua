--This is mainly used to make sure the HUD fixes itself whenever the game's resolution changes
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

local HUDManager = {}

function HUDManager:CreateHUD()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameHUD"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.Parent = pgui

	local vignette = Instance.new("ImageLabel")
	vignette.Name = "StressOverlay"
	vignette.Size = UDim2.fromScale(1, 1)
	vignette.BackgroundTransparency = 1
	vignette.Image = "rbxassetid://623054178"
	vignette.ImageColor3 = Color3.fromRGB(0, 0, 0)
	vignette.ImageTransparency = 1
	vignette.Parent = screenGui

	local prompt = Instance.new("TextLabel")
	prompt.Name = "InteractionPrompt"
	prompt.Size = UDim2.fromScale(0.2, 0.05)
	prompt.Position = UDim2.fromScale(0.5, 0.8)
	prompt.AnchorPoint = Vector2.new(0.5, 0.5)
	prompt.BackgroundTransparency = 1
	prompt.Font = Enum.Font.GothamMedium
	prompt.TextColor3 = Color3.fromRGB(255, 255, 255)
	prompt.Text = "PRESS [E] TO INTERACT"
	prompt.Visible = false
	prompt.Parent = screenGui

	local textScale = Instance.new("UITextSizeConstraint")
	textScale.MaxTextSize = 24
	textScale.MinTextSize = 12
	textScale.Parent = prompt

	return screenGui
end

function HUDManager:UpdateStress(stressLevel)
	local overlay = pgui:FindFirstChild("GameHUD"):FindFirstChild("StressOverlay")
	if overlay then
		local alpha = 1 - (stressLevel / 200)
		overlay.ImageTransparency = alpha

		if stressLevel > 70 then
			overlay.ImageColor3 = Color3.fromRGB(50, 0, 0)
		else
			overlay.ImageColor3 = Color3.fromRGB(0, 0, 0)
		end
	end
end

return HUDManager
