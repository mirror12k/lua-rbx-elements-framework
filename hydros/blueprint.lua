
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


class 'hydros.Blueprint' {
	_init = function (self, name)
		self.name = name or 'Model'
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



class 'hydros.ModelBlueprint' {
	_extends = 'hydros.Blueprint',
	build_self = function (self, opts)
		print("build self")
		return 'lol'
	end,
	build_functions = {
		test_obj = function (self, model, item, opts)
			print("build test_obj in model: ", model)
		end,
	},
}





return export {}
