
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




local CloudNoiseBlueprint
CloudNoiseBlueprint = class 'aeros.CloudNoiseBlueprint' {
	_extends = class_by_name 'hydros.ModelBlueprint',
	_init = function (self, type, size, name)
		CloudNoiseBlueprint.super._init(self, name)
		if type == 'box_noise' then
			self:add('box_noise', { size = size })
		elseif type == 'crystal_noise' then
			self:add('crystal_noise', { size = size })
		elseif type == 'pillar_noise' then
			self:add('pillar_noise', { size = size })
		else
			error('invalid noise type selected: ' .. type)
		end
	end,
	build_functions = {
		box_noise = function (self, model, item, opts)
			for x = -item.size[1]/2, item.size[1]/2 do
				for y = -item.size[2]/2, item.size[2]/2 do
					for z = -item.size[3]/2, item.size[3]/2 do
						local size = (math.noise((x + 0.2) / 3, (y + 0.2) / 3, (z + 0.2) / 3) + 0.5) * 30
						local anglex = (math.noise((x + 0.25) / 3, (y + 0.25) / 3, (z + 0.25) / 3)) * 360
						-- local angley = (math.noise((x + 0.275) / 3, (y + 0.275) / 3, (z + 0.275) / 3)) * 360
						local anglez = (math.noise((x + 0.295) / 3, (y + 0.295) / 3, (z + 0.295) / 3)) * 360
						-- print(size, x, y, z)
						local p = block.block_from_cframe('noise', {size, size, size}, CFrame.new(x * 15, y * 15, z * 15) * vector.angled_cframe({anglex, 0, anglez}))
						p.Parent = model
					end
				end
			end
		end,
		crystal_noise = function (self, model, item, opts)
			for x = -item.size[1]/2, item.size[1]/2 do
				for y = -item.size[2]/2, item.size[2]/2 do
					for z = -item.size[3]/2, item.size[3]/2 do
						local sizex = ((math.noise((x + 10000.215) / 3, (y + 10000.215) / 3, (z + 10000.215) / 3) + 0.5) * 6) ^ 2
						local sizey = ((math.noise((x + 0.225) / 3, (y + 0.225) / 3, (z + 0.225) / 3) + 0.5) * 6) ^ 2
						local sizez = ((math.noise((x + -10000.235) / 3, (y + -10000.235) / 3, (z + -10000.235) / 3) + 0.5) * 6) ^ 2
						local anglex = (math.noise((x + 0.25) / 3, (y + 0.25) / 3, (z + 0.25) / 3)) * 360
						-- local angley = (math.noise((x + 0.275) / 3, (y + 0.275) / 3, (z + 0.275) / 3)) * 360
						local anglez = (math.noise((x + 0.295) / 3, (y + 0.295) / 3, (z + 0.295) / 3)) * 360
						-- print(size, x, y, z)
						local p = block.block_from_cframe('noise', {sizex, sizey, sizez}, CFrame.new(x * 15, y * 15, z * 15) * vector.angled_cframe({anglex, 0, anglez}))
						p.Parent = model
					end
				end
			end
		end,
		pillar_noise = function (self, model, item, opts)
			for x = -item.size[1]/2, item.size[1]/2 do
				for z = -item.size[3]/2, item.size[3]/2 do
					local size = (math.noise((x + 0.1015) / 3, 1544.2563, (z + 0.1015) / 3) + 0.5)
					local p = block.block_from_cframe('noise', {10, size * item.size[2], 10}, CFrame.new(x * 10, size * item.size[2] / 2, z * 10))
					p.Parent = model
				end
			end
		end,
	},
}


return export {}
