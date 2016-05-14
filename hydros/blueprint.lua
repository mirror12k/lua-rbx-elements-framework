
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
		options = options or {}
		local obj = self:build_self(options)
		for _, item in ipairs(self.items) do
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
	_blessed_init = function (self)
		for _,item in ipairs(self.items) do
			if item[1] == 'model' then
				ModelBlueprint.bless(item[2].model)
			end
		end
	end,

	build_self = function (self, opts)
		return block.model(self.name)
	end,
	add_part = function (self, name, size, position, rotation, opts)
		local obj = {
			name = name,
			size = size,
			position = position,
			rotation = rotation,
		}
		if opts ~= nil then
			for k, v in pairs(opts) do
				obj[k] = v
			end
		end
		return self:add('part', obj)
	end,
	add_model = function (self, name, model, opts)
		local obj = {
			name = name,
			model = model,
		}
		if opts ~= nil then
			for k, v in pairs(opts) do
				obj[k] = v
			end
		end
		return self:add('model', obj)
	end,
	add_weld = function (self, p0, p1, name)
		if type(p1) == 'string' then
			return self:add('weld', {
				p0 = p0,
				p1 = p1,
				name = name,
			})
		else
			for _, p in ipairs(p1) do
				self:add_weld(p0, p, name)
			end
			return self
		end
	end,
	add_value = function (self, name, type, value)
		return self:add('value', {
			name = name,
			type = type,
			value = value,
		})
	end,
	build_functions = {
		part = function (self, model, item, opts)
			-- figure out its cframe
			local cf = opts.cframe or CFrame.new()
			if item.position ~= nil then cf = cf * CFrame.new(item.position[1], item.position[2], item.position[3]) end
			if item.rotation ~= nil then cf = cf * vector.angled_cframe(item.rotation) end

			-- create it
			local p = block.block_from_cframe(item.name, item.size, cf)
			p.Parent = model

			-- additional properties as necessary
			if item.color ~= nil then p.BrickColor = BrickColor.new(vector.table_to_color3(item.color)) end
			if item.shape ~= nil then p.Shape = item.shape end
			if item.anchored ~= nil then p.Anchored = item.anchored end
			if item.cancollide ~= nil then p.CanCollide = item.cancollide end
			if item.friction ~= nil then p.Friction = item.friction end
			if item.transparency ~= nil then p.Transparency = item.transparency end
			if item.surface ~= nil then
				p.TopSurface = item.surface
				p.BottomSurface = item.surface
				p.FrontSurface = item.surface
				p.BackSurface = item.surface
				p.LeftSurface = item.surface
				p.RightSurface = item.surface
			end

			return p
		end,
		value = function (self, model, item, opts)
			local v = block.value(item.name, item.type, item.value)
			v.Parent = model
			return v
		end,
		weld = function (self, model, item, opts)
			local p0, p1 = model, model
			for _,a in ipairs(split(item.p0, '.')) do p0 = p0[a] end
			for _,a in ipairs(split(item.p1, '.')) do p1 = p1[a] end
			
			if p0 == nil or p1 == nil then
				error("attempt to weld non-existant parts: '"..item.p0.."' and '"..item.p1.."'")
			else
				local w = block.weld(p0, p1, item.name)
				w.Parent = p0
				return w
			end
		end,
		hinge = function (self, model, item, opts)
			local p0, p1 = model, model
			for _,a in ipairs(split(item.p0, '.')) do p0 = p0[a] end
			for _,a in ipairs(split(item.p1, '.')) do p1 = p1[a] end
			
			if p0 == nil or p1 == nil then
				error("attempt to hinge non-existant parts: '"..item.p0.."' and '"..item.p1.."'")
			else
				local w = block.hinge(p0, p1, item.name, item.hinge_type)
				w.Parent = p0
				return w
			end
		end,
		model = function (self, model, item, opts)
			local sub_opts = table_copy(opts)
			sub_opts.cframe = sub_opts.cframe or CFrame.new()
			if item.position ~= nil then sub_opts.cframe = sub_opts.cframe * CFrame.new(item.position[1], item.position[2], item.position[3]) end
			if item.rotation ~= nil then sub_opts.cframe = sub_opts.cframe * vector.angled_cframe(item.rotation) end

			local res = item.model:build(sub_opts)
			if item.name ~= nil then res.Name = item.name end
			res.Parent = model
			return res
		end,
	},


	-- static method meant to be used to create
	generate_from_model = function (self, model)
		local bp = self.new(model.Name)
		for _,v in pairs(model:GetChildren()) do
			if v:IsA('Part') then
				local opts = {
					color = vector.color3_to_table(v.BrickColor.Color),
					anchored = v.Anchored,
					cancollide = v.CanCollide,
				}
				if v.Transparency ~= 0 then opts.transparency = v.Transparency end
				if 
						v.TopSurface == v.BottomSurface and
						v.TopSurface == v.FrontSurface and
						v.TopSurface == v.BackSurface and
						v.TopSurface == v.LeftSurface and
						v.TopSurface == v.RightSurface and
						v.TopSurface ~= Enum.SurfaceType.Smooth
						then
					opts.surface = v.TopSurface.Value
				end
				bp:add_part(v.Name, vector.vector3_to_table(v.Size), vector.vector3_to_table(v.Position), vector.vector3_to_table(v.Rotation), opts)
			elseif v:IsA('Model') then
				bp:add_model(nil, self:generate_from_model(v))
			end
		end

		-- second pass for welds
		for _,v in pairs(model:GetChildren()) do
			for _, subv in pairs(v:GetChildren()) do
				if subv:IsA('Weld') then
					local p0 = v.Name
					local p1 = subv.Part1.Name

					local iterp = subv.Part1.Parent
					while iterp ~= model do
						p1 = iterp.Name .. '.' .. p1
						iterp = iterp.Parent
					end
					bp:add_weld(p0, p1)
				end
			end
		end
		return bp

	end,
}



local CompiledBlueprint
CompiledBlueprint = class 'hydros.CompiledBlueprint' {
	_extends = 'hydros.ModelBlueprint',

	compile_self = function (self, options)
		return new 'hydros.ModelBlueprint' (self.name)
	end,
	-- syntactic sugar for when calling :compile is a hassle
	build = function (self, options)
		local bp = self:compile()
		return bp:build(options)
	end,
	-- compiles all items inside of it to a new blueprint
	-- any items that don't have an associated compile function will be simply :add'd to the resulting blueprint
	compile = function (self, options)
		options = options or {}
		local obj = self:compile_self(options)
		for _, item in ipairs(self.items) do
			if self.compile_functions[item[1]] ~= nil then
				self.compile_functions[item[1]](self, obj, item[2], options)
			else
				obj:add(item[1], item[2])
			end
		end
		return obj
	end,
	-- adds a blueprint to the items which will be compiled during compile time
	-- the result will be added as a model
	-- blueprints that shouldn't be compiled must be added with add_model
	add_blueprint = function (self, blueprint, name, opts)
		return self:add('blueprint', {
			blueprint = blueprint,
			name = name,
			opts = opts,
		})
	end,


	-- the compile functions for items by name
	compile_functions = {
		-- compile function to compile a sub-blueprint
		blueprint = function (self, bp, item, options)
			bp:add_model(item.name, item.blueprint:compile(), item.opts)
		end,
	},
}




return export {}
