local debounce = {}

local function setupTeleporterPair(model)
	local partA = model:FindFirstChild("TeleporterA")
	local partB = model:FindFirstChild("TeleporterB")
	
	if not partA or not partB then return end
	
	partA.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		
		if humanoid and not debounce[character] then
			debounce[character] = true
			
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = partB.CFrame + Vector3.new(0, 3, 0)
			end
			
			task.wait(1)
			debounce[character] = nil
		end
	end)
	
	partB.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		
		if humanoid and not debounce[character] then
			debounce[character] = true
			
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = partA.CFrame + Vector3.new(0, 3, 0)
			end
			
			task.wait(1)
			debounce[character] = nil
		end
	end)
end

for _, descendant in ipairs(workspace:GetDescendants()) do
	if descendant:IsA("Model") and descendant.Name == "TeleporterPair" then
		setupTeleporterPair(descendant)
	end
end

workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("Model") and descendant.Name == "TeleporterPair" then
		task.wait(0.1)
		setupTeleporterPair(descendant)
	end
end)
