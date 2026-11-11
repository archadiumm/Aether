-- [ Aether ] --
-- * Main script for Aether.
-- * https://github.com/archadiumm/Aether/src/main.luau

-- // Directives // --
--!optimize 2
--!strict

const Main = {}

const Aether = script.Parent
const Remotes = Aether.Remotes

const Resync = Remotes:FindFirstChild("Resync")

const RemoteSpam = require("./_RemoteSpam")
const ClientAdd = require("./_ClientAdd")
const Noclip = require("./_Noclip")
const Fling = require("./_Fling")

const ServerScriptService = game:GetService("ServerScriptService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")

const defaultOptions = {
	Fling = true :: boolean?, -- // Detects exploits that fling other players.
	Noclip = true :: boolean?, -- // Detects exploits that noclip through objects.
	RemoteSpam = true :: boolean?, -- // Detects remote spamming.
	InfiniteJump = true :: boolean?, -- // Detects infinite jumping.
	Modifications = true :: boolean?, -- // Detects humanoid modifications like speedhack, jumphack, etc.
	
	Debug = false :: boolean? -- // Enables debug info. Used to test if Aether is falsely blocking parts of your game.
}

export type cheatOptions = typeof(defaultOptions)

local initialized: boolean = false

function Main:init(cheats: cheatOptions?)
	const packageParent = script.Parent.Parent
	
	if packageParent ~= ServerScriptService then
		warn(`[Aether] - Aether's package is intended to be parented to ServerScriptService, not {packageParent.Name}.`)
	elseif initialized then
		warn("[Aether] - Aether is already initialized.")
		return
	end
	
	initialized = true
	
	const cheats = cheats or defaultOptions
	
	for key: string, _ in defaultOptions do
		if cheats[key] == nil then
			cheats[key] = defaultOptions[key]
		end
		
		ReplicatedStorage:SetAttribute(key, cheats[key])
	end
	
	Remotes.Name = "Aether"
	Remotes.Parent = ReplicatedStorage
	
	if cheats.Modifications then
		ClientAdd:init()
	end

	if cheats.RemoteSpam then
		RemoteSpam:init()
	end
	
	if cheats.Fling then
		Fling:init()
	end
	
	if cheats.Noclip then
		Noclip:init()
	end
	
	Players.PlayerAdded:Connect(function(player: Player)
		if cheats.RemoteSpam then
			RemoteSpam.watch(player)
		end
		
		if cheats.Fling then
			Fling.watch(player)
		end
		
		if cheats.Noclip then
			Noclip.watch(player)
		end
	end)

	Resync.OnServerEvent:Connect(function(player: Player)
		const character = player.Character or player.CharacterAdded:Wait()
		const humanoid = character:WaitForChild("Humanoid") :: Humanoid
		
		const humanoidData = table.freeze({
			WalkSpeed = humanoid.WalkSpeed,
			JumpPower = humanoid.JumpPower,
			JumpHeight = humanoid.JumpHeight
		})
		
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
		
		humanoid.WalkSpeed = humanoidData.WalkSpeed
		humanoid.JumpPower = humanoidData.JumpPower
		humanoid.JumpHeight = humanoidData.JumpHeight
	end)
end

return Main