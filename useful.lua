
-- a roblox cli version of import
function import (name) local target = game.ServerScriptService; string.gsub(name, "([^/]+)", function(s) if s == '..' then target = target.Parent else target = target[s] end end); return require(target)() end

