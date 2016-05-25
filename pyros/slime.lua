
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


local SlimeBlueprint
SlimeBlueprint = class 'pyros.SlimeBlueprint' {
	_extends = 'hydros.ModelBlueprint',

	_init = function (self, size, color, name)
		SlimeBlueprint.super._init(self, name)
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
	end,
}



return export {
	
}
