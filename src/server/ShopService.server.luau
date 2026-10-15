--!strict
-- Treasure Shop: a stall with an "Open" prompt, plus server-validated shovel purchases.
-- Spends from player.leaderstats.Coins (created at 0 if no other script made it).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shovels = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Shovels"))
local grant = script.Parent:WaitForChild("ShovelService"):WaitForChild("GrantShovel") :: BindableEvent

local open = Instance.new("RemoteEvent")
open.Name = "OpenTreasureShop"
open.Parent = ReplicatedStorage
local buy = Instance.new("RemoteFunction")
buy.Name = "BuyShovel"
buy.Parent = ReplicatedStorage

Players.PlayerAdded:Connect(function(player)
	local stats = player:FindFirstChild("leaderstats") or Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	if not stats:FindFirstChild("Coins") then
		local c = Instance.new("IntValue")
		c.Name = "Coins"
		c.Parent = stats
	end
end)

local owned: { [Player]: { [string]: boolean } } = {}
Players.PlayerRemoving:Connect(function(p) owned[p] = nil end)

buy.OnServerInvoke = function(player: Player, name: unknown): (boolean, string)
	if typeof(name) ~= "string" then return false, "Invalid" end
	local def = Shovels.get(name)
	if not def then return false, "Unknown shovel" end
	owned[player] = owned[player] or {}
	if owned[player][name] then return false, "Already owned" end
	local coins = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Coins")
	if not coins or not coins:IsA("IntValue") or coins.Value < def.Price then return false, "Not enough coins" end
	coins.Value -= def.Price
	owned[player][name] = true
	grant:Fire(player, name)
	return true, "Purchased"
end

local stall = Instance.new("Part")
stall.Name = "TreasureShopStall"
stall.Size = Vector3.new(6, 4, 3)
stall.Position = Vector3.new(0, 2, -20)
stall.Anchored = true
stall.Color = Color3.fromRGB(150, 100, 50)
stall.Material = Enum.Material.Wood
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Open"
prompt.ObjectText = "Treasure Shop"
prompt.Parent = stall
prompt.Triggered:Connect(function(player) open:FireClient(player) end)
stall.Parent = workspace
