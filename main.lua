
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


print(export)
print(table_to_stringed_table({1, 'asdf', {key = 5}}))
print(TestSuite)
print(Stack)


local bp = new 'hydros.ModelBlueprint'()
bp:add('part', {
	name = 'testpart',
	size = {10, 20, 30},	
})
bp:add('part', {
	size = {5, 5, 5},
	position = {0, 12.5, 0},	
})
bp:add('part', {
	size = {5, 100, 5},
	position = {0, 50, 0},
	rotation = {45, 0, 0},	
})

bp:build().Parent = workspace
