local BaseAI = require(game.ServerScriptService.AI.Shared.BaseAI)
local Sensory = require(game.ReplicatedStorage.Shared.SensoryModule)
local Memory = require(game.ReplicatedStorage.Shared.MemorySystem)
local Director = require(game.ServerScriptService.DirectorAI)
local Threat = require(script.Parent.Parent.Systems.ThreatSystem)
local Metrics = require(script.Parent.Parent.Systems.Metrics)
local Tracker = require(game.ServerScriptService.AI.Systems.PlayerBehaviorTracker)
local AStar = require(game.ServerScriptService.AI.Systems.AStar)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JumpscareEvent = ReplicatedStorage.GameEvents.JumpscareEvent

local HeroAI = setmetatable({}, BaseAI)
HeroAI.__index = HeroAI

local DebugMetricsEvent = ReplicatedStorage.GameEvents.DebugMetrics

function HeroAI.new(model)
	local self = BaseAI.new(model)
	setmetatable(self, HeroAI)

	self.Memory = Memory.new(10)
	self.Target = nil

	self.State = "Patrol"
	self.HuntTarget = nil

	self.CurrentPath = nil
	self.PathIndex = 1
	self.LastPathTime = 0
	self.LastGoalPos = Vector3.new(0, 0, 0)

	self.HuntTimer = 0
	self.LOST_SIGHT_TIMEOUT = 3.0

	return self
end

function HeroAI:ScoreTarget(player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return -math.huge end

	local dist = (self.Root.Position - root.Position).Magnitude
	local stress = Threat:GetStress(player)
	local visible = Sensory.CanSee(self.Model, player.Character, 60)

	return (100 - dist) + (stress * 2) + (visible and 50 or 0)
end

function HeroAI:Think()
	local currentTime = tick()

	local visiblePlayer = nil
	local closestVisibleDist = math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local visible = Sensory.CanSee(self.Model, p.Character, 500)
			if visible then
				local dist = (self.Root.Position - p.Character.HumanoidRootPart.Position).Magnitude
				if dist < closestVisibleDist then
					closestVisibleDist = dist
					visiblePlayer = p
				end
			end
		end
	end

	if self.State == "Hunt" then
		if visiblePlayer then
			self.HuntTimer = currentTime
			if visiblePlayer ~= self.HuntTarget then
				self.HuntTarget = visiblePlayer
				self.Target = visiblePlayer
			end
		else
			if currentTime - self.HuntTimer > self.LOST_SIGHT_TIMEOUT then
				self.State = "Patrol"
				self.HuntTarget = nil
				self.Target = nil
				print("[HeroAI] Lost target, returning to patrol")
			end
		end
		return
	end

	if visiblePlayer then
		Metrics:PlayerDetected()
		self.State = "Hunt"
		self.HuntTarget = visiblePlayer
		self.Target = visiblePlayer
		self.HuntTimer = tick()
		print("[HeroAI] PLAYER DETECTED! Switching to HUNT mode. Target:", visiblePlayer.Name)
		return
	end

	local bestScore = -math.huge
	local bestPlayer = nil

	for _, p in ipairs(Players:GetPlayers()) do
		local score = self:ScoreTarget(p)
		if score > bestScore then
			bestScore = score
			bestPlayer = p
		end
	end

	self.Target = bestPlayer
	if self.State ~= "Hunt" then
		self.State = "Patrol"
	end
	self.HuntTarget = nil
end

function HeroAI:GetPath(goalPos)
	local now = tick()

	if self.Target and self.Target.Character then
		local root = self.Target.Character:FindFirstChild("HumanoidRootPart")
		if root then
			if (self.LastGoalPos - root.Position).Magnitude > 10 then
				self.LastPathTime = 0
			end
			self.LastGoalPos = root.Position
		end
	end

	if self.CurrentPath and (now - self.LastPathTime < 3) then
		return self.CurrentPath
	end

	self.LastPathTime = now
	
	local startTime = os.clock()
	self.CurrentPath = AStar.FindPath(self.Root.Position, goalPos, 6)
	local endTime = os.clock()
	local pathfindingMs = (endTime - startTime) * 1000
	
	DebugMetricsEvent:FireAllClients("PathfindingTime", pathfindingMs)
	
	self.PathIndex = 1

	return self.CurrentPath
end

function HeroAI:FollowPathStep()
	if not self.CurrentPath then return end

	local current = self.CurrentPath[self.PathIndex]
	local next = self.CurrentPath[self.PathIndex + 1]

	if not current then return end

	local target = next or current
	self.Humanoid:MoveTo(target)

	if (self.Root.Position - current).Magnitude < 4 then
		self.PathIndex += 1
	end
end

function HeroAI:Chase()
	if not self.Target or not self.Target.Character then 
		self.Target = nil
		return 
	end

	local root = self.Target.Character:FindFirstChild("HumanoidRootPart")
	if not root then 
		self.Target = nil
		return 
	end

	local dist = (self.Root.Position - root.Position).Magnitude

	if dist < 5 then
		local hum = self.Target.Character:FindFirstChild("Humanoid")
		if hum then
			JumpscareEvent:FireClient(self.Target)
			hum.Health = 0
		end
		return
	end

	local path = self:GetPath(root.Position)

	if path then
		self.CurrentPath = path
	else
		self:MoveTo(root.Position)
	end
end

function HeroAI:Hunt()
	if not self.HuntTarget or not self.HuntTarget.Character then 
		self.State = "Patrol"
		self.HuntTarget = nil
		self.Target = nil
		return 
	end

	local root = self.HuntTarget.Character:FindFirstChild("HumanoidRootPart")
	if not root then 
		self.State = "Patrol"
		self.HuntTarget = nil
		self.Target = nil
		return 
	end

	local dist = (self.Root.Position - root.Position).Magnitude

	if dist < 5 then
		local hum = self.HuntTarget.Character:FindFirstChild("Humanoid")
		if hum then
			JumpscareEvent:FireClient(self.HuntTarget)
			hum.Health = 0
		end
		return
	end

	self.CurrentPath = nil
	self.PathIndex = 1

	self.Humanoid:MoveTo(root.Position)
end

function HeroAI:Search()
	local job = Director:PopJob()

	local targetPos
	if job then
		targetPos = job.Position
	else
		targetPos = self.Root.Position + Vector3.new(
			math.random(-20, 20),
			0,
			math.random(-20, 20)
		)
	end

	local path = self:GetPath(targetPos)

	if path then
		self.CurrentPath = path
	else
		self:MoveTo(targetPos)
	end
end

function HeroAI:RunStep()
	self:Think()

	if self.State == "Hunt" then
		self:Hunt()
	elseif self.Target then
		self:Chase()
	else
		self:Search()
	end

	self:FollowPathStep()
end

function HeroAI:Run()
	task.spawn(function()
		while self.Active do
			self:RunStep()
			task.wait(0.1)
		end
	end)
end

return HeroAI
