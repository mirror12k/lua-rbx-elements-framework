
local import
if script ~= nil then
	import = function (name, arg)
		local target = script.Parent
		string.gsub(name, "([^/]+)", function(s) if s == '..' then target = target.Parent else target = target[s] end end)
		return require(target)(arg)
	end
else
	-- mostly taken from https://stackoverflow.com/questions/9145432/load-lua-files-by-relative-path
	local folderOfThisFile = ((...) == nil and './') or (...):match("(.-)[^%/]+$")
	import = function (name, arg) return require(folderOfThisFile .. name)(arg) end
end

import 'module'

function table:append(t)
	for k, v in pairs(t) do
		self[k] = v
	end
end

local exports = {}
table.append(exports, import('debug', 'import_list'))
table.append(exports, import('math', 'import_list'))
table.append(exports, import('oop', 'import_list'))
table.append(exports, import('stringy', 'import_list'))
table.append(exports, import('test', 'import_list'))
table.append(exports, import('util', 'import_list'))

table.append(exports, import('module', 'import_list'))



return export(exports)
