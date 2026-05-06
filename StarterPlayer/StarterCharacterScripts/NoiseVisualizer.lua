--Used by the SensoryModule to see if the AI should hear any noises
--Does not create any visual results for the players
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local NoiseVisualizer = {}

function NoiseVisualizer:Init()
end

function NoiseVisualizer:CreateRipple(position, intensity)
	local part = Instance.new("Part")
	part.Name = "NoiseRipple"
	part.Position = position
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(1, 1, 1)
	part.Material = Enum.Material.ForceField
	part.Transparency = 0.5
	part.CanCollide = false
	part.Anchored = true
	part.Parent = workspace

	local targetSize = intensity * 10
	task.spawn(function()
		for i = 1, 10 do
			part.Size = Vector3.new(targetSize * (i/10), targetSize * (i/10), targetSize * (i/10))
			part.Transparency = 0.5 + (i/20)
			task.wait(0.05)
		end
		part:Destroy()
	end)
end

return NoiseVisualizer
