local AStar = {}

--Heurstic (For straight-line distances)
local function heuristic(a, b)
	return (a - b).Magnitude
end

-- 4-directional movement
local DIRECTIONS = {
	Vector3.new(1, 0, 0),
	Vector3.new(-1, 0, 0),
	Vector3.new(0, 0, 1),
	Vector3.new(0, 0, -1),
}

--Converts postion to the grid key
local function toKey(pos, step)
	local x = math.floor(pos.X / step + 0.5)
	local z = math.floor(pos.Z / step + 0.5)
	return x .. "," .. z
end

--Converts the key to world position
local function fromKey(key, step, baseY)
	local x, z = key:match("(-?%d+),(-?%d+)")
	return Vector3.new(tonumber(x) * step, baseY, tonumber(z) * step)
end

--Checks if anything is blocked and that there is a ground to walk on
local function isBlocked(pos, raycastParams)
	local ground = workspace:Raycast(
		pos + Vector3.new(0, 3, 0),
		Vector3.new(0, -6, 0),
		raycastParams
	)

	if not ground then
		return true
	end

	local hit = workspace:Raycast(
		pos + Vector3.new(0, 2, 0),
		Vector3.new(0, 0, 0),
		raycastParams
	)

	return hit ~= nil
end

--Main A* function
function AStar.FindPath(startPos, goalPos, step, filterList)
	step = step or 4

	--Raycast setup for obstacle detection
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterList or {}

	--A* data tables
	local gScore = {} --The cost from the start to the node
	local fScore = {} --Estimated cost of g + heuristic
	local cameFrom = {} -- path reconstructed map
	local closed = {} -- visited/processed nodes

	--Converts positions into the grid keys
	local startKey = toKey(startPos, step)
	local goalKey = toKey(goalPos, step)

	--Starts start node costs
	gScore[startKey] = 0
	fScore[startKey] = heuristic(startPos, goalPos)

	--Nodes to explore
	local openSet = {startKey}

	local iterations = 0
	local maxIterations = 8000

	--Main A* loop
	while #openSet > 0 and iterations < maxIterations do
		iterations += 1

		--Sort the open set by lowest fScore (For the priority queue behavior)
		table.sort(openSet, function(a, b)
			return (fScore[a] or math.huge) < (fScore[b] or math.huge)
		end)

		--Get the node with the lowest estimated cost
		local currentKey = table.remove(openSet, 1)

		--After the goal is reached, reconstruct the path
		if currentKey == goalKey then
			local path = {}
			local key = currentKey

			--Backtracking from the cameFrom map
			while key do
				local pos = fromKey(key, step, startPos.Y)
				table.insert(path, 1, pos)
				key = cameFrom[key]
			end

			return path
		end

		--Processed nodes are marked
		closed[currentKey] = true
		local currentPos = fromKey(currentKey, step, startPos.Y)

		--Check neighbors
		for _, dir in ipairs(DIRECTIONS) do
			local neighborPos = currentPos + dir * step
			local neighborKey = toKey(neighborPos, step)

			--Skip if it is already processed
			if closed[neighborKey] then
				continue
			end

			--Skip and close permantely if its blocked (helps future scans)
			if isBlocked(neighborPos, raycastParams) then
				closed[neighborKey] = true
				continue
			end

			--Unconfirmed cost from start to neighbor
			local tentativeG = (gScore[currentKey] or math.huge) + step

			--Record better path
			if tentativeG < (gScore[neighborKey] or math.huge) then
				cameFrom[neighborKey] = currentKey
				gScore[neighborKey] = tentativeG
				fScore[neighborKey] = tentativeG + heuristic(neighborPos, goalPos)

				--Add to open set if its not already there
				if not table.find(openSet, neighborKey) then
					table.insert(openSet, neighborKey)
				end
			end
		end
	end

	--Not path was found
	return nil
end

return AStar
