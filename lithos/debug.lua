
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




local function print_table(tbl, indent)
	indent = indent or ''
	print(indent .. '{')
	for k,v in pairs(tbl) do
		if type(v) == 'table' then
			print(indent .. '[' .. tostring(k) .. '] = ')
			print_table(v,indent .. '  ')
		else
			print(indent .. '[' .. tostring(k) .. '] = ' .. tostring(v) .. ',')
		end
	end
	print(indent .. '}')
end



return export {
	print_table = print_table,
}
