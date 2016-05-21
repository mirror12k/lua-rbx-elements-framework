
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


local function holes_to_sections_d2(holes)
	local sections = {{ positionx = 0, lengthx = 1, positiony = 0, lengthy = 1 }}

	for _, hole in ipairs(holes) do
		local target = -1
		for i, v in ipairs(sections) do
			if v.positionx <= hole.positionx and v.positionx + v.lengthx > hole.positionx and
					(hole.positiony == nil and hole.lengthy == nil or v.positiony <= hole.positiony and v.positiony + v.lengthy > hole.positiony) then
				if hole.lengthx + hole.positionx > v.positionx + v.lengthx then
					error('invalid hole: ' .. tostring(hole.positionx) .. ' - ' .. tostring(hole.lengthx))
				end
				target = i
				break
			end
		end

		if target == -1 then
			error('hole out of bounds: ' .. tostring(hole.positionx) .. ' - ' .. tostring(hole.lengthx))
		end

		-- calculate the before and after pieces of wall
		local sec = table.remove(sections, target)
		if sec.positionx == hole.positionx then
			if sec.lengthx == hole.lengthx then
				-- do nothing to delete the section
			else
				table.insert(sections, target, {
					positionx = sec.positionx + hole.lengthx,
					lengthx = sec.lengthx - hole.lengthx,
					positiony = sec.positiony,
					lengthy = sec.lengthy,
				})
			end
		else
			if sec.positionx + sec.lengthx == hole.positionx + hole.lengthx then
				table.insert(sections, target, {
					positionx = sec.positionx,
					lengthx = hole.positionx - sec.positionx,
					positiony = sec.positiony,
					lengthy = sec.lengthy,
				})
			else
				table.insert(sections, target, {
					positionx = hole.positionx + hole.lengthx,
					lengthx = (sec.lengthx + sec.positionx) - (hole.lengthx + hole.positionx),
					positiony = sec.positiony,
					lengthy = sec.lengthy,
				})
				table.insert(sections, target, {
					positionx = sec.positionx,
					lengthx = hole.positionx - sec.positionx,
					positiony = sec.positiony,
					lengthy = sec.lengthy,
				})
			end
		end

		-- calculate the above and below pieces of wall
		if hole.positiony ~= nil and hole.lengthy ~= nil then
			if hole.positiony == sec.positiony then
				if hole.lengthy == sec.lengthy then
					-- do nothing
				else
					table.insert(sections, target, {
						positionx = hole.positionx,
						lengthx = hole.lengthx,
						positiony = hole.positiony + hole.lengthy,
						lengthy = sec.lengthy - hole.lengthy,
					})
				end
			else
				if hole.positiony + hole.lengthy == sec.positiony + sec.lengthy then
					table.insert(sections, target, {
						positionx = hole.positionx,
						lengthx = hole.lengthx,
						positiony = sec.positiony,
						lengthy = hole.positiony - sec.positiony,
					})
				else
					table.insert(sections, target, {
						positionx = hole.positionx,
						lengthx = hole.lengthx,
						positiony = sec.positiony,
						lengthy = hole.positiony - sec.positiony,
					})
					table.insert(sections, target, {
						positionx = hole.positionx,
						lengthx = hole.lengthx,
						positiony = hole.positiony + hole.lengthy,
						lengthy = (sec.lengthy + sec.positiony) - (hole.lengthy + hole.positiony),
					})
				end
			end
		end
	end

	return sections
end




return export {
	spaceful = {
		merge_holes = merge_holes,
		holes_to_sections = holes_to_sections,
		holes_to_sections_d2 = holes_to_sections_d2,
	},
}
