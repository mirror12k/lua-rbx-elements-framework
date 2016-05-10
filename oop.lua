


-- import 'Stringy'





base_object = {
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
	-- use the functional isa() instead
	_isa = function (self, class)
		local c = self.class
		while c do
			if c == class then return true end
			c = c.super
		end
		return false
	end,
}
base_object.__index = base_object
base_object.__call = base_object._new


function class (definition)
	local parent
	if definition._extends then
		parent = definition._extends
	else
		parent = base_object
	end
	return parent:_subclass(definition)
end

-- returns true if the object is an instance or subclass of the given class
function isa (obj, class)
	if type(obj) == 'table' and type(obj._isa) == 'function' then
		return obj:_isa(class)
	end
	return false
end


-- -- example code

-- testobj = class {}



-- point = class {
-- 	_init = function (self,x,y)
-- 		point.super._init(self)
-- 		self.x = x or 0
-- 		self.y = y or 0
-- 	end,
-- 	__tostring = function (self)
-- 		return '('..tostring(self.x)..','..tostring(self.y)..')'
-- 	end,
-- 	__add = function (self, other)
-- 		return point(self.x + other.x, self.y + other.y)
-- 	end,
-- 	__sub = function (self, other)
-- 		return point(self.x - other.x, self.y - other.y)
-- 	end,
-- 	__mul = function (self, other)
-- 		if isa(other, point) then return point(self.x * other.x, self.y * other.y) end
-- 		return point(self.x * other, self.y * other)
-- 	end,
-- 	__div = function (self, other)
-- 		if isa(other, point) then return point(self.x / other.x, self.y / other.y) end
-- 		return point(self.x / other, self.y / other)
-- 	end,
-- 	__mod = function (self, other)
-- 		return point(self.x % other.x, self.y % other.y)
-- 	end,
-- 	__unm = function (self)
-- 		return point(-self.x, -self.y)
-- 	end,
-- 	__eq = function (self, other)
-- 		return self.x == other.x and self.y == other.y
-- 	end,
-- 	dist = function (self)
-- 		return (self.x ^ 2 + self.y ^ 2) ^ 0.5
-- 	end,
-- 	normal = function (self)
-- 		return self / self:dist()
-- 	end,
-- }




-- superpoint = class {
-- 	_extends = point,
-- 	_init = function (self, ...)
-- 		superpoint.super._init(self, ...)
-- 		self.x = self.x * 10
-- 		self.y = self.y * 10
-- 	end,
-- }




-- p = point(6,8)
-- print('p:', p)

-- p2 = superpoint(5,13)
-- print('p2:', p2)

-- print(p2 - p)
-- print(-p)
-- print(-p == point(-5,-13))
-- print(p:dist())
-- print(p:normal())
-- print(p:normal():dist())








