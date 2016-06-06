
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

-- implemented for the purpose of easily interacting with things outside the gameworks system
-- like the studio editor and external scripts

local in_memory_registry = {}

local registry_folder
if script ~= nil then
	registry_folder = block.folder('gameworks_registry')
	registry_folder.Parent = game.ServerStorage
end


local RegistryKey = class 'registry.RegistryKey' {
	_init = function (self, key, type, val, object, locked)
		self.key = key
		self.type = type
		self.val = val
		self.object = object
		self.locked = locked or false

		self.on_change_hooks = {}

		self:hook()
	end,

	hook = function (self)
		self.object.Changed:connect(function () self:object_changed() end)
	end,
	object_changed = function (self)
		if self.locked == false and self.val ~= self.object.Value then
			self.val = self.object.Value
			self:fire_change()
		-- else
		-- 	self.object.Value = val
		end
	end,
	delete = function (self)
		self.obj:Destroy()
		in_memory_registry[self.key] = nil
	end,
	get_val = function (self)
		return self.val
	end,
	set_val = function (self, val)
		if val ~= self.val then
			self.val = val
			self.object.Value = val
			self:fire_change()
		end
	end,

	on_change = function (self, fun)
		self.on_change_hooks[#self.on_change_hooks + 1] = fun
	end,
	fire_change = function (self)
		for i = 1, #self.on_change_hooks do
			self.on_change_hooks[i](self.val)
		end
	end,
}


local function create_key (key, type, val, locked)
	local path = split(key, '.')
	local parent = registry_folder
	for i = 1, #path - 1 do
		if parent:FindFirstChild(path[i]) == nil then
			block.folder(path[i]).Parent = parent
		end
		parent = parent[path[i]]
	end

	local obj = block.value(path[#path], type, val)
	obj.Parent = parent

	in_memory_registry[key] = RegistryKey.new(key, type, val, obj, locked)
end

local function delete_key(key)
	if in_memory_registry[key] == nil then
		error('attempt to delete unknown key [' .. key .. ']')
	end
	return in_memory_registry[key]:delete()
end


local function get_key(key)
	if in_memory_registry[key] == nil then
		error('attempt to get unknown key [' .. key .. ']')
	end
	return in_memory_registry[key]:get_val()
end

local function set_key(key, val)
	if in_memory_registry[key] == nil then
		error('attempt to set unknown key [' .. key .. ']')
	end
	return in_memory_registry[key]:set_val(val)
end


local function hook_key(key, fun)
	if in_memory_registry[key] == nil then
		error('attempt to hook unknown key [' .. key .. ']')
	end
	in_memory_registry[key]:on_change(fun)
end



return export {
	registry = {
		create = create_key,
		delete = delete_key,

		get = get_key,
		set = set_key,

		on_change = hook_key,
	}
}
