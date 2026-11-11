-- [ Aether._RemoteSpam ] --
-- * Module for detecting Remote Spamming.
-- * https://github.com/archadiumm/Aether/src/_remotespam.luau

-- // Directives // --
--!optimize 2
--!strict

const RemoteSpam = {}

type playerData = {[string]: number}

const players: {[number]: playerData} = {}

local initialized: boolean = false

const function onRemoteEvent(remote: (RemoteEvent | RemoteFunction), player: Player)
	const userId = player.UserId

	const data: playerData = players[userId] or {}
	players[userId] = data

	const name = remote.Name
	const amount = (data[name] or 0) + 1

	data[name] = amount

	if amount < 5 then
		return
	end

	if name == "Resync" then
		if amount < 10 then
			return
		end
		
		player:Kick("[Aether] - Kicked for attempted humanoid modifications.")
	else
		player:Kick(`[Aether] - Kicked for remote spam.\n* Fired {name} {amount} times per second.`)
	end
end

function RemoteSpam:init()
	if initialized then
		warn("[Aether] - RemoteSpam module is already initialized.")
		return
	else
		initialized = true
	end
	
	for _, remote: Instance in pairs(game:GetDescendants()) do
		if remote:IsA("RemoteEvent") then
			remote.OnServerEvent:Connect(function(player: Player)
				onRemoteEvent(remote, player)
			end)
		end
	end
end

function RemoteSpam.watch(player: Player)
	const userId: number = player.UserId
	players[userId] = {}
	
	const clearThread: thread = task.spawn(function()
		while player.Parent do
			task.wait(1)
			players[userId] = {}
		end
		
		players[userId] = nil
	end)
	
	player.AncestryChanged:Connect(function(_, parent)
		if parent then
			return
		end
		
		task.cancel(clearThread)
		players[userId] = nil
	end)
end

return RemoteSpam
