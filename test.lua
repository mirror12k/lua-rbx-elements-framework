
if script ~= nil then
	function import (name)
		local target = script.Parent
		string.gsub(name, "([^/]+)", function(s) target = target[s] end)
		require(target)()
	end
else
	function import (name) require('./' .. name)() end
end


require('./util')
require('./oop')
require('./stringy')
require('./debug')
require('./math')
-- print(require('./module'))
import 'module'

print(export)
print(lol)

print 'hello world!'







function compare_tables(t1, t2)
	for k, v in ipairs(t1) do
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
	for k, v in ipairs(t2) do
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


TestSuite = class 'test.TestSuite' {
	_init = function (self, name)
		self.results = {}
		self.failed = false
		self.name = name or "test suite"
	end,
	result = function (self, result)
		self.results[#self.results + 1] = result

		if not result then
			self.failed = true
			print("test #" .. tostring(#self.results) .. " failed of " .. self.name)
		end
		return result
	end,
	compare = function (self, val1, val2)
		if val1 == val2 then
			return true
		elseif type(val1) == 'table' and type(val2) == 'table' then
			return compare_tables(val1, val2)
		else
			return false
		end
	end,
	test = function (self, val1, val2)
		return self:result(self:compare(val1, val2))
	end,
	count_failed = function (self)
		local failed = 0
		for i, v in ipairs(self.results) do
			if not v then
				failed = failed + 1
			end
		end
		return failed
	end,
	is_successful = function (self)
		return not self.failed
	end,
	finish = function (self)
		print(tostring(#self.results - self:count_failed()) .. "/" .. tostring(#self.results) .. " successful of " .. self.name)
	end,
}




-- local tests = new 'test.TestSuite' ('stringy tests')

-- tests:test(stringed_table_to_table(table_to_stringed_table({15, 13, 11})), {15, 13, 11})
-- tests:test(stringed_table_to_table(table_to_stringed_table({15, 13, 11, ['foo'] = 'asdf', ['bar'] = 'qwerty'})), {15, 13, 11, ['foo'] = 'asdf', ['bar'] = 'qwerty'})
-- tests:test(stringed_table_to_table(table_to_stringed_table({{15, 13, 11, ['foo'] = 'asdf', ['bar'] = 'qwerty'}, {15, 13, 11, ['foo'] = 'asdf', ['bar'] = 'qwerty'}})),
-- 		{{15, 13, 11, ['foo'] = 'asdf', ['bar'] = 'qwerty'}, {15, 13, 11, ['foo'] = 'asdf', ['bar'] = 'qwerty'}})
-- tests:test(stringed_table_to_table(table_to_stringed_table({['as df'] = {15, 13, 11, ['foo'] = 'asdf', ['bar'] = 'qwerty'},
-- 		['nope lol what'] = {15, 13, 11, ['foo'] = 'asdf', ['bar'] = 'qwerty'}})),
-- 		{['as df'] = {15, 13, 11, ['foo'] = 'asdf', ['bar'] = 'qwerty'},
-- 		['nope lol what'] = {15, 13, 11, ['foo'] = 'asdf', ['bar'] = 'qwerty'}})

-- tests:finish()






