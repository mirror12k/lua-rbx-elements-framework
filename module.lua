




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
end


function export(export_list)
	local this
	this = function ()
		local env = getfenv(this)
		for k, v in pairs(export_list) do
			env[k] = v
		end
	end
	return this
end

return export({ export = export, lol = 'test' })
