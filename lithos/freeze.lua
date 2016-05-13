
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

import 'module'
import 'oop'
import 'stringy'


local function freeze (obj)
	local metatable = getmetatable(obj)
	local s = table_to_stringed_table(setmetatable(obj, nil))
	setmetatable(obj, metatable)
	return metatable.class_name .. ':' .. s
end

local function thaw (s)
	local offset = string.find(s, ':')
	local class_name = string.sub(s, 1, offset - 1)
	s = string.sub(s, offset + 1)
	return class_by_name(class_name).bless(stringed_table_to_table(s))
end


return export {
	freeze = freeze,
	thaw = thaw,
}
