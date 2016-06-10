
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


local function cw(fun, ...)
	return coroutine.wrap(fun)(...)
end

local function cww(fun)
	return function (...)
		return cw(fun, ...)
	end
end

local function timeout_run(fun, delay, ...)
	wait(delay)
	fun(...)
end

local function timeout(fun, delay, ...)
	return coroutine.wrap(timeout_run)(fun, delay, ...)
end


local function interval_run(fun, delay, times, ...)
	for i = 1, times do
		wait(delay)
		fun(...)
	end
end

local function interval(fun, delay, times, ...)
	return coroutine.wrap(interval_run)(fun, delay, times, ...)
end


return export {
	cw = cw,
	cww = cww,
	timeout = timeout,
	interval = interval,
}
