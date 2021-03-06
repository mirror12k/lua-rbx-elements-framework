
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



import 'lithos/lithos'
import 'hydros/hydros'
import 'aeros/aeros'
import 'pyros/pyros'



-- local bp = new 'hydros.ModelBlueprint' ('test_model')
-- bp:add_part('testpart', {10, 20, 30})

-- local m = new 'hydros.ModelBlueprint' ('sub_model')

-- m:add_part('part1', {5, 100, 5}, {0, 50, 10}, {-45, 0, 0}, { anchored = false, })
-- m:add_part('part2', {5, 50, 5}, {0, 25, -10}, {45, 0, 0}, { anchored = false, })

-- m:add_weld('part1', 'part2')

-- m:add_value('myval', 'String', 'hello world!')

-- bp:add_model('center_model', m)
-- bp:add_model('sm1', m, { position = {70, 0, 0}, rotation = {0, 0, 45}, })
-- bp:add_model('sm2', m, { position = {-70, 0, 0}, rotation = {0, 0, -45}, })

-- bp:add_weld('testpart', qw' center_model.part2 sm1.part1 sm2.part1')


-- print(freeze(bp))


-- local bp2 = thaw 'hydros.ModelBlueprint:{["items"]={[1]={[1]="part",[2]={["rotation"]={[1]=-180,[2]=0,[3]=-0},["name"]="testpart",["position"]={[1]=0,[2]=100,[3]=0},["color"]={[1]=0.63921570777893,[2]=0.63529413938522,[3]=0.64705884456635},["anchored"]=true,["cancollide"]=true,["size"]={[1]=10,[2]=20,[3]=30}}},[2]={[1]="model",[2]={["model"]={["items"]={[1]={[1]="part",[2]={["rotation"]={[1]=135,[2]=0,[3]=-0},["name"]="part1",["position"]={[1]=0,[2]=50,[3]=-10.000009536743},["color"]={[1]=0.63921570777893,[2]=0.63529413938522,[3]=0.64705884456635},["anchored"]=false,["cancollide"]=true,["size"]={[1]=5,[2]=100,[3]=5}}},[2]={[1]="part",[2]={["rotation"]={[1]=-135,[2]=0,[3]=-0},["name"]="part2",["position"]={[1]=0,[2]=75,[3]=9.9999980926514},["color"]={[1]=0.63921570777893,[2]=0.63529413938522,[3]=0.64705884456635},["anchored"]=false,["cancollide"]=true,["size"]={[1]=5,[2]=50,[3]=5}}},[3]={[1]="weld",[2]={["p0"]="part1",["p1"]="part2"}}},["name"]="center_model"}}},[3]={[1]="model",[2]={["model"]={["items"]={[1]={[1]="part",[2]={["rotation"]={[1]=144.73561096191,[2]=-29.999998092651,[3]=35.264389038086},["name"]="part1",["position"]={[1]=34.644660949707,[2]=64.644660949707,[3]=-10.000002861023},["color"]={[1]=0.63921570777893,[2]=0.63529413938522,[3]=0.64705884456635},["anchored"]=false,["cancollide"]=true,["size"]={[1]=5,[2]=100,[3]=5}}},[2]={[1]="part",[2]={["rotation"]={[1]=-144.73561096191,[2]=29.999994277954,[3]=35.264385223389},["name"]="part2",["position"]={[1]=52.322326660156,[2]=82.322326660156,[3]=10.000000953674},["color"]={[1]=0.63921570777893,[2]=0.63529413938522,[3]=0.64705884456635},["anchored"]=false,["cancollide"]=true,["size"]={[1]=5,[2]=50,[3]=5}}},[3]={[1]="weld",[2]={["p0"]="part1",["p1"]="part2"}}},["name"]="sm1"}}},[4]={[1]="model",[2]={["model"]={["items"]={[1]={[1]="part",[2]={["rotation"]={[1]=144.73561096191,[2]=29.999998092651,[3]=-35.264389038086},["name"]="part1",["position"]={[1]=-34.644660949707,[2]=64.644660949707,[3]=-10.000002861023},["color"]={[1]=0.63921570777893,[2]=0.63529413938522,[3]=0.64705884456635},["anchored"]=false,["cancollide"]=true,["size"]={[1]=5,[2]=100,[3]=5}}},[2]={[1]="part",[2]={["rotation"]={[1]=-144.73561096191,[2]=-29.999994277954,[3]=-35.264385223389},["name"]="part2",["position"]={[1]=-52.322326660156,[2]=82.322326660156,[3]=10.000000953674},["color"]={[1]=0.63921570777893,[2]=0.63529413938522,[3]=0.64705884456635},["anchored"]=false,["cancollide"]=true,["size"]={[1]=5,[2]=50,[3]=5}}},[3]={[1]="weld",[2]={["p0"]="part1",["p1"]="part2"}}},["name"]="sm2"}}},[5]={[1]="weld",[2]={["p0"]="testpart",["p1"]="center_model.part2"}},[6]={[1]="weld",[2]={["p0"]="testpart",["p1"]="sm1.part1"}},[7]={[1]="weld",[2]={["p0"]="testpart",["p1"]="sm2.part1"}}},["name"]="test_model"}'

