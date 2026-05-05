local Metrics = require(script.Parent.Parent.Systems.Metrics)
local event = game.ReplicatedStorage.GameEvents.DebugMetrics

local MetricsBroadcaster = {}

function MetricsBroadcaster.Start()
	task.spawn(function()
		while true do
			task.wait(2)
			event:FireAllClients(Metrics:GetReport())
		end
	end)
end

return MetricsBroadcaster
