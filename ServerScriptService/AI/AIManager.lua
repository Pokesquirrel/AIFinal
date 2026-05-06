--Main manager for the AI, and if more were to be made
local HeroAI = require(script.Parent.NPCs.HeroAI)

local AIManager = {}
AIManager.Agents = {}
AIManager.HeroSpawned = false

function AIManager:Init()
	--Helps spawn HeroAI only after the player collects the first objective
end

function AIManager:SpawnHero()
	if self.HeroSpawned then return end
	
	local hero = game.ReplicatedStorage:FindFirstChild("Hero")
	if hero then
		hero.Parent = game.Workspace
		local ai = HeroAI.new(hero)
		table.insert(self.Agents, ai)
		ai:Run()
		self.HeroSpawned = true
		print("[AIManager] Hero has been spawned!")
	else
		warn("[AIManager] Hero model not found in ReplicatedStorage")
	end
end

function AIManager:RemoveHero()
	local hero = game.Workspace:FindFirstChild("Hero")
	if hero then
		for i, agent in ipairs(self.Agents) do
			if agent.Model == hero then
				agent.Active = false
				table.remove(self.Agents, i)
				break
			end
		end
		hero.Parent = nil
		self.HeroSpawned = false
		print("[AIManager] Hero has been removed!")
	end
end

return AIManager
