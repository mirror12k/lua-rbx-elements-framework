
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
