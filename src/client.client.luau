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

const function isGrounded(character: Model): boolean
	const rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
	
	const origin = rootPart.Position
	const direction = Vector3.new(0, -5, 0)
	
	const params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	params.RespectCanCollide = true

	const result = workspace:Raycast(origin, direction, params)

	return result ~= nil
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
	humanoid.StateChanged:Connect(function(old: Enum.HumanoidStateType, new: Enum.HumanoidStateType)
		if new ~= Enum.HumanoidStateType.Jumping or table.find(excludedStates, old) then
			return
		end
		
		const rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
		
		if not isGrounded(character) and not falling then
			local velocity = rootPart.AssemblyLinearVelocity

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
			until isGrounded(character)
			
			task.defer(function()
				Resync:FireServer()
				falling = false
			end)
		end
	end)
end

const function antiFling(character: Model): ()
	if not fling then
		return
	end
	
	const rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	
	const voidCFrame = CFrame.new(0, 0, 0)
	
	task.spawn(function()
		local flinging: boolean = false
		local lastPosition: CFrame
		
		while character.Parent do
			task.wait()
			
			flinging = false
			
			for _, part: BasePart in character:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end
				
				if part.AssemblyLinearVelocity.Magnitude >= 1e4 then
					part.AssemblyLinearVelocity = Vector3.zero
					flinging = true
				end
				
				if part.AssemblyAngularVelocity.Magnitude >= 1e4 then
					part.AssemblyAngularVelocity = Vector3.zero
					flinging = true
				end
			end
			
			if flinging then
				if lastPosition == voidCFrame then
					lastPosition = rootPart.CFrame
				end
				
				rootPart.CFrame = lastPosition
				rootPart.Anchored = true
			else
				for _, part: BasePart in character:GetDescendants() do
					if not part:IsA("BasePart") then
						continue
					end
					
					if part.AssemblyLinearVelocity.Magnitude >= 1e4 then
						part.AssemblyLinearVelocity = Vector3.zero
						flinging = true
					end

					if part.AssemblyAngularVelocity.Magnitude >= 1e4 then
						part.AssemblyAngularVelocity = Vector3.zero
						flinging = true
					end
				end
				
				rootPart.Anchored = false
				lastPosition = voidCFrame
			end
		end
	end)
end

const function init(player: Player)
	character = player.Character :: Model
	humanoid = character:WaitForChild("Humanoid") :: Humanoid
	
	connectHumanoid()
	antiFling(character)
end

player.CharacterAdded:Connect(function()
	init(player)
end)

init(player)

Resync.OnClientEvent:Connect(function(data: buffer)
	syncing = true
	
	humanoid.WalkSpeed = buffer.readu16(data, 0)
	humanoid.JumpPower = buffer.readu16(data, 2)
	humanoid.JumpHeight = buffer.readu16(data, 4)
	
	task.defer(function()
		syncing = false
	end)
end)

const fake = ReplicatedStorage:WaitForChild("TopbarPlus") :: Script

if not fake then
	return
end

fake.AncestryChanged:Connect(function()
	if not fake.Parent then
		player:Kick(`[Aether] - Kicked for anticheat tampering.`)
	end
end)

fake:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not fake.Enabled then
		player:Kick(`[Aether] - Kicked for anticheat tampering.`)
	end
end)