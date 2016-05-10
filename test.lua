
require('./util')
require('./oop')
require('./stringy')
require('./debug')
require('./math')

print 'hello world!'


-- print(base_object)

-- local C1
-- C1 = class {
-- 	_init = function (self)
-- 		print("hello world! i am alive: " .. tostring(self))
-- 	end,
-- }

-- local C2
-- C2 = class {
-- 	_extends = C1,
-- 	_init = function (self)
-- 		C2.super._init(self)
-- 		print("C2 ready: " .. tostring(self))
-- 	end,
-- }

-- local C3
-- C3 = class {
-- 	_extends = C2,
-- 	_init = function (self)
-- 		C3.super._init(self)
-- 		print("C3 ready: " .. tostring(self))
-- 	end,
-- }

-- local obj = C2.new()
-- print(obj)
-- print(isa(obj, base_object))
-- print(isa(obj, C1))
-- print(isa(obj, C2))
-- print(isa(obj, C3))
-- print(isa(obj, nil))


-- print_table({1, 5, {'a', 'b'}})

-- print(table_to_stringed_table({1, 2, 3, 4, ['asdf'] = 'qwerty'}))
-- print_table(stringed_table_to_table '{[1]=1,[2]=2,[3]=3,[4]=4,["asdf lol"]="qwerty"}')

-- local stk = Stack.new()
-- stk:push('asdf'):push('qwerty'):push(15)
-- print(stk:pop())
-- print(stk:pop())
-- print(stk:pop())
-- print(stk:pop())



-- print_table(list_delta {1, 2, 5, 4, 1, 0})
-- print_table(list_integral {1, 2, 5, 4, 1, 0})
-- print_table(list_delta(list_integral {1, 2, 5, 4, 1, 0}))
-- print_table(list_integral(list_delta {1, 2, 5, 4, 1, 0}))




-- local asdf = class 'asdf' {
-- 	_init = function (self)
-- 		print("asdf is init!")
-- 	end,
-- }

-- local foo = class 'foo' {
-- 	_init = function (self)
-- 		print("foo is init!")
-- 	end,
-- }


-- local obj = new 'asdf' ()
-- print(obj:isa(asdf))
-- print(obj:isa('asdf'))
-- print(obj:isa('oop.base_object'))
-- print(obj:isa('util.Stack'))
-- print(obj:isa('foo'))
-- print(obj:isa('nope'))

-- for k, v in pairs(class_registry) do
-- 	print(k, v)
-- end



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


local tests = new 'test.TestSuite' ('expirements')

print(isa(tests, TestSuite))
tests:test(1, 1)
tests:test(false, true)
tests:test({}, {})
tests:finish()



-- print(compare_tables({}, {}))
-- print(compare_tables({}, {1, 4}))
-- print(compare_tables({1, 2}, {1, 2}))
-- print(compare_tables({1, 'asdf'}, {1, 'asdf'}))
-- print(compare_tables({ {1, 2}, 'asdf', {3, 4}}, { {1, 2}, 'asdf', {3, 4}}))
-- print(compare_tables({ {1, 2}, 'asdf', {3, 5}}, { {1, 2}, 'asdf', {3, 4}}))
-- print(compare_tables({ {1, 2}, 'asdf', {3, 4}}, { {0, 2}, 'asdf', {3, 4}}))








