
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




local function angled_cframe(rotation)
	return CFrame.Angles(math.rad(rotation[1]), math.rad(rotation[2]), math.rad(rotation[3]))
end

-- borrowed (slightly modified) from the roblox wiki
local function angles_from_cframe(cframe)
	local _,_,_,m00,m01,m02,_,_,m12,_,_,m22 = cframe:components()
	local x,y,z

	-- beware of this function returning NaN from some cases
	-- this is one case that has already caused a headache
	-- kinda obvious though because sin^-1(x | x>1) = indeterminant
	if m02 > 1 then m02 = 1 end
	if m02 < -1 then m02 = -1 end	
	
	return {math.deg(math.atan2(-m12, m22)),math.deg(math.asin(m02)),math.deg(math.atan2(-m01, m00))}
end

local function edge_cframe(size_vec, edge_designation)
	return CFrame.new(size_vec.x * edge_designation[1]/2, size_vec.y * edge_designation[2]/2, size_vec.z * edge_designation[3]/2)
end

local function directional_offset_cframe(point, distance)
	return CFrame.new(Vector3.new(), point) * angled_cframe({0,90,0}) * CFrame.new(distance, 0, 0)
end


local function vector3_to_table(vec)
	return {vec.x,vec.y,vec.z}
end

local function table_to_vector3(tbl)
	return Vector3.new(tbl[1],tbl[2],tbl[3])
end


local function check_table_to_vector3(v)
	if type(v) == 'table' then v = Vector3.new(v[1],v[2],v[3]) end
	return v
end

local function color3_to_table(color)
	return {color.r,color.g,color.b}
end

local function table_to_color3(tbl)
	return Color3.new(tbl[1],tbl[2],tbl[3])
end


return export {
	vector = {
		angled_cframe = angled_cframe,
		angles_from_cframe = angles_from_cframe,
		edge_cframe = edge_cframe,
		directional_offset_cframe = directional_offset_cframe,

		vector3_to_table = vector3_to_table,
		table_to_vector3 = table_to_vector3,
		check_table_to_vector3 = check_table_to_vector3,
		color3_to_table = color3_to_table,
		table_to_color3 = table_to_color3,
	},
}
