local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local event = ReplicatedStorage.GameEvents:WaitForChild("HackingEvent")

local targetWord = "UNLOCK"
local currentIndex = 1
local active = false
local targetDoor = nil
local letterButtons = {}

local gui = Instance.new("ScreenGui")
gui.Name = "HackingMinigame"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "HackFrame"
frame.Size = UDim2.fromScale(0.75, 0.65)
frame.Position = UDim2.fromScale(0.125, 0.15)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 100)
frame.Visible = false
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 0.1)
title.Position = UDim2.fromScale(0, 0.02)
title.BackgroundTransparency = 1
title.Text = "HACK TERMINAL - Spell: UNLOCK"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.TextScaled = true
title.Font = Enum.Font.Code
title.Parent = frame

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.fromScale(0.9, 0.1)
targetLabel.Position = UDim2.fromScale(0.05, 0.12)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = ""
targetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
targetLabel.TextScaled = true
targetLabel.Font = Enum.Font.Code
targetLabel.Parent = frame

local lettersContainer = Instance.new("Frame")
lettersContainer.Name = "LettersContainer"
lettersContainer.Size = UDim2.fromScale(0.96, 0.55)
lettersContainer.Position = UDim2.fromScale(0.02, 0.4)
lettersContainer.BackgroundTransparency = 1
lettersContainer.Parent = frame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.fromScale(0.09, 0.07)
gridLayout.CellPadding = UDim2.fromScale(0.01, 0.01)
gridLayout.Parent = lettersContainer

local instructions = Instance.new("TextLabel")
instructions.Size = UDim2.fromScale(0.96, 0.06)
instructions.Position = UDim2.fromScale(0.02, 0.92)
instructions.BackgroundTransparency = 1
instructions.Text = "Click letters in order: U → N → L → O → C → K"
instructions.TextColor3 = Color3.fromRGB(150, 150, 150)
instructions.TextScaled = true
instructions.Font = Enum.Font.Code
instructions.Parent = frame

local function updateTargetDisplay()
	local display = ""
	for i = 1, #targetWord do
		if i < currentIndex then
			display = display .. "[" .. targetWord:sub(i, i) .. "]"
		else
			display = display .. "_"
		end
		if i < #targetWord then display = display .. " " end
	end
	targetLabel.Text = display
end

local function shuffleLetters()
	local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local shuffled = {}
	for char in string.gmatch(letters, ".") do
		table.insert(shuffled, char)
	end
	for i = #shuffled, 2, -1 do
		local j = math.random(1, i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
	return shuffled
end

local function createLetterButtons()
	for _, btn in pairs(letterButtons) do
		if btn then btn:Destroy() end
	end
	letterButtons = {}
	
	local shuffledLetters = shuffleLetters()
	
	for _, letter in ipairs(shuffledLetters) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromScale(1, 1)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		btn.TextColor3 = Color3.fromRGB(0, 255, 100)
		btn.Text = letter
		btn.TextScaled = true
		btn.Font = Enum.Font.Code
		btn.BorderSizePixel = 2
		btn.BorderColor3 = Color3.fromRGB(0, 255, 100)
		btn.Parent = lettersContainer
		
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 5)
		btnCorner.Parent = btn
		
		btn.MouseButton1Click:Connect(function()
			if not active then return end
			
			local expectedLetter = targetWord:sub(currentIndex, currentIndex)
			
			if letter == expectedLetter then
				btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
				btn.TextColor3 = Color3.fromRGB(200, 255, 200)
				btn.BorderColor3 = Color3.fromRGB(0, 255, 0)
				currentIndex += 1
				updateTargetDisplay()
				
				if currentIndex > #targetWord then
					active = false
					event:FireServer(targetDoor, true)
					task.wait(0.5)
					frame.Visible = false
					if _G.SetHackingMode then
						_G.SetHackingMode(false)
					end
				end
			else
				btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
				btn.TextColor3 = Color3.fromRGB(255, 100, 100)
				btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
				active = false
				event:FireServer(targetDoor, false)
				task.wait(0.5)
				frame.Visible = false
				if _G.SetHackingMode then
					_G.SetHackingMode(false)
				end
			end
		end)
		
		table.insert(letterButtons, btn)
	end
end

local function startHack(door)
	if active then return end
	
	targetDoor = door
	active = true
	currentIndex = 1
	
	if _G.SetHackingMode then
		_G.SetHackingMode(true)
	end
	
	frame.Visible = true
	updateTargetDisplay()
	createLetterButtons()
end

return {
	Start = startHack
}