-- print (bp2)


-- local m = bp2:build({ cframe = CFrame.new(0, 100, 0) * vector.angled_cframe({180, 0, 0}) })
-- m.Parent = workspace

-- print (freeze(class_by_name 'hydros.ModelBlueprint' :generate_from_model(m)))


-- local cf = CFrame.new(50, 50, 50)
-- local cf2 = cf * vector.angled_cframe({0, 45, 0}) * CFrame.new(20, 0, 0)

-- draw.cframe(cf)
-- draw.cframe(cf2)

-- draw.line(Vector3.new(), cf.p)
-- draw.line(Vector3.new(), cf2.p)


-- local bp = new 'aeros.StreetBlueprint' ()
-- bp:add_street({30, 0}, {400, 0})
-- bp:add_street({0, 30}, {0, 200})
-- bp:add_street({-30, 0}, {-200, 0})
-- bp:add_street({0, -30}, {0, -600})

-- bp:add_street({200, 200}, {-200, -200})
-- bp:add_street({200, -400}, {-200, 400})

-- bp:build({ cframe = CFrame.new(0, 1, 0) }).Parent = workspace


-- local bp = new 'aeros.RoomBlueprint' ()
-- -- bp:add_wall({9, 10}, {9, -10})
-- -- bp:add_wall({-9, 10}, {-9, -10})
-- -- bp:add_wall({10, 9}, {-10, 9})
-- -- bp:add_wall({10, -9}, {-10, -9})
-- -- bp:add_floor({20, 2, 20}, {0, 11, 0}, 0, {-10, -9})

-- bp:add_room({0, 0}, 20, 20, { ceiling = {holes = {{ positionx = 0.2, lengthx = 0.2, positiony = 0.25, lengthy = 0.5 }}} })
-- bp:add_room({10, 20}, 40, 20)
-- bp:add_room({10, 40}, 40, 20)

-- -- bp:add_wall({0, 0}, {-50, 50}, { holes = {
-- -- 	{ positionx = 0.2, lengthx = 0.2, positiony = 0.25, lengthy = 0.5 },
-- -- 	{ positionx = 0.6, lengthx = 0.2, positiony = 0.2, lengthy = 0.6 },
-- -- }})
-- -- bp:add_wall({0, 0}, {50, 50}, { holes = {
-- -- 	{ positionx = 0.2, lengthx = 0.2, positiony = 0.2, lengthy = 0.2 },
-- -- 	{ positionx = 0.2, lengthx = 0.2, positiony = 0.6, lengthy = 0.2 },
-- -- }})

-- bp:build().Parent = workspace



