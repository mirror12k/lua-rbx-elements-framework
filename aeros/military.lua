
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




local ConcreteBarrierBlueprint
ConcreteBarrierBlueprint = class 'aeros.ConcreteBarrierBlueprint' {
	_extends = class_by_name 'aeros.RoomBlueprint',

	compile_functions = table_append({
		wall = function (self, blueprint, item, options)
			blueprint:add_part('wall', {item.length, item.height, item.thickness},
				{ (item.pend[1] + item.pstart[1]) / 2, item.height / 2, (item.pend[2] + item.pstart[2]) / 2 },
				{0, item.angle, 0},
				{
					surface = Enum.SurfaceType.SmoothNoOutlines,
				})
		end,
	}, class_by_name 'hydros.CompiledBlueprint' .compile_functions),
}


return export {}
