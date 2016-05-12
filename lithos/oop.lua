
local import
if script ~= nil then
	import = function (name)
		local target = script.Parent
		string.gsub(name, "([^/]+)", function(s) if s == '..' then target = target.Parent else target = target[s] end end)
		require(target)()
	end
else
	-- mostly taken from https://stackoverflow.com/questions/9145432/load-lua-files-by-relative-path
	local folderOfThisFile = ((...) == nil and './') or (...):match("(.-)[^%/]+$")
	import = function (name) require(folderOfThisFile .. name)() end
end

import 'module'
-- import 'stringy'



--[[
	to call super methods, refer to your own class and index .super (do not use self.super, it will be misleading)
]]

local class_registry = {}

local base_object = {
	-- internal function which blesses a new instance of an object
	-- don't call this, call 'bless' instead which is a non-objective alias of _bless
	_bless = function (self, t, ...)
		setmetatable(t, self):_blessed_init(...)
		return t
	end,
	-- overridable constructor function
	-- should invoke super's _init as well
	_init = function (self)
	end,
	-- overridable constructor function for tables that suddenly became an instance of this object
	-- (typically from being deserialized)
	_blessed_init = function (self)
	end,
	-- overridable static contructor that is called when a class is initialized
	-- useful for setting static class values and attributes
	_static_init = function (self)
	end,
	
	-- internal function which creates a new instance of an object
	-- don't call this, call 'new' instead which is a non-objective alias of _new
	_new = function (self, ...)
		local t = {}
		setmetatable(t, self):_init(...)
		return t
	end,
	_freeze = function (self)
		local metatable = getmetatable(self)
		local s = table_to_stringed_table(setmetatable(self, nil))
		setmetatable(self, metatable)
		return s
	end,
	freeze = function (self)
		return self:_freeze()
	end,
	_unfreeze = function (self, s)
		return self:_bless(stringed_table_to_table(s))
	end,
	-- internal function which creates a special instance of the class which is it's own class
	_subclass = function (self, class)
		-- this is to avoid looking up the static init method from parents
		local static_init = class._static_init

		-- set the important stuff
		class.super = self
		class.class = class
		class.__index = class
		setmetatable(class, self)
		-- lookup inherited metamethods
		class.__tostring = class.__tostring
		class.__call = class.__call
		class.__add = class.__add
		class.__sub = class.__sub
		class.__mul = class.__mul
		class.__div = class.__div
		class.__mod = class.__mod
		class.__unm = class.__unm
		class.__concat = class.__concat
		class.__eq = class.__eq
		class.__lt = class.__lt
		class.__le = class.__le
		
		-- add some convenience methods
		class.new = function (...)
			return class:_new(...)
		end
		class.bless = function (...)
			return class:_bless(...)
		end
		class.unfreeze = function (...)
			return class:_unfreeze(...)
		end

		-- invoke static initializer if there is one
		if static_init then static_init(class) end		
		
		return class
	end,
	-- internal function which returns true if this object is an instance of the given class or superclass
	-- use the functional or oop isa() instead
	_isa = function (self, class)
		if type(class) == 'string' then
			if class_registry[class] == nil then
				error("attempt to isa non-existent class '" .. class .. "'")
			end
			return self:_isa(class_registry[class])
		else
			local c = self.class
			while c do
				if c == class then return true end
				c = c.super
			end
			return false
		end
	end,
	-- in case the functional isa() isn't comfortable to use
	isa = function (self, class)
		return self:_isa(class)
	end,
}
base_object.__index = base_object
-- new is better
-- base_object.__call = base_object._new



class_registry['oop.base_object'] = base_object

-- instantiates a new class definition
local function class (definition)
	if type(definition) == 'table' then
		local parent = definition._extends or base_object
		return parent:_subclass(definition)
	else
		if class_registry[definition] ~= nil then
			error("class name '" .. definition .. "' already registered")
		end
		return function (true_def)
				local created_class = class(true_def)
				class_registry[definition] = created_class
				return created_class
			end
	end
end

-- returns true if the object is an instance or subclass of the given class
local function isa (obj, class)
	if type(obj) == 'table' and type(obj._isa) == 'function' then
		return obj:_isa(class)
	end
	return false
end

-- instantiates a new class by name alone from the class registry
local function new (class_name)
	if class_registry[class_name] == nil then
		error("attempt to instantiate non-existent class '" .. class_name .. "'")
	end
	return function (...)
			return class_registry[class_name].new(...)
		end
end





return export {
	class = class,
	isa = isa,
	new = new,
}



