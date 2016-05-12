
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
import 'util'

local exports = {}
table_append(exports, import('debug', 'import_list'))
table_append(exports, import('math', 'import_list'))
table_append(exports, import('oop', 'import_list'))
table_append(exports, import('stringy', 'import_list'))
table_append(exports, import('test', 'import_list'))
table_append(exports, import('util', 'import_list'))

table_append(exports, import('module', 'import_list'))



return export(exports)
