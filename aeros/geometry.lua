
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
import '../hydros/hydros'



local function angle_of_points (p1, p2)
	return math.deg(math.atan2(p2[2] - p1[2], p2[1] - p1[1]))
end

local function angle_of_point (p1)
	return math.deg(math.atan2(p1[2], p1[1]))
end

local function to_object_space (global_point, angle_point, target)
	local global_angle = angle_of_point({ angle_point[1] - global_point[1], angle_point[2] - global_point[2] })
	local result = { target[1] - global_point[1], target[2] - global_point[2] }

	local result_angle = angle_of_point(result) - global_angle
	local dist = math.sqrt(result[1]^2 + result[2]^2)

	return {dist * math.cos(math.rad(result_angle)), dist * math.sin(math.rad(result_angle))}
end

local function to_object_space_all (global_point, angle_point, targets)
	angle_point = { angle_point[1] - global_point[1], angle_point[2] - global_point[2] }
	local global_angle = angle_of_point(angle_point)

	local results = {}
	for i = 1, #targets do
		results[i] = { targets[i][1] - global_point[1], targets[i][2] - global_point[2] }
		local angle = angle_of_point(results[i]) - global_angle
		local dist = math.sqrt(results[i][1]^2 + results[i][2]^2)

		results[i] = { dist * math.cos(math.rad(angle)), dist * math.sin(math.rad(angle)) }
	end

	return results
end

local function to_global_space (global_point, angle_point, target)
	local global_angle = angle_of_point({ angle_point[1] - global_point[1], angle_point[2] - global_point[2] })

	local result_angle = angle_of_point(target) + global_angle
	local dist = math.sqrt(target[1]^2 + target[2]^2)

	return {dist * math.cos(math.rad(result_angle)) + global_point[1], dist * math.sin(math.rad(result_angle)) + global_point[2]}
end

local function to_global_space_all (global_point, angle_point, targets)
	angle_point = { angle_point[1] - global_point[1], angle_point[2] - global_point[2] }
	local global_angle = angle_of_point(angle_point)

	local results = {}
	for i = 1, #targets do
		local angle = angle_of_point(targets[i]) + global_angle
		local dist = math.sqrt(targets[i][1]^2 + targets[i][2]^2)

		results[i] = { dist * math.cos(math.rad(angle)) + global_point[1], dist * math.sin(math.rad(angle)) + global_point[2] }
	end

	return results
end



local function are_points_inline (p1, p2, p3)
	local angle = angle_of_points(p1, p2)
	if angle_of_points(p1, p3) == angle then
		return true
	elseif angle_of_points(p3, p1) == angle then
		return true
	else
		return false
	end
end

local function are_segments_inline (s1, s2)
	local local_s2 = to_object_space_all(s1[1], s1[2], s2)
	return are_points_inline({0, 0}, unpack(local_s2))
end




return export {
	geometry = {
		d2 = {
			angle_of_points = angle_of_points,
			angle_of_point = angle_of_point,
			to_object_space = to_object_space,
			to_object_space_all = to_object_space_all,
			to_global_space = to_global_space,
			to_global_space_all = to_global_space_all,
			are_points_inline = are_points_inline,
			are_segments_inline = are_segments_inline,
		},
	}
}
