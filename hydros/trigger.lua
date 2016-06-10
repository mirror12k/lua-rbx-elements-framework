
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

import 'block'
import 'players'
import 'registry'



local trigger_storage
if script ~= nil then
	trigger_storage = block.model('gameworks_triggers')
	trigger_storage.Parent = workspace

	registry.create('trigger.transparency', 'Number', 1)
	registry.on_change('trigger.transparency', function (val)
		for _, trigger in ipairs(trigger_storage:GetChildren()) do
			trigger.Transparency = val
		end
	end)
end




local function character_trigger (size, position, fun, opts)
	opts = opts or {}

	local b = block.block(opts.name, size, position, opts.rotation)
	b.CanCollide = false
	b.Locked = true
	b.Transparency = registry.get('trigger.transparency')
	b.Parent = opts.parent or trigger_storage
	b.Touched:connect(function (other)
		other = other.Parent
		if other ~= nil and other:FindFirstChild('Humanoid') ~= nil then
			for id, char in pairs(players.get_active_characters()) do
				if char == other then
					return fun(id, char)
				end
			end
		end
	end)
	return b
end






return export {
	trigger = {
		character_trigger = character_trigger,
	}
}

