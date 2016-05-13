
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

import 'vector'
import 'block'

local Blueprint
Blueprint = class 'hydros.Blueprint' {
	_init = function (self)
		self.items = {}
	end,
	add = function (self, type, item)
		self.items[#self.items + 1] = { type, item }
		return self
	end,
	build = function (self, options)
		local obj = self:build_self(options)
		for _, item in pairs(self.items) do
			self.build_functions[item[1]](self, obj, item[2], options)
		end
		return obj
	end,
	build_functions = {},
}


local ModelBlueprint
ModelBlueprint = class 'hydros.ModelBlueprint' {
	_extends = 'hydros.Blueprint',
	_init = function (self, name)
		ModelBlueprint.super._init(self)
		self.name = name or 'Model'
	end,
	build_self = function (self, opts)
		return block.model(self.name)
	end,
	build = function (self, opts)
		opts = opts or {}
		opts.cframe = opts.cframe or CFrame.new()
		return ModelBlueprint.super.build(self, opts)
	end,
	build_functions = {
		part = function (self, model, item, opts)
			local cf = opts.cframe
			if item.position ~= nil then cf = cf * CFrame.new(item.position[1], item.position[2], item.position[3]) end
			if item.rotation ~= nil then cf = cf * vector.angled_cframe(item.rotation) end

			local p = block.block_from_cframe(item.name, item.size, cf)
			p.Parent = model
			return p
		end,
	},
}





return export {}
