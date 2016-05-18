
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

	add_street = function (self, pstart, pend, opts)
		opts = opts or {}
		self:add('street', {
			pstart = pstart,
			pend = pend,
			length = math.sqrt(math.abs(pstart[1] - pend[1])^2 + math.abs(pstart[2] - pend[2])^2),
			angle = math.deg(math.atan2(pend[2] - pstart[2], pend[1] - pstart[1])),
			width = opts.width or 50,
			thickness = opts.thickness or 2,
			sidewalk_width = opts.sidewalk_width or 8,
			sidewalk_elevation = opts.sidewalk_elevation or 1,
			name = opts.name,
		})
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
			blueprint:add_part('sidewalk', {item.length, item.thickness, item.sidewalk_width},
				vector.vector3_to_table((sidewalk_cframe * CFrame.new(0, 0, item.width / 2 + item.sidewalk_width / 2)).p),
				{0, item.angle, 0},
				{
					color = {0.5, 0.5, 0.5},
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
			blueprint:add_part('sidewalk', {item.length, item.thickness, item.sidewalk_width},
				vector.vector3_to_table((sidewalk_cframe * CFrame.new(0, 0, - (item.width / 2 + item.sidewalk_width / 2))).p),
				{0, item.angle, 0},
				{
					color = {0.5, 0.5, 0.5},
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
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
			length = math.sqrt(math.abs(pstart[1] - pend[1])^2 + math.abs(pstart[2] - pend[2])^2),
			-- i honestly have no clue what the 180 - ... is for
			-- it just worked properly for a while, and then started mirroring since the new sectioned wall creation
			-- and this mirroring reverses the new mirroring.
			-- though i'd still love to know why the mirroring is happening in the first place, cause i don't remember changing anything about the angling code
			angle = 180 - math.deg(math.atan2(pend[2] - pstart[2], pend[1] - pstart[1])),
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
			local sections = {{ offset = 0, length = 1, elevation = 0, height = 1 }}

			if item.holes ~= nil then
				for _, hole in ipairs(item.holes) do
					local target = -1
					for i, v in ipairs(sections) do
						if v.offset <= hole.position and v.offset + v.length > hole.position and
								(hole.elevation == nil and hole.height == nil or v.elevation <= hole.elevation and v.elevation + v.height > hole.elevation) then
							if hole.length + hole.position > v.offset + v.length then
								error('invalid hole: ' .. tostring(hole.position) .. ' - ' .. tostring(hole.length))
							end
							target = i
							break
						end
					end

					if target == -1 then
						error('hole out of bounds: ' .. tostring(hole.position) .. ' - ' .. tostring(hole.length))
					end

					-- calculate the before and after pieces of wall
					local sec = table.remove(sections, target)
					if sec.offset == hole.position then
						if sec.length == hole.length then
							-- do nothing to delete the section
						else
							table.insert(sections, target, {
								offset = sec.offset + hole.length,
								length = sec.length - hole.length,
								elevation = sec.elevation,
								height = sec.height,
							})
						end
					else
						if sec.offset + sec.length == hole.position + hole.length then
							table.insert(sections, target, {
								offset = sec.offset,
								length = hole.position - sec.offset,
								elevation = sec.elevation,
								height = sec.height,
							})
						else
							table.insert(sections, target, {
								offset = hole.position + hole.length,
								length = (sec.length + sec.offset) - (hole.length + hole.position),
								elevation = sec.elevation,
								height = sec.height,
							})
							table.insert(sections, target, {
								offset = sec.offset,
								length = hole.position - sec.offset,
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
									offset = hole.position,
									length = hole.length,
									elevation = hole.elevation + hole.height,
									height = sec.height - hole.height,
								})
							end
						else
							if hole.elevation + hole.height == sec.elevation + sec.height then
								table.insert(sections, target, {
									offset = hole.position,
									length = hole.length,
									elevation = sec.elevation,
									height = hole.elevation - sec.elevation,
								})
							else
								table.insert(sections, target, {
									offset = hole.position,
									length = hole.length,
									elevation = sec.elevation,
									height = hole.elevation - sec.elevation,
								})
								table.insert(sections, target, {
									offset = hole.position,
									length = hole.length,
									elevation = hole.elevation + hole.height,
									height = (sec.height + sec.elevation) - (hole.height + hole.elevation),
								})
							end
						end
					end

				end
			end

			for _, sec in ipairs(sections) do
				blueprint:add_part('wall', {sec.length * item.length, item.height * sec.height, item.thickness},
					{
						pstart[1] + pdelta[1] * (sec.offset + sec.length / 2),
						item.height * (sec.elevation + sec.height / 2),
						pstart[2] + pdelta[2] * (sec.offset + sec.length / 2)
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
