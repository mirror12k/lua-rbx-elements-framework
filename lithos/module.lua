
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


local export

-- lua 5.2 dropped getfenv
-- this is a workaround using the debug library
-- if roblox switches over to 5.2, i'll have to go with loadstring, or a pre-processor
-- taken from somewhere on stackoverflow
if getfenv == nil then
	function findenv(f)
		local level = 1
		repeat
			local name, value = debug.getupvalue(f, level)
			if name == '_ENV' then return level, value end
			level = level + 1
		until name == nil
	return nil end

	function getfenv (f) return(select(2, findenv(f)) or _G) end

	export = function (export_list)
		local this
		this = function (opt)
			if opt == nil then
				local env = getfenv(this)
				for k, v in pairs(export_list) do
					env[k] = v
				end
			elseif opt == 'import_list' then
				return export_list
			end
		end
		return this
	end
else
	export = function (export_list)
		local this
		this = function (opt)
			if opt == nil then
				local env = getfenv(0)
				for k, v in pairs(export_list) do
					env[k] = v
				end
			elseif opt == 'import_list' then
				return export_list
			end
		end
		return this
	end
end



function re_export (import_function, modules_list)
	local exports = {}
	for _, module_name in ipairs(modules_list) do
		for k, v in pairs(import_function(module_name, 'import_list')) do
			exports[k] = v
		end
	end
	return export (exports)
end


return export {
	export = export,
	re_export = re_export,
}
