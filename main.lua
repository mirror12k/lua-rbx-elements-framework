
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


-- import 'lithos/util'
-- import 'lithos/stringy'
-- import 'lithos/test'

import 'lithos/lithos'
-- import 'lithos/../lithos/lithos'
import 'hydros/hydros'


-- print(export)
-- print(table_to_stringed_table({1, 'asdf', {key = 5}}))
-- print(TestSuite)
-- print(Stack)


local bp = new 'hydros.ModelBlueprint' ('test_model')
bp:add('part', {
	name = 'testpart',
	size = {10, 20, 30},
})

local m = new 'hydros.ModelBlueprint' ('sub_model')

m:add('part', {
	name = 'part1',
	size = {5, 100, 5},
	position = {0, 50, 10},
	rotation = {-45, 0, 0},
	anchored = false,
})
m:add('part', {
	name = 'special_part',
	size = {5, 50, 5},
	position = {0, 25, -10},
	rotation = {45, 0, 0},
	anchored = false,
})

m:add('weld', {
	p0 = 'part1',
	p1 = 'special_part',
})

m:add('value', {
	type = 'String',
	value = 'hello world!',
})

bp:add('model', { model = m, name = 'sm' })
bp:add('model', { model = m, position = {20, 0, 0}, })
bp:add('model', { model = m, position = {-20, 0, 0}, })

bp:add('weld', {
	p0 = 'testpart',
	p1 = 'sm.special_part',
})


bp:build().Parent = workspace
