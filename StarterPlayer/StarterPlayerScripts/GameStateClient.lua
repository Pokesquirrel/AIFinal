--This is used mainly to for the victory screen popup and keep the game moving when the server starts
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameStateEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("GameStateEvent")

GameStateEvent.OnClientEvent:Connect(function(state, playerName)
	if state == "WIN" then
		print(playerName .. " won!")
	elseif state == "LOSE" then
		print(playerName .. " lost!")
	end
end)
