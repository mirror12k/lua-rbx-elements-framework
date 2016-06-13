
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


import 'slime'





-- globally available settings
-- they are put into the registry under 'slime_mountain' when start_slime_mountain is called
local settings = {
	spawn_slimes = true,
	spawn_slime_checkpoints = true,
	slime_size_factor = 5,
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
		return {self.pdelta[1], self.pdelta[2], 0}
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
	add_mountain_crack = function (self, positionx, lengthx, positiony, lengthy, opts)
		opts = opts or {}
		self:add_hole(positionx, lengthx, positiony, lengthy)
		return self:add('mountain_crack', {
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
	add_mountain_step = function (self, positionx, lengthx, positiony, lengthy, opts)
		opts = opts or {}
		-- a hole is unneeded here because negative ground is not taken
		-- self:add_hole(positionx, lengthx, positiony, lengthy)
		return self:add('mountain_step', {
			positionx = positionx,
			lengthx = lengthx,
			positiony = positiony,
			lengthy = lengthy,
			angle = opts.angle or 0,
			bank_left = opts.bank_left,
			bank_right = opts.bank_right,
		})
	end,
	add_zigzag = function (self, direction, positionx, lengthx, positiony, lengthy, opts)
		opts = opts or {}
		self:add_hole(positionx, lengthx, positiony, lengthy)
		return self:add('zigzag', {
			direction = direction,
			positionx = positionx,
			lengthx = lengthx,
			positiony = positiony,
			lengthy = lengthy,
			step_percent = opts.step_percent or 0.1,
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
					color = {0.2, 0.8, 0.2},
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
		end
		return blueprint
	end,

	compile_functions = table_append({
		mountain_crack = function (self, blueprint, item, options)
			local size = geometry.d2.offset_dist(self.angle, item.lengthx * self.length)
			size[1] = size[1] * item.depthx
			size[2] = size[2] * item.depthy

			local pstart = { self.pdelta[1] * item.positionx, self.pdelta[2] * item.positionx }
			local pend = { self.pdelta[1] * (item.positionx + item.lengthx), self.pdelta[2] * (item.positionx + item.lengthx) }
			local pmid = { pstart[1] + size[1], pend[2] - size[2] }


			local s1 = geometry.d2.offset_segment({pstart, pmid}, -90, self.thickness / 2)
			local s2 = geometry.d2.offset_segment({pmid, pend}, -90, self.thickness / 2)
			blueprint:add_part('crack_base', {geometry.d2.distance_of_points(unpack(s1)), self.thickness, item.lengthy * self.width},
				{
					(s1[1][1] + s1[2][1]) / 2,
					(s1[1][2] + s1[2][2]) / 2,
					self.width * (item.positiony + item.lengthy / 2),
				},
				{0, 0, geometry.d2.angle_of_points(unpack(s1))},
				{
					color = {0.25, 0.25, 0.25},
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
			blueprint:add_part('crack_wall', {geometry.d2.distance_of_points(unpack(s2)), self.thickness, item.lengthy * self.width},
				{
					(s2[1][1] + s2[2][1]) / 2,
					(s2[1][2] + s2[2][2]) / 2,
					self.width * (item.positiony + item.lengthy / 2),
				},
				{0, 0, geometry.d2.angle_of_points(unpack(s2))},
				{
					color = {0.25, 0.25, 0.25},
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
				blueprint:add_part('crack_bank', {length, self.thickness, width},
					vector.vector3_to_table(cf.p),
					vector.angles_from_cframe(cf),
					{
						color = {0.2, 0.8, 0.2},
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
							color = {0.25, 0.25, 0.25},
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
				blueprint:add_part('crack_bank', {length, self.thickness, width},
					vector.vector3_to_table(cf.p),
					vector.angles_from_cframe(cf),
					{
						color = {0.2, 0.8, 0.2},
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
							color = {0.25, 0.25, 0.25},
							surface = Enum.SurfaceType.SmoothNoOutlines,
						})
				end
			end
		end,
		mountain_step = function (self, blueprint, item, options)
			local size = geometry.d2.offset_dist(self.angle + item.angle, item.lengthx * self.length)

			local pstart = { self.pdelta[1] * item.positionx, self.pdelta[2] * item.positionx }
			local pend = { self.pdelta[1] * (item.positionx + item.lengthx), self.pdelta[2] * (item.positionx + item.lengthx) }
			local pmid = { pend[1] - size[1], pstart[2] + size[2] }


			local seg = geometry.d2.offset_segment({pend, pmid}, 90, self.thickness / 2)

			blueprint:add_part('step', {geometry.d2.distance_of_points(unpack(seg)), self.thickness, item.lengthy * self.width},
				{
					(seg[1][1] + seg[2][1]) / 2,
					(seg[1][2] + seg[2][2]) / 2,
					self.width * (item.positiony + item.lengthy / 2),
				},
				{0, 0, geometry.d2.angle_of_points(unpack(seg))},
				{
					color = {0.38, 0.38, 0.38},
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})

			local cf = CFrame.new((pend[1] + pmid[1]) / 2, (pend[2] + pmid[2]) / 2, self.width * item.positiony)
				* vector.angled_cframe({0, 0, geometry.d2.angle_of_points(unpack(seg))})
				* vector.angled_cframe({-item.bank_left, 0, 0})
				* CFrame.new(0, self.thickness / 2, item.lengthy * self.width / 2)

			blueprint:add_part('step_bank', {geometry.d2.distance_of_points(unpack(seg)), self.thickness, item.lengthy * self.width},
				vector.vector3_to_table(cf.p),
				vector.angles_from_cframe(cf),
				{
					color = {0.38, 0.38, 0.38},
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})

			local cf = CFrame.new((pend[1] + pmid[1]) / 2, (pend[2] + pmid[2]) / 2, self.width * (item.positiony + item.lengthy))
				* vector.angled_cframe({0, 0, geometry.d2.angle_of_points(unpack(seg))})
				* vector.angled_cframe({item.bank_right, 0, 0})
				* CFrame.new(0, self.thickness / 2, -item.lengthy * self.width / 2)

			blueprint:add_part('step_bank', {geometry.d2.distance_of_points(unpack(seg)), self.thickness, item.lengthy * self.width},
				vector.vector3_to_table(cf.p),
				vector.angles_from_cframe(cf),
				{
					color = {0.38, 0.38, 0.38},
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})

		end,
		zigzag = function (self, blueprint, item, options)
			local pstart = { self.pdelta[1] * item.positionx, self.pdelta[2] * item.positionx }
			local pend = { self.pdelta[1] * (item.positionx + item.lengthx), self.pdelta[2] * (item.positionx + item.lengthx) }
			local size = { pend[1] - pstart[1], pend[2] - pstart[2] }


			local step_width = self.width * item.lengthy * item.step_percent
			local slope_horizontal_width = self.width * item.lengthy - (step_width * 2)
			local slope_width = geometry.d2.distance_of_point({slope_horizontal_width, size[2]})

			local step_offset = size[2] / 2
			if item.direction == 'right' then
				step_offset = -step_offset
			end

			blueprint:add_part('zigzag_wall', { 5, size[2], self.width * item.lengthy},
				{ pend[1] + 5 / 2, (pstart[2] + pend[2]) / 2, self.width * (item.positiony + item.lengthy / 2) },
				nil,
				{
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})

			blueprint:add_part('zigzag_step', {size[1], size[2], step_width},
				{ (pstart[1] + pend[1]) / 2, pstart[2] + step_offset, self.width * item.positiony + step_width / 2 },
				nil,
				{
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})

			blueprint:add_part('zigzag_step', {size[1], size[2], step_width},
				{ (pstart[1] + pend[1]) / 2, pstart[2] - step_offset, self.width * (item.positiony + item.lengthy) - step_width / 2 },
				nil,
				{
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})

			-- {y,z} format points
			local ptop = { pend[2], self.width * item.positiony + step_width }
			local pbot = { pstart[2], self.width * (item.positiony + item.lengthy) - step_width }
			if item.direction == 'right' then
				local store = ptop[1]
				ptop[1] = pbot[1]
				pbot[1] = store
			end

			local seg = geometry.d2.offset_segment({ptop, pbot}, 90, size[2] / 2)

			local slope_angle = geometry.d2.angle_of_point({slope_horizontal_width, size[2]})
			if item.direction == 'right' then
				slope_angle = -slope_angle
			end

			blueprint:add_part('zigzag_slope', {size[1], size[2], slope_width},
				{ (pstart[1] + pend[1]) / 2, (seg[1][1] + seg[2][1]) / 2, (seg[1][2] + seg[2][2]) / 2 },
				{slope_angle, 0, 0},
				{
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})


		end,
	}, class_by_name 'hydros.CompiledBlueprint' .compile_functions),
}


local function slime_zigzag_mountain_generator (width, length, angle)
	local blueprint = new 'pyros.slime.SlimeMountainBlueprint' (width, length, angle)

	local offset = 0
	local is_left = true
	while offset < length do
		local step_length = math.random(10, 70)
		if offset + step_length < length then
			local direction = is_left and 'left' or 'right'
			is_left = not is_left
			blueprint:add_zigzag(direction, offset / length, step_length / length, 0, 1, {})
		end
		offset = offset + step_length + math.random(10, 30) * 0.1
	end

	return blueprint
end

local function slime_mountain_generator (width, length, angle)
	local blueprint = new 'pyros.slime.SlimeMountainBlueprint' (width, length, angle)

	local offset = 20
	while offset < length do
		local step_length = math.random(10, 30)
		if offset + step_length < length then
			local step_width_1, step_width_2 = math.random(0, width), math.random(0, width)
			-- ensure that
			if step_width_1 > step_width_2 then
				local store = step_width_1
				step_width_1 = step_width_2
				step_width_2 = store
			end
			-- ensure the width is sufficient
			while (step_width_2 - step_width_1) / width < 0.2 do
				step_width_1, step_width_2 = math.random(0, width), math.random(0, width)
				if step_width_1 > step_width_2 then
					local store = step_width_1
					step_width_1 = step_width_2
					step_width_2 = store
				end
			end
			if (step_width_2 - step_width_1) / width >= 0.7 then
				local step_width_3, step_width_4 = math.random(step_width_1 + width * 0.1, step_width_2 - width * 0.1),
						math.random(step_width_1 + width * 0.1, step_width_2 - width * 0.1)
				if step_width_3 > step_width_4 then
					local store = step_width_3
					step_width_3 = step_width_4
					step_width_4 = store
				end
				while (step_width_4 - step_width_3) / width < 0.2 do
					step_width_3, step_width_4 = math.random(step_width_1 + width * 0.1, step_width_2 - width * 0.1),
						math.random(step_width_1 + width * 0.1, step_width_2 - width * 0.1)
					if step_width_3 > step_width_4 then
						local store = step_width_3
						step_width_3 = step_width_4
						step_width_4 = store
					end
				end

				if math.random() > 0.5 then
					local bank_angle = math.random(5, 45)
					local runoff_angle = math.random(5, 45)
					blueprint:add_mountain_crack(
						offset / length, step_length / length, step_width_1 / width, (step_width_3 - step_width_1) / width,
						{
							depthx = math.random(75, 120) * 0.01,
							depthy = math.random(75, 120) * 0.01,
							bank_left = { angle = bank_angle, runoff_angle = runoff_angle },
							bank_right = { angle = bank_angle, runoff_angle = runoff_angle },
						})
				else
					local bank_angle = math.random(20, 60)
					blueprint:add_mountain_step(
						offset / length, step_length / length, step_width_1 / width, (step_width_3 - step_width_1) / width,
						{
							angle = math.random(-15, 0),
							bank_left = bank_angle,
							bank_right = bank_angle,
						})
				end

				if math.random() > 0.5 then
					local bank_angle = math.random(5, 45)
					local runoff_angle = math.random(5, 45)
					blueprint:add_mountain_crack(
						offset / length, step_length / length, step_width_4 / width, (step_width_2 - step_width_4) / width,
						{
							depthx = math.random(75, 120) * 0.01,
							depthy = math.random(75, 120) * 0.01,
							bank_left = { angle = bank_angle, runoff_angle = runoff_angle },
							bank_right = { angle = bank_angle, runoff_angle = runoff_angle },
						})
				else
					local bank_angle = math.random(20, 60)
					blueprint:add_mountain_step(
						offset / length, step_length / length, step_width_4 / width, (step_width_2 - step_width_4) / width,
						{
							angle = math.random(-15, 0),
							bank_left = bank_angle,
							bank_right = bank_angle,
						})
				end
			else
				if math.random() > 0.5 then
					local bank_angle = math.random(5, 45)
					local runoff_angle = math.random(5, 45)
					blueprint:add_mountain_crack(
						offset / length, step_length / length, step_width_1 / width, (step_width_2 - step_width_1) / width,
						{
							depthx = math.random(75, 120) * 0.01,
							depthy = math.random(75, 120) * 0.01,
							bank_left = { angle = bank_angle, runoff_angle = runoff_angle },
							bank_right = { angle = bank_angle, runoff_angle = runoff_angle },
						})
				else
					local bank_angle = math.random(20, 60)
					blueprint:add_mountain_step(
						offset / length, step_length / length, step_width_1 / width, (step_width_2 - step_width_1) / width,
						{
							angle = math.random(-15, 0),
							bank_left = bank_angle,
							bank_right = bank_angle,
						})
				end
			end
		end
		offset = offset + step_length + math.random(5, 25)
	end

	return blueprint
end


local function multi_slope_slime_mountain_generator(width, count, opts)
	local bp = new 'hydros.ModelBlueprint' ()
	local position = {0, 0, 0}

	opts.requirements = opts.requirements or {}

	for i = 1, count do
		local length = math.random(opts.min_length or 200, opts.max_length or 400)
		local angle = math.random(opts.min_angle or 30, opts.max_angle or 45)


		local mountain
		if opts.requirements[i].type == 'zigzag' then
			mountain = slime_zigzag_mountain_generator(width, length * 0.75, angle)
		else
			mountain = slime_mountain_generator(width, length, angle)
		end
		bp:add_model(nil, mountain, { position = position })

		local new_position = mountain:get_top_edge()
		position = { new_position[1] + position[1], new_position[2] + position[2], new_position[3] + position[3] }
	end

	return bp, position
end



local function start_mountain_slime_waves(width, orginal_size, parent, offset)
	local cf = offset
	local tick = 0.1

	cw(function ()
		while true do
			while settings.spawn_slimes ~= true do
				wait(1)
			end

			tick = tick + 0.1
			local size = orginal_size + (((math.noise(tick * 4, 54653.215, 15.36375) + 0.5) * 2) ^ 2) * settings.slime_size_factor

			local count = 0
			local spawned = 0
			local color = vector.color3_to_table(Color3.fromHSV(math.random(), 1, 1))
			for i = 0, width, size do
				count = count + 1
				if math.noise(tick, 15678.215, i * 0.125) > 0 then
					spawned = spawned + 1
					new 'pyros.SlimeBlueprint' (size, 3 * (4/3) * math.pi * size^3, color) -- formula of a sphere
						:build({ cframe = cf * CFrame.new(-size * 2, size * 2, 0)
							* CFrame.new(0, math.random() * size, i + (math.random() - 0.5) * size ) }).Parent = parent
				end
			end
			wait(3 * spawned / count)
		end
	end)
end


local function generate_mountain_top_platform(width)
	local bp = new 'hydros.ModelBlueprint' ()

	local length = 100

	bp:add_part('base', {length, 5, width}, {length / 2, -2.5, width / 2}, nil, { surface = Enum.SurfaceType.SmoothNoOutlines })

	local dimension = ((length ^ 2) / 2) ^ 0.5
	bp:add_part('base_edge', {dimension, 5, dimension}, {length / 2, -2.5, 0}, {0, 45, 0}, { surface = Enum.SurfaceType.SmoothNoOutlines })
	bp:add_part('base_edge', {dimension, 5, dimension}, {length / 2, -2.5, width}, {0, 45, 0}, { surface = Enum.SurfaceType.SmoothNoOutlines })

	bp:add_part('teleporter', {4, 10, 4}, {length - 8 / 2, 5, width / 2}, nil, { transparency = 0.5, color = {0.2, 1, 0.2}, cancollide = false })

	return bp
end

local function spawn_slime_cluster(cf, target, size, count, parent)
	local color = vector.color3_to_table(Color3.fromHSV(math.random(), 1, 1))
	for i = 1, count do
		new 'pyros.SlimeBlueprint' (size, 3 * (4/3) * math.pi * size^3, color) -- formula of a sphere
			:build({ cframe = cf * CFrame.new(-size * 2, size * 2, 0)
				* CFrame.new(0, math.random() * size, target.z + (math.random() - 0.5) * size ) }).Parent = parent
	end
end

local function start_slime_mountain_checkpoints(bottom, top, width, teleporter)
	local game_triggers = {}
	-- slime checkpoint waves
	for _, offset in ipairs({0.2, 0.45, 0.7}) do

		local new_trigger = {}
		new_trigger.op = function (trigger, char)
				local torso = char:FindFirstChild('Torso')
				if torso ~= nil  and settings.spawn_slime_checkpoints == true then
					spawn_slime_cluster(CFrame.new(unpack(top)), torso.Position, 14, 7, workspace)
				end
			end
		new_trigger.trigger = trigger.disposable_character_trigger({10, 400, width},
			{bottom[1] + (top[1] - bottom[1]) * offset, bottom[2] + (top[2] - bottom[2]) * offset, width / 2},
			new_trigger.op)
		game_triggers[#game_triggers + 1] = new_trigger
	end
	-- win trigger
	-- make it a little wider to make sure it catches everyone
	local new_trigger = {}
	new_trigger.op = function (trigger, char)
			local torso = char:FindFirstChild('Torso')
			if torso ~= nil then
				print('winrar')
			end
		end
	new_trigger.trigger = trigger.disposable_character_trigger({10, 100, width + 40}, {top[1], 50 + top[2], width / 2}, new_trigger.op)
	game_triggers[#game_triggers + 1] = new_trigger

	trigger.hook_character_absolute_teleport(teleporter, {bottom[1], bottom[2] + 50, bottom[3] + 50}, function (_, id, char)
		-- rehook all events on trigger
		for _, game_trigger in ipairs(game_triggers) do
			trigger.hook_disposable_character_trigger(game_trigger.trigger, char, game_trigger.op)
		end
	end)

end



local function start_slime_mountain()
	-- register the settings for global access
	registry.link_table('slime_mountain', settings)

	local width = 150

	local mountain, top = multi_slope_slime_mountain_generator(width, 3, {
			requirements = {
				{},
				{ type = 'zigzag' },
				{},
			}
	})
	local mountain_top = generate_mountain_top_platform(width)

	mountain:build().Parent = workspace
	local mountain_top_model = mountain_top:build({ cframe = CFrame.new(unpack(top)) })
	mountain_top_model.Parent = workspace



	block.spawn('spawn', {10, 1, 10}, {0, 50, 50}).Parent = workspace

	start_mountain_slime_waves(width, 10, workspace, CFrame.new(vector.table_to_vector3(top)))
	start_slime_mountain_checkpoints({0, 0, 0}, top, width, mountain_top_model.teleporter)
end

return export {
	slime_mountain = {
		mountain_generator = mountain_generator,
		multi_slope_mountain_generator = multi_slope_mountain_generator,
		start_slime_waves = start_slime_waves,
		start_mountain_checkpoints = start_mountain_checkpoints,
		start = start_slime_mountain,
	}
}
