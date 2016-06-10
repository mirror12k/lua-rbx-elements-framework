
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


local function create_trigger(size, position, opts)
	local p = block.block(opts.name or 'trigger', size, position, opts.rotation)
	p.CanCollide = false
	p.Locked = true
	p.Transparency = registry.get('trigger.transparency')
	p.Parent = opts.parent or trigger_storage
	return p
end


local function hook_character_trigger(trigger, fun, opts)
	local character_debounce = {}
	trigger.Touched:connect(function (other)
		-- verify that this is the torso
		-- otherwise what might happen is that a gibbed body part might fly off and activate a trigger accidentally
		if other.Name == 'Torso' then
			other = other.Parent
			-- verify that it could be a character and is not dead
			if other ~= nil and other:FindFirstChild('Humanoid') ~= nil and other.Humanoid.Health > 0 then
				-- find which character it is
				for id, char in pairs(players.get_active_characters()) do
					if char == other and character_debounce[id] == nil then
						-- perform debounce if necessary
						if opts.debounce ~= nil then
							character_debounce[id] = true
							delay_debounce_finish(opts.debounce, character_debounce, id)
						end
						-- invoke callback
						return fun(trigger, id, char)
					end
				end
			end
		end
	end)
end

-- creates an invisible trigger block which detects when a player character's torso touches it and fires the callback
-- returns the created trigger part which can be destroyed to delete the trigger
-- opts can contain a debounce in seconds to prevent a single character triggering it multiple times
local function character_trigger (size, position, fun, opts)
	opts = opts or {}
	local trigger = create_trigger(size, position, opts)

	hook_character_trigger(trigger, fun, opts)
	-- part is returned so that the trigger can later be deleted or toggled on-off by adding or removing it
	return trigger
end


local function hook_disposable_character_trigger(trigger, character, fun, opts)
	opts = opts or {}

	local connection
	connection = character:FindFirstChild('Torso').Touched:connect(function (other)
		if character.Humanoid.Health > 0 and other == trigger then
			connection:disconnect()
			return fun(trigger, character)
		end
	end)
end



-- a different implementation of a trigger by hooking the character's Touched instead of the trigger's Touched
-- this allows per-character removal of triggers and a much simpler and less expensive trigger mechanism
local function disposable_character_trigger(size, position, fun, opts)
	opts = opts or {}
	local trigger = create_trigger(size, position, opts)

	players.on_character(function (player, character)
		hook_disposable_character_trigger(trigger, character, fun, opts)
	end)
	-- part is returned so that the trigger can later be deleted or toggled on-off by adding or removing it
	return trigger
end






return export {
	trigger = {
		create_trigger = create_trigger,
		hook_character_trigger = hook_character_trigger,
		character_trigger = character_trigger,
		hook_disposable_character_trigger = hook_disposable_character_trigger,
		disposable_character_trigger = disposable_character_trigger,
	}
}

