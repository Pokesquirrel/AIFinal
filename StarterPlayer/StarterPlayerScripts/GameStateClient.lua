local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameStateEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("GameStateEvent")

GameStateEvent.OnClientEvent:Connect(function(state, playerName)
	if state == "WIN" then
		print(playerName .. " won!")
		-- Add win UI/logic here
	elseif state == "LOSE" then
		print(playerName .. " lost!")
		-- Add lose UI/logic here
	end
end)
