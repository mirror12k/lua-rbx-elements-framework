
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
import 'hydros/blueprint'


print(export)
print(table_to_stringed_table({1, 'asdf', {key = 5}}))
print(TestSuite)
print(Stack)


local bp = new 'hydros.ModelBlueprint'()
bp:add('test_obj', {})
bp:add('test_obj', {})
bp:add('test_obj', {})

bp:build()
