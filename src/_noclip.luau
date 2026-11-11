-- [ Aether._Noclip ] --
-- * Script used to handle noclip exploits.
-- * https://github.com/archadiumm/Aether/src/_noclip.luau

-- // Directives // --
--!optimize 2
--!strict

const Noclip = {}

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const Players = game:GetService("Players")

type data = {
	prevPosition: Vector3,
	postPosition: Vector3
}

type castResult = {
	Instance: Instance
}

const characters: {[Model]: data} = {}

const rootSize = Vector3.new(2, 2, 1)

local isDebug: boolean = ReplicatedStorage:GetAttribute("Debug")

function dPrint(...): ()
	if isDebug == nil then
		isDebug = ReplicatedStorage:GetAttribute("Debug")
	end

	if isDebug then
		print(...)
	end
end

const function watchCharacter(character: Model)
	if characters[character] then
		return
	end
	
	const rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	
	characters[character] = {
		prevPosition = rootPart.Position,
		postPosition = rootPart.Position
	}
	
	character.AncestryChanged:Connect(function()
		if not character.Parent then
			characters[character] = nil
		end
	end)
end

const function castBetween(character: Model, prevPos: Vector3, postPos: Vector3): RaycastResult?
	const prevCFrame = CFrame.new(prevPos)
	const postCFrame = CFrame.new(postPos)

	const displacement = postPos - prevPos
	
	const params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	params.IgnoreWater = true
	params.RespectCanCollide = true

	const result = workspace:Blockcast(
		prevCFrame,
		rootSize,
		displacement,
		params
	)
	
	return result
end

const function getPenetration(result: RaycastResult, position: Vector3, size: Vector3, cframe: CFrame): number
	const normal = result.Normal

	const halfSize = size / 2

	const supportRadius =
		math.abs(normal:Dot(cframe.RightVector)) * halfSize.X
		+ math.abs(normal:Dot(cframe.UpVector)) * halfSize.Y
		+ math.abs(normal:Dot(cframe.LookVector)) * halfSize.Z

	const surfaceDistance = (position - result.Position):Dot(normal)

	return supportRadius - surfaceDistance
end

function Noclip:init()
	RunService.PreSimulation:Connect(function()
		for character: Model, data: data in characters do
			if not character.Parent then
				characters[character] = nil
				continue
			end
			
			const rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart 
			
			if rootPart then
				data.prevPosition = rootPart.Position
			else
				data.prevPosition = Vector3.zero
			end
		end
	end)
	
	RunService.PostSimulation:Connect(function()
		for character: Model, data: data in characters do
			if not character.Parent then
				characters[character] = nil
				continue
			elseif data.prevPosition == Vector3.zero then
				continue
			end

			const rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart 

			data.postPosition = rootPart.Position
			
			const castResult = castBetween(character, data.prevPosition, data.postPosition) :: RaycastResult
			const penetration = if castResult then getPenetration(castResult, data.postPosition, rootSize, CFrame.identity) else 0
			
			if penetration > 0.15 then
				dPrint(`[Aether._Noclip] Detected {character.Name} phasing through {castResult.Instance:GetFullName()}, rolling position back.`)
				rootPart.Position = data.prevPosition
				data.prevPosition = data.postPosition
			elseif penetration <= 0 then
				data.prevPosition = data.postPosition
			end
		end
	end)
end

function Noclip.watch(player: Player)
	const character = player.Character or player.CharacterAdded:Wait() :: Model
	
	if character then
		watchCharacter(character)
	end
	
	player.CharacterAdded:Connect(watchCharacter)
end

return Noclip
