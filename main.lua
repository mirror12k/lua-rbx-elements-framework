
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




import 'lithos/util'
import 'lithos/stringy'
import 'lithos/test'

print(export)
print(table_to_stringed_table({1, 'asdf', {key = 5}}))
print(TestSuite)


