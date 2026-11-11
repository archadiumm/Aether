-- [ Aether._ClientAdd ] --
-- * Module for adding the client scripts needed to the client.
-- * https://github.com/archadiumm/Aether/src/_clientadd.luau

-- // Directives // --
--!optimize 2
--!strict

const ClientAdd = {}

const TextChatService = game:GetService("TextChatService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const SoundService = game:GetService("SoundService")
const Lighting = game:GetService("Lighting")

const Client = script.Parent:FindFirstChild("Client") :: Script

type location = {
	Parent: Instance,
	Name: string,
}

const locations: {location} = {
	{
		Parent = ReplicatedStorage,
		Name = "TopbarPlus",
	},
	{
		Parent = SoundService,
		Name = "SFXManager",
	},
	{
		Parent = Lighting,
		Name = "LightingScript",
	},
	{
		Parent = TextChatService,
		Name = "ChatScript",
	}
}

function ClientAdd:init(): ()
	const location: location = locations[math.random(1, #locations)]
	
	const real = location.Parent:FindFirstChild(location.Name)
	
	if real then
		Client.Name = "Init"
		Client.Parent = real
	else
		Client.Name = location.Name
		Client.Parent = location.Parent
	end
	
	Client.Enabled = true
end

return ClientAdd
