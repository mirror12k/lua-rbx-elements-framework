
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


local StreetBlueprint
StreetBlueprint = class 'aeros.StreetBlueprint' {
	_extends = class_by_name 'hydros.CompiledBlueprint',


	add_sidewalk_hole = function (self, street, side, hole_start, hole_end)
		if side == 'left' then
			street.left_sidewalk_holes[#street.left_sidewalk_holes + 1] = { position = hole_start, length = hole_end - hole_start }
		else
			street.right_sidewalk_holes[#street.right_sidewalk_holes + 1] = { position = hole_start, length = hole_end - hole_start }
		end
	end,
	calculate_intersection = function (self, street, other)
		local left_sidewalk = geometry.d2.offset_segment({street.pstart, street.pend}, 90, other.width / 2)
		local right_sidewalk = geometry.d2.offset_segment({street.pstart, street.pend}, -90, other.width / 2)

		local left_start = geometry.d2.offset_segment({other.pstart, other.pend}, 90, other.width / 2)
		left_start = left_start[1]
		local right_start = geometry.d2.offset_segment({other.pstart, other.pend}, -90, other.width / 2)
		right_start = right_start[1]
		local other_left = geometry.d2.offset_segment({other.pstart, other.pend}, 90, other.width / 2)
		local other_right = geometry.d2.offset_segment({other.pstart, other.pend}, -90, other.width / 2)

		local collision_left = geometry.d2.find_segment_collision(left_sidewalk, other_left)
		local collision_right = geometry.d2.find_segment_collision(right_sidewalk, other_left)
		if collision_left ~= nil and collision_right ~= nil then
			-- draw.vertical_line(left_start, {255, 0, 0})
			-- draw.vertical_line(collision_right, {255, 255, 0})
			local offset_left = geometry.d2.distance_of_points(left_start, collision_left)
			local offset_right = geometry.d2.distance_of_points(left_start, collision_right)
			offset_left = offset_left / other.length
			offset_right = offset_right / other.length
			-- print('segment left: ', offset_right, offset_left)
			if offset_left < offset_right then
				self:add_sidewalk_hole(other, 'left', offset_left, offset_right)
			else
				self:add_sidewalk_hole(other, 'left', offset_right, offset_left)
			end
		elseif collision_left ~= nil then
			-- draw.vertical_line(collision_left, {255, 255, 0})
			local offset_left = geometry.d2.distance_of_points(left_start, collision_left)
			offset_left = offset_left / other.length
			-- local angle_diff = geometry.d2.angle_diff(street.angle, other.angle)
			-- print(street.angle, other.angle, angle_diff)
			-- if angle_diff > 90 then
				self:add_sidewalk_hole(other, 'left', 0, offset_left)
			-- else
			-- 	self:add_sidewalk_hole(other, 'left', offset_left, 1)
			-- end

		elseif collision_right ~= nil then
			draw.vertical_line(collision_right, {0, 255, 255})
			local offset_right = geometry.d2.distance_of_points(left_start, collision_right)
			offset_right = offset_right / other.length
			local angle_diff = geometry.d2.angle_diff(street.angle, other.angle)
			-- print(street.angle, other.angle, angle_diff)
			if angle_diff > 90 then
				self:add_sidewalk_hole(other, 'left', 0, offset_right)
			else
				self:add_sidewalk_hole(other, 'left', offset_right, 1)
			end
		end

		collision_left = geometry.d2.find_segment_collision(left_sidewalk, other_right)
		collision_right = geometry.d2.find_segment_collision(right_sidewalk, other_right)
		if collision_left ~= nil and collision_right ~= nil then
			local offset_left = geometry.d2.distance_of_points(right_start, collision_left)
			local offset_right = geometry.d2.distance_of_points(right_start, collision_right)
			offset_left = offset_left / other.length
			offset_right = offset_right / other.length
			-- print('segment right: ', offset_right, offset_left)
			if offset_left < offset_right then
				self:add_sidewalk_hole(other, 'right', offset_left, offset_right)
			else
				self:add_sidewalk_hole(other, 'right', offset_right, offset_left)
			end
		elseif collision_left ~= nil then
			local offset_right = geometry.d2.distance_of_points(right_start, collision_left)
			offset_right = offset_right / other.length
			self:add_sidewalk_hole(other, 'right', 0, offset_right)
		elseif collision_right ~= nil then
			local offset_right = geometry.d2.distance_of_points(right_start, collision_right)
			offset_right = offset_right / other.length
			local angle_diff = geometry.d2.angle_diff(street.angle, other.angle)
			-- print(street.angle, other.angle, angle_diff)
			if angle_diff > 90 then
				self:add_sidewalk_hole(other, 'right', 0, offset_right)
			else
				self:add_sidewalk_hole(other, 'right', offset_right, 1)
			end
		end
	end,
	add_street = function (self, pstart, pend, opts)
		opts = opts or {}

		local data = {
			pstart = pstart,
			pend = pend,
			length = geometry.d2.distance_of_points(pstart, pend),
			angle = 180 - geometry.d2.angle_of_points(pstart, pend),
			width = opts.width or 50,
			thickness = opts.thickness or 2,
			sidewalk_width = opts.sidewalk_width or 8,
			sidewalk_elevation = opts.sidewalk_elevation or 1,
			name = opts.name,
			left_sidewalk_holes = {},
			right_sidewalk_holes = {},
		}

		for _, item in ipairs(self.items) do
			if item[1] == 'street' then
				self:calculate_intersection(data, item[2])
				self:calculate_intersection(item[2], data)
			end
		end

		self:add('street', data)
	end,
	compile_functions = table_append({
		street = function (self, blueprint, item, options)
			blueprint:add_part('pavement', {item.length, item.thickness, item.width},
				{(item.pstart[1] + item.pend[1]) / 2, - item.thickness / 2, (item.pstart[2] + item.pend[2]) / 2},
				{0, item.angle, 0},
				{
					color = {0, 0, 0},
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
			local sidewalk_cframe = CFrame.new(
					(item.pstart[1] + item.pend[1]) / 2,
					item.sidewalk_elevation - item.thickness / 2,
					(item.pstart[2] + item.pend[2]) / 2
				) * vector.angled_cframe({0, item.angle, 0})

			local sections = spaceful.holes_to_sections(spaceful.merge_holes(item.right_sidewalk_holes))
			for _, sec in ipairs(sections) do
				blueprint:add_part('sidewalk_left', {item.length * sec.length, item.thickness, item.sidewalk_width},
					vector.vector3_to_table((
						sidewalk_cframe * CFrame.new(-(sec.position + sec.length / 2 - 0.5) * item.length, 0, item.width / 2 + item.sidewalk_width / 2)
					).p),
					{0, item.angle, 0},
					{
						color = {1, 0.5, 0.5},
						surface = Enum.SurfaceType.SmoothNoOutlines,
					})
			end

			sections = spaceful.holes_to_sections(spaceful.merge_holes(item.left_sidewalk_holes))
			for _, sec in ipairs(sections) do
				blueprint:add_part('sidewalk_right', {item.length * sec.length, item.thickness, item.sidewalk_width},
					vector.vector3_to_table((
						sidewalk_cframe * CFrame.new(-(sec.position + sec.length / 2 - 0.5) * item.length, 0, - (item.width / 2 + item.sidewalk_width / 2))
					).p),
					{0, item.angle, 0},
					{
						color = {0.5, 0.5, 1},
						surface = Enum.SurfaceType.SmoothNoOutlines,
					})
			end
		end,
	}, class_by_name 'hydros.CompiledBlueprint' .compile_functions),
}



local RoomBlueprint
RoomBlueprint = class 'aeros.RoomBlueprint' {
	_extends = class_by_name 'hydros.CompiledBlueprint',


	add_room = function (self, position, length, width, options)
		options = options or {}
		options.thickness = options.thickness or self.thickness or 2

		self:add_wall({position[1] + length / 2 - options.thickness / 2, position[2] + width / 2},
			{position[1] + length / 2 - options.thickness / 2, position[2] - width / 2}, options.north_wall)
		self:add_wall({position[1] -length / 2 + options.thickness / 2, position[2] + width / 2},
			{position[1] -length / 2 + options.thickness / 2, position[2] - width / 2}, options.south_wall)
		self:add_wall({position[1] + length / 2, position[2] + width / 2 - options.thickness / 2},
			{position[1] -length / 2, position[2] + width / 2 - options.thickness / 2}, options.east_wall)
		self:add_wall({position[1] + length / 2, position[2] -width / 2 + options.thickness / 2},
			{position[1] -length / 2, position[2] -width / 2 + options.thickness / 2}, options.west_wall)
		-- add_floor()
	end,
	add_wall = function (self, pstart, pend, options)
		options = options or {}
		self:add('wall', {
			pstart = pstart,
			pend = pend,
			length = geometry.d2.distance_of_points(pstart, pend),
			-- i honestly have no clue what the 180 - ... is for
			-- it just worked properly for a while, and then started mirroring since the new sectioned wall creation
			-- and this mirroring reverses the new mirroring.
			-- though i'd still love to know why the mirroring is happening in the first place, cause i don't remember changing anything about the angling code

			-- ok, a little more research shows that because roblox has it's z axis reversed backwards, the forth quadrant is where the first should be, etc
			angle = 180 - geometry.d2.angle_of_points(pstart, pend),
			height = options.height or self.height or 12,
			thickness = options.thickness or self.thickness or 2,
			holes = options.holes,
		})
	end,
	add_floor = function (self, size, position, rotation, options)
		options = options or {}
		self:add('floor', {
			size = size,
			position = position,
			rotation = rotation,
		})
	end,

	compile_functions = table_append({
		wall = function (self, blueprint, item, options)
			local length = item.length
			local pstart = item.pstart
			local pdelta = { item.pend[1] - item.pstart[1], item.pend[2] - item.pstart[2] }
			local sections = {{ positionx = 0, lengthx = 1, elevation = 0, height = 1 }}

			if item.holes ~= nil then
				for _, hole in ipairs(item.holes) do
					local target = -1
					for i, v in ipairs(sections) do
						if v.positionx <= hole.position and v.positionx + v.lengthx > hole.position and
								(hole.elevation == nil and hole.height == nil or v.elevation <= hole.elevation and v.elevation + v.height > hole.elevation) then
							if hole.lengthx + hole.position > v.positionx + v.lengthx then
								error('invalid hole: ' .. tostring(hole.position) .. ' - ' .. tostring(hole.lengthx))
							end
							target = i
							break
						end
					end

					if target == -1 then
						error('hole out of bounds: ' .. tostring(hole.position) .. ' - ' .. tostring(hole.lengthx))
					end

					-- calculate the before and after pieces of wall
					local sec = table.remove(sections, target)
					if sec.positionx == hole.position then
						if sec.lengthx == hole.lengthx then
							-- do nothing to delete the section
						else
							table.insert(sections, target, {
								positionx = sec.positionx + hole.lengthx,
								lengthx = sec.lengthx - hole.lengthx,
								elevation = sec.elevation,
								height = sec.height,
							})
						end
					else
						if sec.positionx + sec.lengthx == hole.position + hole.lengthx then
							table.insert(sections, target, {
								positionx = sec.positionx,
								lengthx = hole.position - sec.positionx,
								elevation = sec.elevation,
								height = sec.height,
							})
						else
							table.insert(sections, target, {
								positionx = hole.position + hole.lengthx,
								lengthx = (sec.lengthx + sec.positionx) - (hole.lengthx + hole.position),
								elevation = sec.elevation,
								height = sec.height,
							})
							table.insert(sections, target, {
								positionx = sec.positionx,
								lengthx = hole.position - sec.positionx,
								elevation = sec.elevation,
								height = sec.height,
							})
						end
					end

					-- calculate the above and below pieces of wall
					if hole.elevation ~= nil and hole.height ~= nil then
						if hole.elevation == sec.elevation then
							if hole.height == sec.height then
								-- do nothing
							else
								table.insert(sections, target, {
									positionx = hole.position,
									lengthx = hole.lengthx,
									elevation = hole.elevation + hole.height,
									height = sec.height - hole.height,
								})
							end
						else
							if hole.elevation + hole.height == sec.elevation + sec.height then
								table.insert(sections, target, {
									positionx = hole.position,
									lengthx = hole.lengthx,
									elevation = sec.elevation,
									height = hole.elevation - sec.elevation,
								})
							else
								table.insert(sections, target, {
									positionx = hole.position,
									lengthx = hole.lengthx,
									elevation = sec.elevation,
									height = hole.elevation - sec.elevation,
								})
								table.insert(sections, target, {
									positionx = hole.position,
									lengthx = hole.lengthx,
									elevation = hole.elevation + hole.height,
									height = (sec.height + sec.elevation) - (hole.height + hole.elevation),
								})
							end
						end
					end

				end
			end

			for _, sec in ipairs(sections) do
				blueprint:add_part('wall', {sec.lengthx * item.lengthx, item.height * sec.height, item.thickness},
					{
						pstart[1] + pdelta[1] * (sec.positionx + sec.lengthx / 2),
						item.height * (sec.elevation + sec.height / 2),
						pstart[2] + pdelta[2] * (sec.positionx + sec.lengthx / 2)
					},
					{0, item.angle, 0},
					{
						surface = Enum.SurfaceType.SmoothNoOutlines,
					})
			end
		end,
		floor = function (self, blueprint, item, options)
			blueprint:add_part('wall', item.size,
				item.position,
				{0, item.rotation, 0},
				{})
		end,
	}, class_by_name 'hydros.CompiledBlueprint' .compile_functions),
}



return export {}
