
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

import 'util'
import 'oop'
import 'stringy'
import 'debug'
import 'math'






local TestSuite
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





return export {
	TestSuite = TestSuite,
}
