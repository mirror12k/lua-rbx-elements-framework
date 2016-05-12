


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



return export {
	export = export,
}
