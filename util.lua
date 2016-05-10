

require('./oop')


Stack = class {
	_init = function (self)
		Stack.super._init(self)
		self.length = 0
	end,
	push = function (self, item)
		self.length = self.length + 1
		self[self.length] = item
		return self
	end,
	pop = function (self)
		if self.length == 0 then
			error('attempt to pop an empty list')
		end
		local item = self[self.length]
		self[self.length] = nil
		self.length = self.length - 1
		return item
	end,
	peek = function (self)
		return self[self.length]
	end,
	
}

