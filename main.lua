
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



import 'lithos/lithos'
import 'hydros/hydros'




local bp = new 'hydros.ModelBlueprint' ('test_model')
bp:add_part('testpart', {10, 20, 30})

local m = new 'hydros.ModelBlueprint' ('sub_model')

m:add_part('part1', {5, 100, 5}, {0, 50, 10}, {-45, 0, 0}, { anchored = false, })
m:add_part('part2', {5, 50, 5}, {0, 25, -10}, {45, 0, 0}, { anchored = false, })

m:add_weld('part1', 'part2')

m:add_value('myval', 'String', 'hello world!')

bp:add_model('center_model', m)
bp:add_model('sm1', m, { position = {70, 0, 0}, rotation = {0, 0, 45}, })
bp:add_model('sm2', m, { position = {-70, 0, 0}, rotation = {0, 0, -45}, })

bp:add_weld('testpart', qw' center_model.part2 sm1.part1 sm2.part1')


bp:build().Parent = workspace


local cf = CFrame.new(50, 50, 50)
local cf2 = cf * vector.angled_cframe({0, 45, 0}) * CFrame.new(20, 0, 0)

draw.cframe(cf)
draw.cframe(cf2)

draw.line(Vector3.new(), cf.p)
draw.line(Vector3.new(), cf2.p)
