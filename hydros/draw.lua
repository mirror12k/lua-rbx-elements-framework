
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



import '../lithos/lithos'
import 'vector'
import 'block'
import 'blueprint'

local draw = {}

function draw.cframe(cframe, name, parent)
	local blueprint = new 'hydros.ModelBlueprint' (name or 'cframe')
	blueprint:add_part('point', {0.4, 0.4, 0.4}, nil, nil, { color = {1,1,1} })
	blueprint:add_part('x', {10, 0.2, 0.2}, {5, 0, 0}, nil, { color = {1,0,0} })
	blueprint:add_part('y', {0.2, 10, 0.2}, {0, 5, 0}, nil, { color = {0,1,0} })
	blueprint:add_part('z', {0.2, 0.2, 10}, {0, 0, 5}, nil, { color = {0,0,1} })
	blueprint:add_part('nx', {10, 0.2, 0.2}, {-5, 0, 0}, nil, { color = {1,0,1} })
	blueprint:add_part('ny', {0.2, 10, 0.2}, {0, -5, 0}, nil, { color = {1,1,0} })
	blueprint:add_part('nz', {0.2, 0.2, 10}, {0, 0, -5}, nil, { color = {0,1,1} })
	blueprint:add_weld('point', qw' x y z nx ny nz ')
	local m = blueprint:build({ cframe = cframe })
	m.Parent = parent or workspace
	return m
end


function draw.line(vec1, vec2, color, parent)
	local distance = (vec1 - vec2).magnitude
	local p = block.block_from_cframe('line', {distance, 0.2, 0.2}, CFrame.new(vec1) * vector.directional_offset_cframe(vec2 - vec1, distance/2))
	p.Parent = parent or workspace
	if color then p.BrickColor = BrickColor.new(vector.table_to_color3(color)) end
	return p
end

return export {
	draw = draw,
}
