--!strict
-- Buried chests: no pedestals. Each chest sits underground beneath a dirt pile
-- marked with a cartoon X. Pile and X scale with the chest's size.
-- Usage: tag any chest Model (with a PrimaryPart) "Chest" and place it on the
-- ground where it should be buried. Players dig it up with the "Dig" prompt.

local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local CHEST_TAG = "Chest"
local DIRT_COLOR = Color3.fromRGB(105, 70, 40)
local X_COLOR = Color3.fromRGB(220, 30, 30)

local function makePart(name: string, size: Vector3, color: Color3, material: Enum.Material): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.CanCollide = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	return p
end

local function bury(chest: Model)
	if chest:GetAttribute("Buried") ~= nil then return end
	local root = chest.PrimaryPart
	if not root then
		warn("Chest has no PrimaryPart:", chest:GetFullName())
		return
	end

	local _, size = chest:GetBoundingBox()
	local footprint = math.max(size.X, size.Z)
	local groundY = chest:GetPivot().Position.Y - size.Y / 2 -- chest bottom = ground
	local origin = chest:GetPivot()

	-- Sink chest fully below the surface (leave 0.5 stud of cover).
	local buriedCF = origin - Vector3.new(0, size.Y + 0.5, 0)
	chest:PivotTo(buriedCF)
	chest:SetAttribute("Buried", true)

	local ground = Vector3.new(origin.Position.X, groundY, origin.Position.Z)

	-- Dirt pile: squashed sphere sized to the chest.
	local moundW = footprint * 1.4
	local mound = makePart("DirtPile", Vector3.new(moundW, math.max(1, size.Y * 0.6), moundW), DIRT_COLOR, Enum.Material.Ground)
	mound.Shape = Enum.PartType.Ball
	mound.Size = Vector3.new(moundW, math.max(1, size.Y * 0.6), moundW)
	mound.CanCollide = true
	mound.CFrame = CFrame.new(ground)
	mound.Parent = chest.Parent

	-- Cartoon X: two chunky crossed bars lying on top of the pile.
	local barLen = moundW * 0.7
	local barThick = math.max(0.3, footprint * 0.12)
	local topY = ground.Y + mound.Size.Y / 2 + barThick / 2 - 0.05
	local xModel = Instance.new("Model")
	xModel.Name = "BuriedX"
	for i, angle in { 45, -45 } do
		local bar = makePart("Bar" .. i, Vector3.new(barLen, barThick, barThick * 1.6), X_COLOR, Enum.Material.SmoothPlastic)
		bar.CFrame = CFrame.new(ground.X, topY, ground.Z) * CFrame.Angles(0, math.rad(angle), 0)
		bar.Parent = xModel
	end
	xModel.Parent = chest.Parent

	-- Dig prompt on the pile.
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Dig"
	prompt.ObjectText = "Buried Chest"
	prompt.HoldDuration = 1.5
	prompt.MaxActivationDistance = 10 + footprint
	prompt.Parent = mound

	prompt.Triggered:Connect(function(player)
		prompt:Destroy()
		mound:Destroy()
		xModel:Destroy()
		TweenService:Create(root, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { CFrame = origin }):Play()
		chest:SetAttribute("Buried", false)
		chest:SetAttribute("DugUpBy", player.UserId)
	end)
end

CollectionService:GetInstanceAddedSignal(CHEST_TAG):Connect(function(inst)
	if inst:IsA("Model") then bury(inst) end
end)
for _, inst in CollectionService:GetTagged(CHEST_TAG) do
	if inst:IsA("Model") then bury(inst) end
end
