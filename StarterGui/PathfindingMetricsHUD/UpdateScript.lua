--This is used to visually show how fast the AI determines a new path to find the player
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DebugMetricsEvent = ReplicatedStorage.GameEvents.DebugMetrics

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("PathfindingMetricsHUD")
local valueLabel = hud:WaitForChild("MetricsFrame"):WaitForChild("ValueLabel")

local function updateColor(ms)
	if ms < 5 then
		valueLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	elseif ms < 20 then
		valueLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	else
		valueLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	end
end

DebugMetricsEvent.OnClientEvent:Connect(function(metricType, value)
	if metricType == "PathfindingTime" then
		local ms = tonumber(value) or 0
		valueLabel.Text = string.format("%.2f ms", ms)
		updateColor(ms)
	end
end)
