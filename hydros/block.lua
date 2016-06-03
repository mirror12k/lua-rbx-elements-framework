
local import
if script ~= nil then
	import = function (name, arg)
		local target = script.Parent
		string.gsub(name, "([^/]+)", function(s) if s == '..' then target = target.Parent else target = target[s] end end)
		return require(target)(arg)
	end
else
	-- mostly taken from https://stackoverflow.com/questions/9145432/load-lua-files-by-relative-path
	local location = ((...) == nil and './') or (...):match("(.-)[^%/]+$")
	import = function (name, arg)
		local target = location .. name
		while string.match(target, '/[^/]+/../') do target = string.gsub(target, '/[^/]+/../', '/') end
		return require(target)(arg)
	end
end



import '../lithos/lithos'
import 'vector'



local function block_from_cframe(name, size, cframe)
	local part = Instance.new('Part')
	part.Anchored = true
--	part.FormFactor = 'Custom'
	part.TopSurface = 'Smooth'
	part.BottomSurface = 'Smooth'
	part.Material = 'SmoothPlastic'
	part.Name = name or 'Part'
	
	part.CFrame = cframe or CFrame.new()
	
	if size == nil then
		part.Size = Vector3.new(1,1,1)
	else
		part.Size = Vector3.new(size[1],size[2],size[3])
	end

	return part
end

local function block(name, size, position, rotation)
	if position ~= nil then
		if rotation == nil then
			return block_from_cframe(name, size, CFrame.new(position[1], position[2], position[3]))
		else
			return block_from_cframe(name, size, CFrame.new(position[1], position[2], position[3]) * vector.angled_cframe(rotation))
		end
	else
		return block_from_cframe(name, size, CFrame.new())
	end
end



local function model(name)
	local m = Instance.new('Model')
	m.Name = name or 'Model'
	return m
end

local function group(name, parts)
	local m = model(name)
	table.foreachi(parts,
		function (v)
			v.Parent = m
		end
	)
	return m
end

local function ungroup(m)
	local parent = m.Parent
	table.foreachi(m:GetChildren(),
		function (v)
			v.Parent = parent
		end
	)
end

local function value(name, type, val)
	local v = Instance.new(type .. 'Value')
	v.Value = val
	v.Name = name or type .. 'Value'
	return v
end

-- borrowed with slight modification from the roblox forums
local function joint(part0, part1, joint_type, name)
	local weld = Instance.new(joint_type or "Weld")
	weld.Name = name or joint_type or 'Weld'
	weld.Part0 = part0
	weld.Part1 = part1
	weld.C0 = CFrame.new()
	weld.C1 = part1.CFrame:inverse() * part0.CFrame
	weld.Parent = part0
	return weld
end

local function weld(part0, part1, name)
	return joint(part0, part1, 'Weld', name)
end

local function adv_joint(part0, part1, name, joint_type, c0, c1)
	local weld = Instance.new(joint_type or "Weld")
	weld.Name = name or joint_type or 'Weld'
	weld.Part0 = part0
	weld.Part1 = part1
	weld.C0 = c0
	weld.C1 = c1
	weld.Parent = part0
	return weld
end


local function hinge(part0, part1, name, hinge_type)
	if hinge_type == 'y-planar' then
		return adv_joint(part0, part1, name, 'Rotate', vector.angled_cframe({90,0,0}),
			part1.CFrame:toObjectSpace(part0.CFrame) * vector.angled_cframe({90,0,0}))
	end
end



local function spawn(name, size, position, rotation)
	local part = Instance.new('SpawnLocation')
	part.Anchored = true
--	part.FormFactor = 'Custom'
	part.TopSurface = 'Smooth'
	part.BottomSurface = 'Smooth'
	part.Material = 'SmoothPlastic'
	part.Name = name or 'SpawnLocation'
	
	local cf
	if position ~= nil then
		if rotation == nil then
			cf = CFrame.new(position[1], position[2], position[3])
		else
			cf = CFrame.new(position[1], position[2], position[3]) * vector.angled_cframe(rotation)
		end
	else
		cf = CFrame.new()
	end
	part.CFrame = cf
	
	if size == nil then
		part.Size = Vector3.new(1,1,1)
	else
		part.Size = Vector3.new(size[1],size[2],size[3])
	end

	return part
end



local get_mass_of_model
get_mass_of_model = function (m)
	local mass = 0
	for _, v in pairs(m:GetChildren()) do
		if v:IsA('BasePart') then
			mass = mass + v:GetMass()
		elseif v:IsA('Model') then
			mass = mass + get_mass_of_model(v)
		end
	end
	return mass
end



return export {
	block = {
		block_from_cframe = block_from_cframe,
		block = block,
		spawn = spawn,
		model = model,
		group = group,
		value = value,

		joint = joint,
		weld = weld,
		adv_joint = adv_joint,
		hinge = hinge,

		get_mass_of_model = get_mass_of_model,
	},
}
