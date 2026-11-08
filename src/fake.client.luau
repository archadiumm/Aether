-- [ Aether.Fake ] --
-- * A disguised script that can detect client changes.
-- * https://github.com/archadiumm/Aether/src/fake.client.luau

-- // Directives // --
--!optimize 2
--!strict

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")

if not ReplicatedStorage:GetAttribute("Tampering") then
	return
end

const player = Players.LocalPlayer :: Player

const function randomUnicode(): string
	const length = math.random(3, 25)
	const result = {}

	for i = 1, length do
		const codepoint = math.random(0x0021, 0xFFFF)
		result[i] = utf8.char(codepoint)
	end

	return table.concat(result)
end

const function killSwitch()
	player:Kick(`[Aether] - Kicked for anticheat tampering.`)
end

const playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
const aether = playerGui:WaitForChild("Client") :: LocalScript

if not aether or not playerGui then
	killSwitch()
	return
end

aether:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not aether.Enabled then
		killSwitch()
	end
end)

aether.AncestryChanged:Connect(function()
	if not aether.Parent then
		killSwitch()
	end
end)

while aether.Parent do
	aether.Name = randomUnicode()
	task.wait(1)
end