
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



-- borrowed from some internet page
local function isINF(v)
  return v == math.huge or v == -math.huge
end
-- this too
local function isNAN(v)
  return v ~= v
end



-- returns each element subtracted from the next, effectively taking the dx/dy of a data set
-- inverse opperation of list_integral
local function list_delta(list)
	local l = {}
	l[1] = list[1]
	for i = 2,#list do
		l[i] = list[i] - list[i-1]
	end
	return l
end


-- returns each element add to the next, effectively taking the integral of a data set
-- inverse opperation of list_delta
local function list_integral(list)
	local l = {}
	l[1] = list[1]
	for i = 2,#list do
		l[i] = list[i] + l[i-1]
	end
	return l
end

return export {
	isINF = isINF,
	isNAN = isNAN,
	list_delta = list_delta,
	list_integral = list_integral,
}
