--!strict
-- Treasure shop shovel list: each entry shows "x(multiplier) Dig Speed".
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shovels = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Shovels"))

local gui = Instance.new("ScreenGui")
gui.Name = "TreasureShop"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.fromOffset(320, 360)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.CanvasSize = UDim2.new()
frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
frame.Parent = gui
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = frame

for _, s in Shovels.List do
	local row = Instance.new("TextButton")
	row.Name = s.Name
	row.Size = UDim2.new(1, -8, 0, 56)
	row.TextWrapped = true
	row.RichText = true
	row.Text = `<b>{s.Name}</b>\n{Shovels.speedText(s)} · {s.Price} coins`
	row.Parent = frame
	row.Activated:Connect(function()
		local ok, msg = ReplicatedStorage:WaitForChild("BuyShovel"):InvokeServer(s.Name)
		row.Text = `<b>{s.Name}</b>\n{ok and "Purchased!" or msg}`
		task.delay(1.5, function()
			row.Text = `<b>{s.Name}</b>\n{Shovels.speedText(s)} · {s.Price} coins`
		end)
	end)
end

ReplicatedStorage:WaitForChild("OpenTreasureShop").OnClientEvent:Connect(function()
	gui.Enabled = not gui.Enabled
end)
