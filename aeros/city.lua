
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
			local sidewalk_cframe = CFrame.new((item.pstart[1] + item.pend[1]) / 2, item.sidewalk_elevation - item.thickness / 2, (item.pstart[2] + item.pend[2]) / 2)
				* vector.angled_cframe({0, item.angle, 0})
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
			angle = math.deg(math.atan2(pend[2] - pstart[2], pend[1] - pstart[1])),
			height = options.height or self.height or 12,
			thickness = options.thickness or self.thickness or 2,
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
			local sections = {item}

			for _, hole in ipairs(item.holes) do
				local target = 0
				for i = 1, #sections do
					-- if sections[i].
				end
			end

			for _, item in ipairs(sections) do
				blueprint:add_part('wall', {item.length, item.height, item.thickness},
					{(item.pstart[1] + item.pend[1]) / 2, item.height / 2, (item.pstart[2] + item.pend[2]) / 2},
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
