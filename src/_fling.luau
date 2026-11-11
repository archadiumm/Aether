-- [ Aether._Fling ] --
-- * Module for detecting suspicious player velocity.
-- * https://github.com/archadiumm/Aether/src/_fling.luau

-- // Directives // --
--!optimize 2
--!strict

const Fling = {}

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const PhysicsService = game:GetService("PhysicsService")
const RunService = game:GetService("RunService")
const Players = game:GetService("Players")

const characters: {[Model]: RBXScriptConnection} = {}
const freezes: {[Model]: freezeData} = {}

const maxVelocity = 1e4
const freezeTime = 1

type partData = {
	collisionGroup: string,
	anchored: boolean,
}

type freezeData = {
	parts: {[BasePart]: partData},
	connection: RBXScriptConnection?,
}

local isDebug: boolean = ReplicatedStorage:GetAttribute("Debug")

function dPrint(...): ()
	if isDebug == nil then
		isDebug = ReplicatedStorage:GetAttribute("Debug")
	end
	
	if isDebug then
		print(...)
	end
end

const function reloadGroup(): ()
	if not PhysicsService:IsCollisionGroupRegistered("Aether") then
		PhysicsService:RegisterCollisionGroup("Aether")
	end
	
	const groups = PhysicsService:GetRegisteredCollisionGroups()
	
	for _, group in groups do
		PhysicsService:CollisionGroupSetCollidable(group.name, "Aether", false)
	end
end

const function registerPart(data: freezeData, part: BasePart)
	if data.parts[part] then
		return
	end

	data.parts[part] = {
		collisionGroup = part.CollisionGroup,
		anchored = part.Anchored,
	}
	
	reloadGroup()
	
	part.CollisionGroup = "Aether"
	part.Anchored = true

	part.AssemblyLinearVelocity = Vector3.zero
	part.AssemblyAngularVelocity = Vector3.zero
end

const function unfreezeCharacter(character: Model)
	const data = freezes[character]

	if not data then
		return
	end

	freezes[character] = nil

	if data.connection then
		data.connection:Disconnect()
	end

	for part, previous in data.parts do
		if not part.Parent then
			continue
		end
		
		part.AssemblyLinearVelocity = Vector3.zero
		part.AssemblyAngularVelocity = Vector3.zero

		part.CollisionGroup = previous.collisionGroup
		part.Anchored = previous.anchored
	end
end

const function freezeCharacter(character: Model)
	if freezes[character] then
		return
	end

	const duration = math.max(
		0,
		freezeTime + math.random(-25, 150) / 100
	)

	const data: freezeData = {
		parts = {},
		connection = nil,
	}
	
	dPrint(`[Aether._Fling] - Freezing {character.Name}'s character (Velocity above {maxVelocity})`)
	freezes[character] = data

	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			registerPart(data, descendant)
		end
	end

	data.connection = character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			registerPart(data, descendant)
		end
	end)

	task.delay(duration, function()
		if freezes[character] == data then
			unfreezeCharacter(character)
		end
	end)
end

const function watchCharacter(character: Model)
	if characters[character] then
		return
	end

	const rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

	characters[character] = RunService.PostSimulation:Connect(function()
		if not rootPart.Parent then
			characters[character]:Disconnect()
			characters[character] = nil
			return
		end

		if freezes[character] then
			return
		end

		if rootPart.AssemblyLinearVelocity.Magnitude > maxVelocity
			or rootPart.AssemblyAngularVelocity.Magnitude > maxVelocity then

			freezeCharacter(character)
		end
	end)
end

const function enforceFreeze()
	for character, data in freezes do
		for part in data.parts do
			if not part.Parent then
				continue
			end

			part.Anchored = true
			part.AssemblyLinearVelocity = Vector3.zero
			part.AssemblyAngularVelocity = Vector3.zero
		end
	end
end


function Fling:init(): ()
	RunService.PostSimulation:Connect(enforceFreeze)
end

function Fling.watch(player: Player): ()
	const character = player.Character or player.CharacterAdded:Wait() :: Model
	
	if character then
		watchCharacter(character)
	end

	player.CharacterAdded:Connect(watchCharacter)
end

return Fling
