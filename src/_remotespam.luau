-- [ Aether._RemoteSpam ] --
-- * Module for detecting Remote Spamming.
-- * https://github.com/archadiumm/Aether/src/_remotespam.luau

-- // Directives // --
--!optimize 2
--!strict

const RemoteSpam = {}

const players = {}

const function onRemoteEvent(remote: (RemoteEvent | RemoteFunction), player: Player)
	const userId: number = player.UserId

	if not players[userId][remote.Name] then
		players[userId][remote.Name] = 0
	end

	players[userId][remote.Name] += 1

	const amount = players[userId][remote.Name]
	
	if amount >= 5 then
		if remote.Name == "Resync" and amount >= 10 then
			player:Kick(`[Aether] - Kicked for attempted humanoid modifications.`)
		else
			player:Kick(`[Aether] - Kicked for remote spam.\n* Fired {remote.Name} {amount} times per second.`)
		end
	end
end

function RemoteSpam:init()
	for _, remote: Instance in pairs(game:GetDescendants()) do
		if remote:IsA("RemoteEvent") then
			remote.OnServerEvent:Connect(function(player: Player)
				onRemoteEvent(remote, player)
			end)
		end
	end
end

function RemoteSpam:append(remote: RemoteFunction, player: Player)
	onRemoteEvent(remote, player)
end

function RemoteSpam.watch(player: Player)
	const userId: number = player.UserId
	players[userId] = {}
	
	const clearThread: thread = task.spawn(function()
		while true do
			task.wait(1)
			players[userId] = {}
		end
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