
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
	_extends = class_by_name 'hydros.ModelBlueprint',

	add_street = function (self, pstart, pend, opts)
		opts = opts or {}
		self:add('street', {
			pstart = pstart,
			pend = pend,
			length = math.sqrt(math.abs(pstart[1] - pend[1])^2 + math.abs(pstart[2] - pend[2])^2),
			width = opts.width or 50,
			thickness = opts.thickness or 2,
			sidewalk_width = opts.sidewalk_width or 8,
			sidewalk_elevation = opts.sidewalk_elevation or 1,
			name = opts.name,
		})
	end,
	compile_functions = {
		street = function (self, item, options)
			local angle = math.deg(math.atan2(item.pend[2] - item.pstart[2], item.pend[1] - item.pstart[1]))
			self:add_part('pavement', {item.length, item.thickness, item.width},
				{(item.pstart[1] + item.pend[1]) / 2, - item.thickness / 2, (item.pstart[2] + item.pend[2]) / 2},
				{0, angle, 0},
				{
					color = {0, 0, 0},
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
			local sidewalk_cframe = CFrame.new((item.pstart[1] + item.pend[1]) / 2, item.sidewalk_elevation - item.thickness / 2, (item.pstart[2] + item.pend[2]) / 2)
				* vector.angled_cframe({0, angle, 0})
			self:add_part('sidewalk', {item.length, item.thickness, item.sidewalk_width},
				vector.vector3_to_table((sidewalk_cframe * CFrame.new(0, 0, item.width / 2 + item.sidewalk_width / 2)).p),
				{0, angle, 0},
				{
					color = {0.5, 0.5, 0.5},
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
			self:add_part('sidewalk', {item.length, item.thickness, item.sidewalk_width},
				vector.vector3_to_table((sidewalk_cframe * CFrame.new(0, 0, - (item.width / 2 + item.sidewalk_width / 2))).p),
				{0, angle, 0},
				{
					color = {0.5, 0.5, 0.5},
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
		end,
	}
}



return export {}
