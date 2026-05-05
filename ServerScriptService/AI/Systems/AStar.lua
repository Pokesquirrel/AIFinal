local AStar = {}

local function heuristic(a, b)
	return (a - b).Magnitude
end

local DIRECTIONS = {
	Vector3.new(1, 0, 0),
	Vector3.new(-1, 0, 0),
	Vector3.new(0, 0, 1),
	Vector3.new(0, 0, -1),
}

local function toKey(pos, step)
	local x = math.floor(pos.X / step + 0.5)
	local z = math.floor(pos.Z / step + 0.5)
	return x .. "," .. z
end

local function fromKey(key, step, baseY)
	local x, z = key:match("(-?%d+),(-?%d+)")
	return Vector3.new(tonumber(x) * step, baseY, tonumber(z) * step)
end

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

function AStar.FindPath(startPos, goalPos, step, filterList)
	step = step or 4

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterList or {}

	local gScore = {}
	local fScore = {}
	local cameFrom = {}
	local closed = {}

	local startKey = toKey(startPos, step)
	local goalKey = toKey(goalPos, step)

	gScore[startKey] = 0
	fScore[startKey] = heuristic(startPos, goalPos)

	local openSet = {startKey}

	local iterations = 0
	local maxIterations = 8000

	while #openSet > 0 and iterations < maxIterations do
		iterations += 1

		table.sort(openSet, function(a, b)
			return (fScore[a] or math.huge) < (fScore[b] or math.huge)
		end)

		local currentKey = table.remove(openSet, 1)

		if currentKey == goalKey then
			local path = {}
			local key = currentKey

			while key do
				local pos = fromKey(key, step, startPos.Y)
				table.insert(path, 1, pos)
				key = cameFrom[key]
			end

			return path
		end

		closed[currentKey] = true
		local currentPos = fromKey(currentKey, step, startPos.Y)

		for _, dir in ipairs(DIRECTIONS) do
			local neighborPos = currentPos + dir * step
			local neighborKey = toKey(neighborPos, step)

			if closed[neighborKey] then
				continue
			end

			if isBlocked(neighborPos, raycastParams) then
				closed[neighborKey] = true
				continue
			end

			local tentativeG = (gScore[currentKey] or math.huge) + step

			if tentativeG < (gScore[neighborKey] or math.huge) then
				cameFrom[neighborKey] = currentKey
				gScore[neighborKey] = tentativeG
				fScore[neighborKey] = tentativeG + heuristic(neighborPos, goalPos)

				if not table.find(openSet, neighborKey) then
					table.insert(openSet, neighborKey)
				end
			end
		end
	end

	return nil
end

return AStar
