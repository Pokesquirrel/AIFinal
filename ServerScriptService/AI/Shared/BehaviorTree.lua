local BehaviorTree = {}

BehaviorTree.NodeStatus = {
	Success = "Success",
	Failure = "Failure",
	Running = "Running"
}

function BehaviorTree.Selector(children)
	return function(...)
		for _, child in ipairs(children) do
			local status = child(...)
			if status ~= BehaviorTree.NodeStatus.Failure then
				return status
			end
		end
		return BehaviorTree.NodeStatus.Failure
	end
end

function BehaviorTree.Sequence(children)
	return function(...)
		for _, child in ipairs(children) do
			local status = child(...)
			if status ~= BehaviorTree.NodeStatus.Success then
				return status
			end
		end
		return BehaviorTree.NodeStatus.Success
	end
end

function BehaviorTree.Task(fn)
	return fn
end

return BehaviorTree
