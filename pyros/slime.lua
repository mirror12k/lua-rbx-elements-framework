
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
			f.Velocity = Vector3.new(-10,0,0)
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
	add_mountain_step = function (self, positionx, lengthx, positiony, lengthy, opts)
		self:add_hole(positionx, lengthx, positiony, lengthy)
		return self:add('mountain_step', {
			positionx = positionx,
			lengthx = lengthx,
			positiony = positiony,
			lengthy = lengthy,
			depthx = opts.depthx or 1,
			depthy = opts.depthy or 1,
			bank_left = opts.bank_left,
			bank_right = opts.bank_right,
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
			size[1] = size[1] * item.depthx
			size[2] = size[2] * item.depthy

			local pstart = { self.pdelta[1] * item.positionx, self.pdelta[2] * item.positionx }
			local pend = { self.pdelta[1] * (item.positionx + item.lengthx), self.pdelta[2] * (item.positionx + item.lengthx) }
			local pmid = { pstart[1] + size[1], pend[2] - size[2] }


			local s1 = geometry.d2.offset_segment({pstart, pmid}, -90, self.thickness / 2)
			local s2 = geometry.d2.offset_segment({pmid, pend}, -90, self.thickness / 2)
			blueprint:add_part('step', {geometry.d2.distance_of_points(unpack(s1)), self.thickness, item.lengthy * self.width},
				{
					(s1[1][1] + s1[2][1]) / 2,
					(s1[1][2] + s1[2][2]) / 2,
					self.width * (item.positiony + item.lengthy / 2),
				},
				{0, 0, geometry.d2.angle_of_points(unpack(s1))},
				{
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
			blueprint:add_part('step_wall', {geometry.d2.distance_of_points(unpack(s2)), self.thickness, item.lengthy * self.width},
				{
					(s2[1][1] + s2[2][1]) / 2,
					(s2[1][2] + s2[2][2]) / 2,
					self.width * (item.positiony + item.lengthy / 2),
				},
				{0, 0, geometry.d2.angle_of_points(unpack(s2))},
				{
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
			if item.bank_left ~= nil then
				local l = item.lengthx * self.length
				local width = geometry.d2.offset_dist(item.bank_left.angle, l)[2]
				local length = geometry.d2.dist_from_x(item.bank_left.angle, l)

				-- local offset_front = geometry.d2.offset_dist(item.bank_left.angle, length)[2]

				local pback = { pstart[1], pstart[2], self.width * item.positiony }
				-- local pfront = { pend[1], pend[2], self.width * item.positiony + offset_front }

				local cf = CFrame.new(unpack(pback))
					* vector.angled_cframe({0, 0, self.angle})
					* vector.angled_cframe({0, -item.bank_left.angle, 0})
					* CFrame.new(length / 2, - self.thickness / 2, - width / 2)

				-- draw.axis(vector.table_to_vector3(pback), vector.table_to_vector3(pfront))
				blueprint:add_part('step_bank', {length, self.thickness, width},
					vector.vector3_to_table(cf.p),
					vector.angles_from_cframe(cf),
					{
						surface = Enum.SurfaceType.SmoothNoOutlines,
					})

				if item.bank_left.runoff_angle ~= nil then
					local cf = CFrame.new(unpack(pback))
						* vector.angled_cframe({0, 0, self.angle})
						* vector.angled_cframe({0, -item.bank_left.angle, 0})
						* vector.angled_cframe({-item.bank_left.runoff_angle, 0, 0})
						* CFrame.new(length / 2, - self.thickness / 2, - width / 2)
					blueprint:add_part('bank_runoff', {length, self.thickness, width},
						vector.vector3_to_table(cf.p),
						vector.angles_from_cframe(cf),
						{
							surface = Enum.SurfaceType.SmoothNoOutlines,
						})
				end
			end
			if item.bank_right ~= nil then
				local l = item.lengthx * self.length
				local width = geometry.d2.offset_dist(item.bank_right.angle, l)[2]
				local length = geometry.d2.dist_from_x(item.bank_right.angle, l)

				-- local offset_front = geometry.d2.offset_dist(item.bank_right.angle, length)[2]

				local pback = { pstart[1], pstart[2], self.width * (item.positiony + item.lengthy) }
				-- local pfront = { pend[1], pend[2], self.width * (item.positiony + item.lengthy) - offset_front }

				local cf = CFrame.new(unpack(pback))
					* vector.angled_cframe({0, 0, self.angle})
					* vector.angled_cframe({0, item.bank_left.angle, 0})
					* CFrame.new(length / 2, - self.thickness / 2, width / 2)

				-- draw.axis(vector.table_to_vector3(pback), vector.table_to_vector3(pfront))
				blueprint:add_part('step_bank', {length, self.thickness, width},
					vector.vector3_to_table(cf.p),
					vector.angles_from_cframe(cf),
					{
						surface = Enum.SurfaceType.SmoothNoOutlines,
					})
				if item.bank_left.runoff_angle ~= nil then
					local cf = CFrame.new(unpack(pback))
						* vector.angled_cframe({0, 0, self.angle})
						* vector.angled_cframe({0, item.bank_left.angle, 0})
						* vector.angled_cframe({item.bank_left.runoff_angle, 0, 0})
						* CFrame.new(length / 2, - self.thickness / 2, width / 2)
					blueprint:add_part('bank_runoff', {length, self.thickness, width},
						vector.vector3_to_table(cf.p),
						vector.angles_from_cframe(cf),
						{
							surface = Enum.SurfaceType.SmoothNoOutlines,
						})
				end
			end
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
				local bank_angle = math.random(5, 45)
				local runoff_angle = math.random(5, 45)
				blueprint:add_mountain_step(
					offset / length, step_length / length, step_width_1 / width, (step_width_2 - step_width_1) / width,
					{
						depthx = math.random(75, 120) * 0.01,
						depthy = math.random(75, 120) * 0.01,
						bank_left = { angle = bank_angle, runoff_angle = runoff_angle },
						bank_right = { angle = bank_angle, runoff_angle = runoff_angle },
					})
			end
		end
		offset = offset + step_length + math.random(5, 25)
	end

	return blueprint
end



function generate_slime_wave(width, size, cf, parent, tick_fun)
	local tick = tick_fun()
	for i = 0, width, size do
		if math.noise(tick, 15678.215, i / 0.1) > 0 then
			new 'pyros.SlimeBlueprint' (size, 3 * (4/3) * math.pi * size^3 ) -- formula of a sphere
				:build({ cframe = cf * CFrame.new(0, math.random() * size, i + (math.random() - 0.5) * size ) }).Parent = parent
		end
	end
end


function start_mountain_slime_waves(width, size, parent, offset)
	local tick = 0.1
	interval(generate_slime_wave, 1, 1000, width, size, CFrame.new(offset[1] - size * 2, offset[2] + size * 2, offset[3]), parent,
		function ()
			tick = tick + 0.1
			return tick
		end)
end


return export {
	slime_mountain_generator = slime_mountain_generator,
	start_mountain_slime_waves = start_mountain_slime_waves,
}
