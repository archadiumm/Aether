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

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")

const defaultOptions = {
	RemoteSpam = true :: boolean?, -- // Detects remote spamming 
	InfiniteJump = true :: boolean?, -- // Detects infinite jumping
	Modifications = true :: boolean?, -- // Detects humanoid modifications like speedhack, jumphack, etc.
	Tampering = true :: boolean?, -- // Detects if the client-sided scripts get deleted/disabled.
	Fling = false :: boolean? -- // Detects exploits that fling other players.
}

export type cheatOptions = typeof(defaultOptions)

function Main:init(cheats: cheatOptions?)
	const cheats = cheats or defaultOptions
	
	for key: string, _ in defaultOptions do
		if cheats[key] == nil then
			cheats[key] = defaultOptions[key]
		end
		
		ReplicatedStorage:SetAttribute(key, cheats[key])
	end
	
	Remotes.Name = "Aether"
	Remotes.Parent = ReplicatedStorage
	
	if cheats.Tampering then
		ClientAdd:init()
	end

	if cheats.RemoteSpam then
		RemoteSpam:init()
	end
	
	Players.PlayerAdded:Connect(function(player: Player)
		ClientAdd.add(player)
		
		if cheats.RemoteSpam then
			RemoteSpam.watch(player)
		end
	end)

	Resync.OnServerEvent:Connect(function(player: Player)
		const character = player.Character or player.CharacterAdded:Wait()
		const humanoid = character:WaitForChild("Humanoid") :: Humanoid

		const data = buffer.create(6)
		buffer.writeu16(data, 0, humanoid.WalkSpeed)
		buffer.writeu16(data, 2, humanoid.JumpPower)
		buffer.writeu16(data, 4, humanoid.JumpHeight)

		Resync:FireClient(player, data)
	end)
end

return Main