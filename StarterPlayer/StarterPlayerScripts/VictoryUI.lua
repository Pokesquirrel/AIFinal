--Victory screen popup for when the players win
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameStateEvent = ReplicatedStorage.GameEvents.GameStateEvent
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--Creates the GUI popup
local function createVictoryScreen()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "VictoryScreen"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "VictoryFrame"
	frame.Size = UDim2.new(0.5, 0, 0.4, 0)
	frame.Position = UDim2.new(0.25, 0, 0.3, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 200, 100)
	stroke.Thickness = 3
	stroke.Parent = frame

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0.3, 0)
	title.Position = UDim2.new(0, 0, 0.1, 0)
	title.BackgroundTransparency = 1
	title.Text = "VICTORY!"
	title.TextColor3 = Color3.fromRGB(100, 255, 100)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = frame

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Size = UDim2.new(1, 0, 0.2, 0)
	subtitle.Position = UDim2.new(0, 0, 0.45, 0)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "You collected all 10 objectives!"
	subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	subtitle.TextScaled = true
	subtitle.Font = Enum.Font.Gotham
	subtitle.Parent = frame

	local winnerName = Instance.new("TextLabel")
	winnerName.Name = "WinnerName"
	winnerName.Size = UDim2.new(1, 0, 0.15, 0)
	winnerName.Position = UDim2.new(0, 0, 0.7, 0)
	winnerName.BackgroundTransparency = 1
	winnerName.Text = ""
	winnerName.TextColor3 = Color3.fromRGB(200, 200, 200)
	winnerName.TextScaled = true
	winnerName.Font = Enum.Font.Gotham
	winnerName.Parent = frame

	return screenGui, frame
end

local victoryGui, victoryFrame = createVictoryScreen()

--Checks for victory game state
GameStateEvent.OnClientEvent:Connect(function(state, winnerName)
	if state == "WIN" then
		victoryFrame.WinnerName.Text = "Winner: " .. winnerName
		victoryFrame.Visible = true
		
		victoryFrame.Size = UDim2.new(0, 0, 0, 0)
		victoryFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local tween = TweenService:Create(victoryFrame, tweenInfo, {
			Size = UDim2.new(0.5, 0, 0.4, 0),
			Position = UDim2.new(0.25, 0, 0.3, 0)
		})
		tween:Play()
		
		print("[VictoryUI] Victory screen displayed for " .. winnerName)
	elseif state == "LOSE" then
			--In case a lose screen was ever added
		print("[VictoryUI] Player lost: " .. winnerName)
	end
end)

print("[VictoryUI] Victory screen system loaded")
