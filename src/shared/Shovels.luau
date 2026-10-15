--!strict
-- Shovel definitions. Knockback and DigSpeed are multipliers (x1 = wood shovel).
-- Dig time for a chest = BASE_DIG_SECONDS / DigSpeed (wood shovel = 4s).

export type Shovel = { Name: string, Price: number, Knockback: number, DigSpeed: number }

local Shovels = {}

Shovels.BASE_DIG_SECONDS = 4

Shovels.List = {
	{ Name = "Wood Shovel", Price = 0, Knockback = 1, DigSpeed = 1 },
	{ Name = "Stone Shovel", Price = 250, Knockback = 1.5, DigSpeed = 1.5 },
	{ Name = "Iron Shovel", Price = 1000, Knockback = 2, DigSpeed = 2 },
	{ Name = "Gold Shovel", Price = 4000, Knockback = 3, DigSpeed = 3 },
	{ Name = "Diamond Shovel", Price = 15000, Knockback = 4, DigSpeed = 4 },
} :: { Shovel }

function Shovels.get(name: string): Shovel?
	for _, s in Shovels.List do
		if s.Name == name then return s end
	end
	return nil
end

local function fmt(n: number): string
	return (string.format("%.2f", n):gsub("%.?0+$", ""))
end

-- Shop label: shows Dig Speed (knockback still applies, just isn't listed).
function Shovels.speedText(s: Shovel): string
	return "x" .. fmt(s.DigSpeed) .. " Dig Speed"
end

function Shovels.digSeconds(s: Shovel?): number
	local speed = if s then s.DigSpeed else 1
	return Shovels.BASE_DIG_SECONDS / speed
end

return Shovels
