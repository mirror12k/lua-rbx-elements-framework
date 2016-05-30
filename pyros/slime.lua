
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
import '../hydros/hydros'
import '../aeros/aeros'




local SlimeAI
SlimeAI = class 'pyros.SlimeAI' {
	_init = function (self, size, model)
		self.size = size
		self.model = model
		self:hook()
	end,
	hook = function (self)
		self.model.body.Touched:connect(function (other) self:touched(other) end)
	end,
	touched = function (self, other)
		if self.model.Parent ~= nil and other ~= nil and other.Parent ~= nil then
			if other.Anchored == false and other.Parent:FindFirstChild('ai_type') == nil then
				other:BreakJoints()
				other.Parent = self.model
				other.CFrame = CFrame.new(self.model.core.Position + (other.Position - self.model.core.Position).unit * self.size / 3)
					* vector.angled_cframe({math.random() * 360, math.random() * 360, math.random() * 360})
				block.weld(self.model.core, other)
				-- this digesting operation is expensive and multiple parts can create massive processing costs
				-- comment it out if the slimes are eating large amounts of parts
				-- or perhaps fiddle with the constants
				interval(self.digest_part, 1, 10, self, other)
				timeout(self.finish_digesting_part, 10, self, other)
			end
		end
	end,
	digest_part = function (self, part)
		if part.Parent ~= nil then
			local cf = part.CFrame
			part.Size = part.Size * 0.9
			part.CFrame = cf
			block.weld(self.model.core, part)
		end
	end,
	finish_digesting_part = function (self, part)
		if part.Parent ~= nil then
			part:Destroy()
		end
	end,
}



local SlimeBlueprint
SlimeBlueprint = class 'pyros.SlimeBlueprint' {
	_extends = 'hydros.ModelBlueprint',

	_init = function (self, size, dampening, color, name)
		SlimeBlueprint.super._init(self, name)
		self.size = size
		self.dampening = dampening

		self:add_part('body', {size, size, size}, nil, nil, {
			shape = Enum.PartType.Ball,
			transparency = 0.6,
			anchored = false,
			color = color,
		})
		self:add_part('core', {size / 6, size / 6, size / 6}, nil, nil, {
			shape = Enum.PartType.Ball,
			transparency = 0.2,
			anchored = false,
			color = color,
		})
		self:add_weld('body', 'core')
		self:add_value('ai_type', 'String', 'slime')
	end,
	build = function (self, ...)
		local m = SlimeBlueprint.super.build(self, ...)
		local ai = SlimeAI.new(self.size, m)
		if self.dampening ~= nil then
			local f = Instance.new('BodyVelocity')
			f.Velocity = Vector3.new(0,0,0)
			f.MaxForce = Vector3.new(self.dampening, self.dampening, self.dampening)
			f.Parent = m.core
		end
		return m
	end,
}



local SlimeMountainBlueprint
SlimeMountainBlueprint = class 'pyros.slime.SlimeMountainBlueprint' {
	_extends = 'hydros.CompiledBlueprint',
	
	_init = function (self, width, length, angle, name)
		SlimeMountainBlueprint.super._init(self, name)
		self.width = width
		self.length = length
		self.angle = angle
		self.thickness = 20

		self.offset = geometry.d2.offset_dist(self.angle - 90, self.thickness / 2)
		self.pdelta = geometry.d2.offset_dist(self.angle, self.length)

		self.holes = {}
	end,

	get_top_edge = function (self)
		return {self.pdelta[1] + self.offset[1], self.pdelta[2] + self.offset[2], 0}
	end,
	add_hole = function (self, positionx, lengthx, positiony, lengthy)
		self.holes[#self.holes + 1] = {
			positionx = positionx,
			lengthx = lengthx,
			positiony = positiony,
			lengthy = lengthy,
		}
		return self
	end,
	add_mountain_step = function (self, positionx, lengthx, positiony, lengthy)
		self:add_hole(positionx, lengthx, positiony, lengthy)
		return self:add('mountain_step', {
			positionx = positionx,
			lengthx = lengthx,
			positiony = positiony,
			lengthy = lengthy,
		})
	end,
	compile_self = function (self, ...)
		local blueprint = SlimeMountainBlueprint.super.compile_self(self, ...)

		local sections = spaceful.holes_to_sections_d2(self.holes)
		for _, sec in ipairs(sections) do
			blueprint:add_part('mountain_slope', {self.length * sec.lengthx, self.thickness, self.width * sec.lengthy},
				{
					self.offset[1] + self.pdelta[1] * (sec.positionx + sec.lengthx / 2),
					self.offset[2] + self.pdelta[2] * (sec.positionx + sec.lengthx / 2),
					self.width * (sec.positiony + sec.lengthy / 2),
				},
				{0, 0, self.angle},
				{
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
		end
		return blueprint
	end,

	compile_functions = table_append({
		mountain_step = function (self, blueprint, item, options)
			local size = geometry.d2.offset_dist(self.angle, item.lengthx * self.length)
			local slope_offset = geometry.d2.offset_dist(self.angle + 90, self.thickness / 2)
			blueprint:add_part('step', {size[1], self.thickness, item.lengthy * self.width},
				{
					slope_offset[1] + self.offset[1] + self.pdelta[1] * item.positionx + size[1] / 2,
					slope_offset[2] + self.offset[2] + self.pdelta[2] * item.positionx - self.thickness / 2,
					self.width * (item.positiony + item.lengthy / 2),
				},
				nil,
				{
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
			blueprint:add_part('step', {size[2], self.thickness, item.lengthy * self.width},
				{
					slope_offset[1] + self.offset[1] + self.pdelta[1] * (item.positionx + item.lengthx) + self.thickness / 2,
					slope_offset[2] + self.offset[2] + self.pdelta[2] * (item.positionx + item.lengthx) - size[2] / 2,
					self.width * (item.positiony + item.lengthy / 2),
				},
				{0, 0, 90},
				{
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
		end,
	}, class_by_name 'hydros.CompiledBlueprint' .compile_functions),
}



function slime_mountain_generator (width, length, angle)
	local blueprint = new 'pyros.slime.SlimeMountainBlueprint' (width, length, angle)

	local offset = 20
	while offset < length do
		local step_length = math.random(10, 20)
		if offset + step_length < length then
			local step_width_1, step_width_2 = math.random(0, width), math.random(0, width)
			if step_width_1 > step_width_2 then
				local store = step_width_1
				step_width_1 = step_width_2
				step_width_2 = store
			end
			if step_width_1 ~= step_width_2 then
				blueprint:add_mountain_step(offset / length, step_length / length, step_width_1 / width, (step_width_2 - step_width_1) / width)
			end
		end
		offset = offset + step_length + math.random(0, 40)
	end

	return blueprint
end


function generate_slime_wave(width, size, cf, parent)
	for i = 0, width, size do
		new 'pyros.SlimeBlueprint' (size, 2 * (4/3) * math.pi * size^3 ) -- formula of a sphere
			:build({ cframe = cf * CFrame.new(0, 0, i) }).Parent = parent
	end
end


function start_mountain_slime_waves(width, size, parent, offset)
	interval(generate_slime_wave, 5, 1000, width, size, CFrame.new(offset[1] - size * 2, offset[2] + size * 2, offset[3]), parent)
end


return export {
	slime_mountain_generator = slime_mountain_generator,
	start_mountain_slime_waves = start_mountain_slime_waves,
}
