
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



local delay_debounce_finish = cww(function (delay, debounce, key)
	wait(delay)
	debounce[key] = nil
end)


local function character_trigger (size, position, fun, opts)
	opts = opts or {}

	local character_debounce = {}

	local b = block.block(opts.name, size, position, opts.rotation)
	b.CanCollide = false
	b.Locked = true
	b.Transparency = registry.get('trigger.transparency')
	b.Parent = opts.parent or trigger_storage
	b.Touched:connect(function (other)
		other = other.Parent
		-- verify that it could be a character
		if other ~= nil and other:FindFirstChild('Humanoid') ~= nil then
			-- find which character it is
			for id, char in pairs(players.get_active_characters()) do
				if char == other and character_debounce[id] == nil then
					-- perform debounce if necessary
					if opts.debounce ~= nil then
						character_debounce[id] = true
						delay_debounce_finish(opts.debounce, character_debounce, id)
					end
					-- invoke callback
					return fun(id, char)
				end
			end
		end
	end)
	-- part is returned so that a trigger can later be deleted or toggled on-off by adding or removing it
	return b
end






return export {
	trigger = {
		character_trigger = character_trigger,
	}
}

