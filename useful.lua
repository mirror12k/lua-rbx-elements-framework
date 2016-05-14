
-- a roblox cli version of import
function import (name) local target = game.ServerScriptService; string.gsub(name, "([^/]+)", function(s) target = target[s] end); return require(target)() end

import 'lithos/lithos'; import 'hydros/hydros'

-- serialize a model
print (freeze(class_by_name 'hydros.ModelBlueprint' :generate_from_model(workspace.test_model)))

