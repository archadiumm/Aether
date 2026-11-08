-- [ Aether._ClientAdd ] --
-- * Module for adding the client scripts needed to the client.
-- * https://github.com/archadiumm/Aether/src/_clientadd.luau

-- // Directives // --
--!optimize 2
--!strict

const ClientAdd = {}

const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Client = script.Parent:FindFirstChild("Client") :: LocalScript
const Fake = script.Parent:FindFirstChild("Fake") :: Script

const function newScript(): LocalScript
	const newClient: LocalScript = Client:Clone()

	return newClient
end

const function addScript(player: Player): LocalScript
	const playerGui = player:WaitForChild("PlayerGui")

	const newClient = newScript()
	newClient.Name = "Client"
	newClient.Enabled = true

	newClient.Parent = playerGui
	
	return newClient
end

function ClientAdd:init(): ()
	Fake.Name = "TopbarPlus"
	Fake.Parent = ReplicatedStorage
	
	Fake.Enabled = true
end

function ClientAdd.add(player: Player): ()
	const script = addScript(player)
end

return ClientAdd