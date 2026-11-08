-- [ Aether.Client ] --
-- * Localscript for detecting some client-sided exploits.
-- * https://github.com/archadiumm/Aether/src/Client.client.luau

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

const player: Player = Players.LocalPlayer :: Player
local character: Model = player.Character or player.CharacterAdded:Wait()
local humanoid: Humanoid = character:WaitForChild("Humanoid") :: Humanoid

const fallStates = {Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Physics, Enum.HumanoidStateType.Jumping}

local falling: boolean = false
local syncing: boolean = false

const function connectHumanoid(): ()
	humanoid.Changed:Connect(function(property: string)
		if (not syncing) and (property == "WalkSpeed" or property == "JumpPower" or property == "JumpHeight") then
			Resync:FireServer()
		end
	end)
	
	humanoid.StateChanged:Connect(function(old: Enum.HumanoidStateType, new: Enum.HumanoidStateType)
		if (not falling) and (new == Enum.HumanoidStateType.Jumping and table.find(fallStates, old)) then
			falling = true
			
			repeat
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

				syncing = true

				humanoid.Jump = false
				humanoid.JumpPower = 0
				humanoid.JumpHeight = 0

				task.wait()
			until humanoid:GetState() == Enum.HumanoidStateType.Landed
			
			task.defer(function()
				Resync:FireServer()
				
				falling = false
				
				repeat
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
					task.wait()
				until humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
			end)
		end
	end)
end

const function antiFling(part: BasePart): ()
	
end

player.CharacterAdded:Connect(function()
	character = player.Character :: Model
	humanoid = character:WaitForChild("Humanoid") :: Humanoid
	
	connectHumanoid()
	
	for _, part: BasePart in character:GetDescendants() do
		if part:IsA("BasePart") then
			antiFling(part)
		end
	end
end)

connectHumanoid()

Resync.OnClientEvent:Connect(function(data: buffer)
	syncing = true
	
	humanoid.WalkSpeed = buffer.readu16(data, 0)
	humanoid.JumpPower = buffer.readu16(data, 2)
	humanoid.JumpHeight = buffer.readu16(data, 4)
	
	task.defer(function()
		syncing = false
	end)
end)

