
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
import 'oop'

local Stack
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
local function iter_table(t)
	local i = 0
	local n = table.getn(t)
	return function ()
		i = i + 1
		if i <= n then return t[i] end
	end
end




-- performs shallow copy of table
local function copy_table(t)
	local tc = {}
	for k,v in pairs(t) do
		tc[k] = v
	end
	return tc
end

-- performs deep copies of tables
-- oblivious to recursive tables, metatables, and none-primitive keys
local function deep_copy_table(t)
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
local function qw (s)
	local result = {}
	for substr in string.gmatch(s, "%S+") do
		result[#result + 1] = substr
	end
	return result
end




function compare_tables(t1, t2)
	for k, v in pairs(t1) do
		if v ~= t2[k] then
			if type(v) == 'table' and type(t2[k]) == 'table' then
				if compare_tables(v, t2[k]) == false then
					return false
				end
			else
				return false
			end
		end
	end
	for k, v in pairs(t2) do
		if v ~= t1[k] then
			if type(v) == 'table' and type(t1[k]) == 'table' then
				if compare_tables(v, t1[k]) == false then
					return false
				end
			else
				return false
			end
		end
	end
	return true
end



return export {
	Stack = Stack,
	iter_table = iter_table,
	copy_table = copy_table,
	deep_copy_table = deep_copy_table,
	qw = qw,
	compare_tables = compare_tables,
}

