-- [ Aether.Client ] --
-- * Localscript for detecting some client-sided exploits.
-- * https://github.com/archadiumm/Aether/src/client.client.luau

-- // Directives // --
--!optimize 2
--!strict

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")

const Aether = ReplicatedStorage:WaitForChild("Aether") :: Folder
const Resync = Aether:FindFirstChild("Resync") :: RemoteEvent

repeat 
	task.wait() 
until game:IsLoaded() and Players.LocalPlayer

const modifications = ReplicatedStorage:GetAttribute("Modifications") :: boolean
const infiniteJump = ReplicatedStorage:GetAttribute("InfiniteJump") :: boolean
const fling = ReplicatedStorage:GetAttribute("Fling") :: boolean

const player: Player = Players.LocalPlayer :: Player
local character: Model = player.Character or player.CharacterAdded:Wait()
local humanoid: Humanoid = character:WaitForChild("Humanoid") :: Humanoid

const excludedStates: {Enum.HumanoidStateType} = {Enum.HumanoidStateType.Swimming, Enum.HumanoidStateType.Climbing}

local falling: boolean = false
local syncing: boolean = false

local fallStart: number = 0
const coyote: number = 0.125

const radius: number = 1.5
const distance: number = 5
const offsets: {Vector3} = {
	Vector3.zero,
	Vector3.new(radius, 0, 0),
	Vector3.new(-radius, 0, 0),
	Vector3.new(0, 0, radius),
	Vector3.new(0, 0, -radius),
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

const function isGrounded(): boolean
	const rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?

	if not rootPart then
		return false
	end

	const params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	params.RespectCanCollide = true

	for _, offset in offsets do
		const origin = rootPart.Position + offset
		const result = workspace:Raycast(
			origin,
			Vector3.new(0, -distance, 0),
			params
		)

		if result then
			return true
		end
	end
	
	const fallTime = os.clock() - fallStart
	
	if fallTime < coyote then
		return true
	end

	return false
end

const function connectHumanoid(): ()
	-- // Modifications
	humanoid.Changed:Connect(function(property: string)
		if not modifications then 
			return 
		end

		if (not syncing) and (property == "WalkSpeed" or property == "JumpPower" or property == "JumpHeight") then
			Resync:FireServer()
		end
	end)

	-- // Infinite Jump
	humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
		if humanoid.FloorMaterial == Enum.Material.Air then
			fallStart = os.clock()
		end
	end)
	
	humanoid.StateChanged:Connect(function(old: Enum.HumanoidStateType, new: Enum.HumanoidStateType)
		if new ~= Enum.HumanoidStateType.Jumping or table.find(excludedStates, old) then
			return
		end

		const rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart

		if not isGrounded() and not falling then
			local velocity = rootPart.AssemblyLinearVelocity
			
			dPrint("[Aether._Client] - Jump mid-air detected. Canceling jump.")

			repeat
				velocity = rootPart.AssemblyLinearVelocity

				if velocity.Y > 0 then
					rootPart.AssemblyLinearVelocity = Vector3.new(
						velocity.X,
						math.min(velocity.Y, -5),
						velocity.Z
					)

					humanoid.JumpPower = 0
					humanoid.JumpHeight = 0
					syncing = true
					falling = true
				end

				task.wait()
			until isGrounded()

			task.defer(function()
				Resync:FireServer()
				falling = false
			end)
		end
	end)
end

const function velocityFix()
	for _, part: BasePart in character:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end
		
		part:GetPropertyChangedSignal("CollisionGroup"):Connect(function()
			if part.CollisionGroup == "Aether" then
				repeat
					part.AssemblyLinearVelocity = Vector3.zero
					part.AssemblyAngularVelocity = Vector3.zero
					
					part.Anchored = true
					
					task.wait()
				until part.CollisionGroup ~= "Aether"
			end
		end)
	end
end

const function init(player: Player)
	character = player.Character :: Model
	humanoid = character:WaitForChild("Humanoid") :: Humanoid

	connectHumanoid()
	velocityFix()
end

player.CharacterAdded:Connect(function()
	init(player)
end)

init(player)

Resync.OnClientEvent:Connect(function(data: buffer)
	syncing = true
	
	if humanoid.WalkSpeed ~= buffer.readu16(data, 0) then
		dPrint(`[Aether._Client] - Resyncing WalkSpeed (Client: {humanoid.WalkSpeed} | Server: {buffer.readu16(data, 0)})`)
	elseif humanoid.JumpPower ~= buffer.readu16(data, 2) then
		dPrint(`[Aether._Client] - Resyncing JumpPower (Client: {humanoid.JumpPower} | Server: {buffer.readu16(data, 2)})`)
	elseif humanoid.JumpHeight ~= buffer.readu16(data, 4) then
		dPrint(`[Aether._Client] - Resyncing JumpHeight (Client: {humanoid.JumpHeight} | Server: {buffer.readu16(data, 4)})`)
	end

	humanoid.WalkSpeed = buffer.readu16(data, 0)
	humanoid.JumpPower = buffer.readu16(data, 2)
	humanoid.JumpHeight = buffer.readu16(data, 4)

	task.defer(function()
		syncing = false
	end)
end)