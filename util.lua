

require('./oop')


Stack = class 'util.Stack' {
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




-- borrowed from some programming lua book
function iter_table(t)
	local i = 0
	local n = table.getn(t)
	return function ()
		i = i + 1
		if i <= n then return t[i] end
	end
end




-- performs shallow copy of table
function copy_table(t)
	local tc = {}
	for k,v in pairs(t) do
		tc[k] = v
	end
	return tc
end

-- performs deep copies of tables
-- oblivious to recursive tables, metatables, and none-primitive keys
function deep_copy_table(t)
	local tc = {}
	for k,v in pairs(t) do
		if type(v) == 'table' then
			tc[k] = deep_copy_table(v)
		else
			tc[k] = v
		end
	end
	return tc
end

-- whitespace-quoted words
-- splits a string of words on their whitespace and returns a list
function qw (s)
	local result = {}
	for substr in string.gmatch(s, "%S+") do
		result[#result + 1] = substr
	end
	return result
end




