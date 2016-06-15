
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
import 'vector'



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



local TriggerObject = class 'hydros.TriggerObject' {
	_init = function (self)
		self:connect()
		self.connected = true
	end,
	reconnect = function (self)
		if self.connected == false then
			self:connect()
			self.connected = true
		end
	end,
	disconnect = function (self)
		if self.connected == true then
			self:break_connection()
			self.connected = false
		end
	end,
}




local delay_debounce_finish = cww(function (delay, debounce, key)
	wait(delay)
	debounce[key] = nil
end)


local function create_trigger_part(size, position, opts)
	opts = opts or {}
	local p = block.block(opts.name or 'trigger', size, position, opts.rotation)
	p.CanCollide = false
	p.Locked = true
	p.Transparency = registry.get('trigger.transparency')
	p.Parent = opts.parent or trigger_storage
	return p
end



local CharacterTrigger
CharacterTrigger = class 'hydros.CharacterTrigger' {
	_extends = TriggerObject,
	_init = function (self, trigger_part, fun, debounce)
		self.trigger_part = trigger_part
		self.fun = fun
		self.debounce = debounce
		self.debounce_active = {}
		CharacterTrigger.super._init(self)
	end,
	connect = function (self)
		self.connection = self.trigger_part.Touched:connect(function (other)
			-- verify that this is the torso and that it could be a character and is not dead
			-- otherwise what might happen is that a gibbed body part might fly off and activate a trigger accidentally
			if other.Name == 'Torso' and other.Parent ~= nil
					and other.Parent:FindFirstChild('Humanoid') ~= nil and other.Parent.Humanoid.Health > 0 then
				-- find which player it is
				local player = game.Players:GetPlayerFromCharacter(other.Parent)
				if not self.debounce_active[player.UserId] then
					-- perform debounce if necessary
					if self.debounce ~= nil then
						self.debounce_active[player.UserId] = true
						self:delay_debounce_finish(player.UserId)
					end
					-- invoke callback
					return self.fun(self, other.Parent)
				end
			end
		end)
	end,
	break_connection = function (self)
		self.connection:disconnect()
	end,
	delay_debounce_finish = cww(function (self, id)
		wait(self.debounce)
		self.debounce_active[id] = nil
	end),
}

local function hook_character_trigger(trigger_part, fun, opts)
	opts = opts or {}
	return new 'hydros.CharacterTrigger' (trigger_part, fun, opts.debounce)
end

-- creates an invisible trigger block which detects when a player character's torso touches it and fires the callback
-- returns the created trigger object which can be safely disconnected or reconnected
-- callback will receive the trigger object and character
-- opts can contain a debounce in seconds to prevent a single character triggering it multiple times
local function character_trigger (size, position, fun, opts)
	local trigger = create_trigger_part(size, position, opts)

	return hook_character_trigger(trigger, fun, opts)
end




local DisposableCharacterTrigger
DisposableCharacterTrigger = class 'hydros.DisposableCharacterTrigger' {
	_extends = TriggerObject,
	_init = function (self, trigger_part, character, fun)
		self.trigger_part = trigger_part
		self.character = character
		self.fun = fun
		DisposableCharacterTrigger.super._init(self)
	end,
	connect = function (self)
		if self.character:FindFirstChild('Torso') ~= nil and self.character:FindFirstChild('Humanoid') ~= nil then
			self.connection = self.character.Torso.Touched:connect(function (other)
				if other == self.trigger_part and self.character:FindFirstChild('Humanoid') ~= nil and self.character.Humanoid.Health > 0 then
					self:disconnect()
					return self.fun(self, self.character)
				end
			end)
		end
	end,
	break_connection = function (self)
		self.connection:disconnect()
		self.connection = nil
	end,
}



local function hook_disposable_character_trigger(trigger_part, character, fun, opts)
	return new 'hydros.DisposableCharacterTrigger' (trigger_part, character, fun)
end



-- a different implementation of a trigger by hooking the character's Touched instead of the trigger's Touched
-- callback will receive the trigger object and character
-- this allows per-character removal of triggers and a much simpler and less expensive trigger mechanism
local function disposable_character_trigger(size, position, fun, opts)
	local trigger_part = create_trigger_part(size, position, opts)

	players.on_character(function (player, character)
		hook_disposable_character_trigger(trigger_part, character, fun, opts)
	end)
	-- part is returned so that the trigger can later be deleted or toggled on-off by adding or removing it
	return trigger
end





local function hook_character_absolute_teleport(trigger_part, position, fun, opts)
	hook_character_trigger(trigger_part, function (trigger, character)
		local humanoid = character:FindFirstChild('Humanoid')
		local torso = character:FindFirstChild('Torso')
		if torso ~= nil and humanoid ~= nil and humanoid.Health > 0 then
			torso.CFrame = CFrame.new(unpack(position))
			if fun ~= nil then
				fun(trigger, character)
			end
		end
	end, opts)
end



return export {
	trigger = {
		create_trigger_part = create_trigger_part,
		hook_character_trigger = hook_character_trigger,
		character_trigger = character_trigger,
		hook_disposable_character_trigger = hook_disposable_character_trigger,
		disposable_character_trigger = disposable_character_trigger,
		hook_character_absolute_teleport = hook_character_absolute_teleport,
	}
}

