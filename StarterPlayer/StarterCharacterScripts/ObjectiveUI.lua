local event = game.ReplicatedStorage.GameEvents.ObjectiveUpdate
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:FindFirstChild("ObjectiveUI")

local label

if not gui then

	gui = Instance.new("ScreenGui")
	gui.Name = "ObjectiveUI"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui


	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(0.18, 0.07)
	frame.Position = UDim2.fromScale(0.02, 0.02)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BackgroundTransparency = 0.2
	frame.Parent = gui

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 12)

	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.5

	local padding = Instance.new("UIPadding", frame)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)

	label = Instance.new("TextLabel")
	label.Name = "ObjectiveLabel"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Text = "0 / 10"
	label.Parent = frame
else

	label = gui:FindFirstChild("Frame"):FindFirstChild("ObjectiveLabel")
end

event.OnClientEvent:Connect(function(collected, total)
	if label then
		label.Text = collected .. " / " .. total
	end
end)