-- print(geometry.d2.are_segments_overlapping({{10, 10}, {30, 30}}, {{20, 20}, {60, 60}}))
-- print(geometry.d2.are_segments_overlapping({{10, 10}, {30, 30}}, {{40, 40}, {60, 60}}))
-- print_table(geometry.d2.join_overlapping_segments({{10, 10}, {30, 30}}, {{20, 20}, {60, 60}}))
-- print_table(geometry.d2.join_overlapping_segments({{10, 10}, {30, 30}}, {{-20, -20}, {60, 60}}))


-- print(geometry.d2.angle_of_point({10, 10}))
-- print(geometry.d2.angle_of_point({-10, 10}))
-- print(geometry.d2.angle_of_point({-10, -10}))
-- print(geometry.d2.angle_of_point({10, -10}))

-- print(geometry.d2.angle_of_points({0, 10}, {10, 10}))
-- print(geometry.d2.angle_of_points({10, 0}, {10, 10}))

-- print(unpack(geometry.d2.to_object_space({0, 0}, {20, 20}, {30, 30})))
-- print_table(geometry.d2.to_object_space_all({0, 0}, {20, 20}, { {30, 30}, {40, 0} }))


-- print(unpack(geometry.d2.to_global_space({10, 15}, {20, 20}, geometry.d2.to_object_space({10, 15}, {20, 20}, {30, 30}))))
-- print(unpack(geometry.d2.to_global_space({10, 15}, {-20, 18}, geometry.d2.to_object_space({10, 15}, {-20, 18}, {30, 30}))))
-- print_table(geometry.d2.to_global_space_all({-15, -24}, {-40, -15}, geometry.d2.to_object_space_all({-15, -24}, {-40, -15}, { {30, 30}, {40, 0} })))


-- print(geometry.d2.are_points_inline({0, 10}, {0, 20}, {0, 40}))
-- print(geometry.d2.are_points_inline({0, 10}, {0, 20}, {0, 0}))
-- print(geometry.d2.are_points_inline({0, 10}, {0, 20}, {2, 40}))
-- print(geometry.d2.are_points_inline({0, 10}, {1, 20}, {0, 40}))
-- print(geometry.d2.are_points_inline({-10, 10}, {-20, 20}, {-40, 40}))
-- print(geometry.d2.are_points_inline({-10, 10}, {-20, 20}, {40, -40}))
-- print(geometry.d2.are_segments_inline({{10, 10}, {20, 20}}, {{40, 40}, {50, 50}}))
-- print(geometry.d2.are_segments_inline({{10, 10}, {20, 20}}, {{-40, -40}, {-50, -50}}))
-- print(geometry.d2.are_segments_inline({{10, 10}, {20, 20}}, {{40, 40}, {-50, 50}}))
-- print(geometry.d2.are_segments_inline({{10, 10}, {20, 20}}, {{40, -40}, {-50, -50}}))
-- print(geometry.d2.are_segments_inline({{10, 10}, {20, 20}}, {{20, 10}, {30, 20}}))


-- print_table(geometry.d2.find_line_collision({{0, 0}, {10, 0}}, {{20, 10}, {30, 20}}))
-- print_table(geometry.d2.find_line_collision({{0, 0}, {10, 0}}, {{10, 10}, {20, 20}}))
-- print_table(geometry.d2.find_line_collision({{0, 0}, {10, 0}}, {{10, 5}, {20, 10}}))
-- print_table(geometry.d2.find_line_collision({{0, 0}, {10, 0}}, {{10, 20}, {20, 40}}))
-- print_table(geometry.d2.find_line_collision({{0, 0}, {10, 0}}, {{10, 20}, {20, 10}}))
-- print_table(geometry.d2.find_line_collision({{0, 0}, {10, 0}}, {{10, 20}, {20, 10}}))
-- print_table(geometry.d2.find_line_collision({{0, 0}, {10, 0}}, {{10, 0}, {10, 10}}))


