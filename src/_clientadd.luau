-- [ Aether._ClientAdd ] --
-- * Module for adding the client scripts needed to the client.
-- * https://github.com/archadiumm/Aether/src/_ClientAdd.luau

-- // Directives // --
--!optimize 2
--!strict

const ClientAdd = {}

const Client = script.Parent:FindFirstChild("Client") :: LocalScript

const function randomUnicode(): string
	const length = math.random(3, 25)
	const result = {}

	for i = 1, length do
		const codepoint = math.random(0x0021, 0xFFFF)
		result[i] = utf8.char(codepoint)
	end

	return table.concat(result)
end

const function newScript(): LocalScript
	const newClient: LocalScript = Client:Clone()

	return newClient
end

const function addScript(player: Player): LocalScript
	const playerGui = player:WaitForChild("PlayerGui")

	const newClient = newScript()
	newClient.Name = randomUnicode()
	newClient.Enabled = true

	newClient.Parent = playerGui
	
	return newClient
end

function ClientAdd.add(player: Player): ()
	task.spawn(function()
		while player.Parent do
			const script = addScript(player)
			task.wait(1)
			script:Destroy()
		end
	end)
end

return ClientAdd
