
require('oop')

print 'hello world!'
print(base_object)

local C1
C1 = class {
	_init = function (self)
		print("hello world! i am alive: " .. tostring(self))
	end,
}

local C2
C2 = class {
	_extends = C1,
	_init = function (self)
		C2.super._init(self)
		print("C2 ready: " .. tostring(self))
	end,
}

local C3
C3 = class {
	_extends = C2,
	_init = function (self)
		C3.super._init(self)
		print("C3 ready: " .. tostring(self))
	end,
}

local obj = C2.new()
print(obj)
print(isa(obj, base_object))
print(isa(obj, C1))
print(isa(obj, C2))
print(isa(obj, C3))
print(isa(obj, nil))

