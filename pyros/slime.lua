
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
				timeout(function ()
					other:Destroy()
				end, 5)
			end
		end
	end,
}



local SlimeBlueprint
SlimeBlueprint = class 'pyros.SlimeBlueprint' {
	_extends = 'hydros.ModelBlueprint',

	_init = function (self, size, color, name)
		SlimeBlueprint.super._init(self, name)
		self.size = size
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
		return m
	end,
}



return export {
	
}
