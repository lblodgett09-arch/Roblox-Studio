--!strict
-- Gives players shovel Tools and applies each shovel's Knockback multiplier on hit.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shovels = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Shovels"))

local BASE_KNOCKBACK = 40 -- studs/sec impulse at x1
local HIT_COOLDOWN = 0.6

local function makeTool(def: Shovels.Shovel): Tool
	local tool = Instance.new("Tool")
	tool.Name = def.Name
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool.GripPos = Vector3.new(0, -1.5, 0)
	tool:SetAttribute("Knockback", def.Knockback)
	tool:SetAttribute("DigSpeed", def.DigSpeed)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.4, 4, 0.4)
	handle.Color = Color3.fromRGB(120, 85, 50)
	handle.Material = Enum.Material.Wood
	handle.Parent = tool
	local blade = Instance.new("Part")
	blade.Name = "Blade"
	blade.Size = Vector3.new(1.4, 1.2, 0.2)
	blade.Color = Color3.fromRGB(170, 170, 175)
	blade.Material = Enum.Material.Metal
	blade.CanCollide = false
	blade.Massless = true
	blade.CFrame = handle.CFrame * CFrame.new(0, -2.4, 0)
	local weld = Instance.new("WeldConstraint")
	weld.Part0, weld.Part1 = handle, blade
	weld.Parent = blade
	blade.Parent = tool

	-- Knockback: swinging (activating) the shovel and touching a player launches them.
	local swinging, last = false, {} :: { [Model]: number }
	tool.Activated:Connect(function()
		swinging = true
		task.delay(0.5, function() swinging = false end)
	end)
	handle.Touched:Connect(function(hit)
		if not swinging then return end
		local victim = hit.Parent
		local owner = tool.Parent
		if not victim or victim == owner or not victim:IsA("Model") then return end
		local hum = victim:FindFirstChildOfClass("Humanoid")
		local vroot = victim:FindFirstChild("HumanoidRootPart") :: BasePart?
		local oroot = owner and owner:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not hum or not vroot or not oroot then return end
		if os.clock() - (last[victim] or 0) < HIT_COOLDOWN then return end
		last[victim] = os.clock()
		local dir = (vroot.Position - oroot.Position) * Vector3.new(1, 0, 1)
		if dir.Magnitude < 0.01 then return end
		vroot:ApplyImpulse((dir.Unit + Vector3.new(0, 0.4, 0)) * BASE_KNOCKBACK * def.Knockback * vroot.AssemblyMass)
	end)
	return tool
end

local function give(player: Player, name: string)
	local def = Shovels.get(name)
	if not def then return end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack and not backpack:FindFirstChild(name) then makeTool(def).Parent = backpack end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		player:WaitForChild("Backpack")
		give(player, "Wood Shovel")
	end)
end)

-- Other scripts (shop purchases) can call this via a BindableEvent.
local grant = Instance.new("BindableEvent")
grant.Name = "GrantShovel"
grant.Parent = script
grant.Event:Connect(give)
