
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
			-- figure out its cframe
			local cf = opts.cframe
			if item.position ~= nil then cf = cf * CFrame.new(item.position[1], item.position[2], item.position[3]) end
			if item.rotation ~= nil then cf = cf * vector.angled_cframe(item.rotation) end

			-- create it
			local p = block.block_from_cframe(item.name, item.size, cf)
			p.Parent = model

			-- additional properties as necessary
			if item.color then p.BrickColor = BrickColor.new(table_to_color3(item.color)) end
			if item.shape then p.Shape = item.shape end
			if item.anchored then p.Anchored = item.anchored end
			if item.cancollide then p.CanCollide = item.cancollide end
			if item.friction then p.Friction = item.friction end
			if item.transparency then p.Transparency = item.transparency end
			if item.surface then
				p.TopSurface = item.surface
				p.BottomSurface = item.surface
				p.FrontSurface = item.surface
				p.BackSurface = item.surface
				p.LeftSurface = item.surface
				p.RightSurface = item.surface
			end

			return p
		end,
		model = function (self, model, item, opts)
			local sub_opts = table_copy(opts)
			if item.position ~= nil then sub_opts.cframe = sub_opts.cframe * CFrame.new(item.position[1], item.position[2], item.position[3]) end
			if item.rotation ~= nil then sub_opts.cframe = sub_opts.cframe * vector.angled_cframe(item.rotation) end

			local res = item.model:build(sub_opts)
			res.Parent = model
			return res
		end,
	},
}





return export {}