-- print_table(geometry.d2.find_segment_collision({{-20, 0}, {20, 0}}, {{10, 5}, {10, 10}}))
-- print_table(geometry.d2.find_segment_collision({{-20, 20}, {20, -20}}, {{-10, -10}, {10, 10}}))

-- print_table(geometry.d2.offset_segment({{0, 0}, {10, 10}}, -90, 10))



-- math.randomseed(tick())

-- local bp = new 'aeros.StreetBlueprint' ()
-- -- bp:add_street({10, 10}, {-10, -10})
-- -- bp:add_street({-10, 10}, {10, -10})

-- -- bp:add_street({200, 200}, {-100, -200})
-- -- bp:add_street({200, -80}, {-200, -20})

-- bp:add_street({200, 200}, {-200, -200})
-- bp:add_street({-100, -100}, {-200, -100})
-- bp:add_street({100, 100}, {100, 200})

-- -- for _ = 1, 15 do
-- -- 	bp:add_street({math.random(-1000, 1000), math.random(-1000, 1000)}, {math.random(-1000, 1000), math.random(-1000, 1000)})
-- -- end

-- bp:build({ cframe = CFrame.new(0, 1, 0) }).Parent = workspace





-- new 'aeros.BuildingBlueprint' (5, 50, 110):build().Parent = workspace

-- local bp = new 'aeros.ConcreteBarrierBlueprint' ()
-- bp.thickness = 6
-- bp.height = 20

-- bp
-- 	:add_wall({20, 20}, {20, -20})
-- 	:add_wall({20, -20}, {-20, -20})
-- 	:add_wall({-20, -20}, {-20, 20})
-- 	:build().Parent = workspace



-- new 'aeros.CloudNoiseBlueprint' ('pillar_noise', {40, 100, 40}):build().Parent = workspace


-- new 'pyros.SlimeBlueprint' (20, {80, 200, 80}):build({cframe = CFrame.new(0, 50, 0)}).Parent = workspace
-- new 'pyros.slime.SlimeMountainBlueprint' (100, 100, 45)
-- 	:add_mountain_crack(0.2, 0.4, 0, 0.5, {
-- 						depthx = 0.75,
-- 						depthy = 0.75,
-- 						bank_left = { angle = 15, runoff_angle = 20 },
-- 						bank_right = { angle = 15, runoff_angle = 20 },
-- 					})
-- 	:add_mountain_crack(0.7, 0.3, 0.8, 0.2, {
-- 						depthx = 1.5,
-- 						depthy = 1.5,
-- 						bank_left = { angle = 15, runoff_angle = 20 },
-- 						bank_right = { angle = 15, runoff_angle = 20 },
-- 					})
-- 	:build().Parent = workspace

-- new 'pyros.slime.SlimeMountainBlueprint' (100, 100, 45)
-- 	:add_zigzag('right', 0.2, 0.4, 0, 0.5, {})
-- 	:add_zigzag('left', 0.7, 0.3, 0.8, 0.2, {})
-- 	:build().Parent = workspace

-- local mountain = slime_mountain_generator(100, 500, 30)
-- mountain:build().Parent = workspace
-- local top = CFrame.new(vector.table_to_vector3(mountain:get_top_edge()))

-- mountain = slime_mountain_generator(100, 500, 35)
-- mountain:build({ cframe = top }).Parent = workspace
-- top = top * CFrame.new(vector.table_to_vector3(mountain:get_top_edge()))

-- mountain = slime_mountain_generator(100, 500, 45)
-- mountain:build({ cframe = top }).Parent = workspace
-- top = top * CFrame.new(vector.table_to_vector3(mountain:get_top_edge()))





math.randomseed(tick())

slime_mountain.start()

-- trigger.disposable_character_trigger({10, 100, 100}, {50, 50, 0}, function (tgr, char)
-- 	print('character of ' .. char.Name .. ' tripped the trigger!')
-- end, { debounce = 3 })
