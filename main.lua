
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


-- print(freeze(bp))

local bp2 = thaw'hydros.ModelBlueprint:{["name"]="test_model",["items"]={[1]={[1]="part",[2]={["size"]={[1]=10,[2]=20,[3]=30},["name"]="testpart"}},[2]={[1]="model",[2]={["model"]={["name"]="sub_model",["items"]={[1]={[1]="part",[2]={["position"]={[1]=0,[2]=50,[3]=10},["name"]="part1",["anchored"]=false,["rotation"]={[1]=-45,[2]=0,[3]=0},["size"]={[1]=5,[2]=100,[3]=5}}},[2]={[1]="part",[2]={["position"]={[1]=0,[2]=25,[3]=-10},["name"]="part2",["anchored"]=false,["rotation"]={[1]=45,[2]=0,[3]=0},["size"]={[1]=5,[2]=50,[3]=5}}},[3]={[1]="weld",[2]={["p1"]="part2",["p0"]="part1"}},[4]={[1]="value",[2]={["type"]="String",["value"]="hello world!",["name"]="myval"}}}},["name"]="center_model"}},[3]={[1]="model",[2]={["position"]={[1]=70,[2]=0,[3]=0},["model"]={["name"]="sub_model",["items"]={[1]={[1]="part",[2]={["position"]={[1]=0,[2]=50,[3]=10},["name"]="part1",["anchored"]=false,["rotation"]={[1]=-45,[2]=0,[3]=0},["size"]={[1]=5,[2]=100,[3]=5}}},[2]={[1]="part",[2]={["position"]={[1]=0,[2]=25,[3]=-10},["name"]="part2",["anchored"]=false,["rotation"]={[1]=45,[2]=0,[3]=0},["size"]={[1]=5,[2]=50,[3]=5}}},[3]={[1]="weld",[2]={["p1"]="part2",["p0"]="part1"}},[4]={[1]="value",[2]={["type"]="String",["value"]="hello world!",["name"]="myval"}}}},["rotation"]={[1]=0,[2]=0,[3]=45},["name"]="sm1"}},[4]={[1]="model",[2]={["position"]={[1]=-70,[2]=0,[3]=0},["model"]={["name"]="sub_model",["items"]={[1]={[1]="part",[2]={["position"]={[1]=0,[2]=50,[3]=10},["name"]="part1",["anchored"]=false,["rotation"]={[1]=-45,[2]=0,[3]=0},["size"]={[1]=5,[2]=100,[3]=5}}},[2]={[1]="part",[2]={["position"]={[1]=0,[2]=25,[3]=-10},["name"]="part2",["anchored"]=false,["rotation"]={[1]=45,[2]=0,[3]=0},["size"]={[1]=5,[2]=50,[3]=5}}},[3]={[1]="weld",[2]={["p1"]="part2",["p0"]="part1"}},[4]={[1]="value",[2]={["type"]="String",["value"]="hello world!",["name"]="myval"}}}},["rotation"]={[1]=0,[2]=0,[3]=-45},["name"]="sm2"}},[5]={[1]="weld",[2]={["p1"]="center_model.part2",["p0"]="testpart"}},[6]={[1]="weld",[2]={["p1"]="sm1.part1",["p0"]="testpart"}},[7]={[1]="weld",[2]={["p1"]="sm2.part1",["p0"]="testpart"}}}}'

print (bp2)

bp2:build().Parent = workspace


-- local cf = CFrame.new(50, 50, 50)
-- local cf2 = cf * vector.angled_cframe({0, 45, 0}) * CFrame.new(20, 0, 0)

-- draw.cframe(cf)
-- draw.cframe(cf2)

-- draw.line(Vector3.new(), cf.p)
-- draw.line(Vector3.new(), cf2.p)
