
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



local function merge_holes (holes)
	local new_holes = {}
	while #holes > 0 do
		local hole = table.remove(holes, #holes)
		for i = #holes, 1, -1 do
			if hole.position >= holes[i].position and hole.position < holes[i].position + holes[i].length or
					holes[i].position >= hole.position and holes[i].position < hole.position + hole.length then
				local other = table.remove(holes, i)
				hole.length = math.max(hole.position + hole.length, other.position + other.length)
				hole.position = math.min(hole.position, other.position)
				hole.length = hole.length - hole.position
			end
		end
		new_holes[#new_holes + 1] = hole
	end
	return new_holes
end

local function holes_to_sections(holes)
	local sections = {{ position = 0, length = 1 }}
	for _, hole in ipairs(holes) do
		local target = -1
		for i, v in ipairs(sections) do
			if v.position <= hole.position and v.position + v.length > hole.position then
				if hole.length + hole.position > v.position + v.length then
					error('invalid hole: ' .. tostring(hole.position) .. ' - ' .. tostring(hole.length))
				end
				target = i
				break
			end
		end

		if target == -1 then
			error('no matching section found: ' .. hole.length .. ", " .. hole.position)
		end

		local sec = table.remove(sections, target)
		if sec.position < hole.position then
			table.insert(sections, target, {
				position = sec.position,
				length = hole.position - sec.position,
			})
		end
		if sec.position + sec.length > hole.position + hole.length then
			table.insert(sections, target, {
				position = hole.position + hole.length,
				length = sec.position + sec.length - (hole.position + hole.length),
			})
		end
	end
	return sections
end

return export {
	spaceful = {
		merge_holes = merge_holes,
		holes_to_sections = holes_to_sections,
	},
}
