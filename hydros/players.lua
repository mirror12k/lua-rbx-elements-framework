
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



local active_users = {}


local on_player_hooks = {}
local on_player_left_hooks = {}
local on_character_hooks = {}
local on_character_died_hooks = {}
local on_character_removed_hooks = {}
local on_chat_hooks = {}





local function character_died(player, character)
	for _, f in ipairs(on_character_died_hooks) do
		f(player, character)
	end
end

local function character_added(player, character)
	for _, f in ipairs(on_character_hooks) do
		f(player, character)
	end

	local humanoid = character:FindFirstChild('Humanoid')
	if humanoid ~= nil then
		humanoid.Died:connect(function (character) character_died(player, character) end)
	else
		warn('missing humanoid in player ' .. player.UserId .. ' character')
	end
end

local function character_removed(player, character)
	for _, f in ipairs(on_character_removed_hooks) do
		f(player, character)
	end
end

local function character_chatted(player, message, recipient)
	for _, f in ipairs(on_chat_hooks) do
		f(player, message, recipient)
	end
end

local function player_added(player)
	active_users[player.UserId] = player
	-- hook the player events
	player.CharacterAdded:connect(function (character) character_added(player, character) end)
	player.CharacterRemoving:connect(function (character) character_removed(player, character) end)
	player.Chatted:connect(function (message, recipient) character_chatted(player, message, recipient) end)

	for _, f in ipairs(on_player_hooks) do
		f(player)
	end
end

local function player_removed(player)
	active_users[player.UserId] = nil

	for _, f in ipairs(on_player_left_hooks) do
		f(player)
	end
end






if script ~= nil then
	-- hook game player events
	game.Players.PlayerAdded:connect(player_added)
	game.Players.PlayerRemoving:connect(player_removed)
end




local function on_player(fun)
	on_player_hooks[#on_player_hooks + 1] = fun
end
local function on_player_left(fun)
	on_player_left_hooks[#on_player_left_hooks + 1] = fun
end
local function on_character(fun)
	on_character_hooks[#on_character_hooks + 1] = fun
end
local function on_character_died(fun)
	on_character_died_hooks[#on_character_died_hooks + 1] = fun
end
local function on_character_removed(fun)
	on_character_removed_hooks[#on_character_removed_hooks + 1] = fun
end
local function on_chat(fun)
	on_chat_hooks[#on_chat_hooks + 1] = fun
end



return export {
	players = {
		on_player = on_player,
		on_player_left = on_player_left,
		on_character = on_character,
		on_character_died = on_character_died,
		on_character_removed = on_character_removed,
		on_chat = on_chat,
	},
}
