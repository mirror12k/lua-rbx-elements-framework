

require('util')

--[[
	stringed tables are a subset of regular tables that lack many advanced table-tools
	but are good enough for transfering simple nested tables
	being a subset allows these stringed tables to be inserted directly into lua code
]]





function stringed_table_to_table(stringed_table)
	if string.sub(stringed_table, 1, 1) ~= '{' then
		error('malformed stringed table:' .. string.sub(stringed_table, 1, 1))
	end
	local root = {}
	local t = root
	local depth_stack = Stack.new()
	local o = 2
	local p = string.find(stringed_table, '=', o)
	local p2 = string.find(stringed_table, '}', o)
	
	while p ~= nil do
		if p2 and p2 < p then
			t = depth_stack:pop()
			o = p2 + 1
		else
			local key = string.sub(stringed_table,o,p - 1)
			if string.sub(key, 1, 1) == '[' then
				key = tonumber(string.sub(key, 2, -2))
				if key == nil then error('failed to convert number') end
			end
--			print('got key: ', key)
--			if tonumber(name) ~= nil then name = tonumber(name) end
			
			local sy = string.sub(stringed_table,p + 1, p + 1)
			if sy == '{' then
				t[key] = {}
				depth_stack:push(t)
				t = t[key]
				o = p + 2
			elseif sy == '"' then
				local p3 = string.find(stringed_table, '"', p + 2)
				t[key] = string.sub(stringed_table, p + 2, p3 - 1)
				o = p3 + 1
			else
				local p3 = string.find(stringed_table, ',', p + 1)
				if p3 == nil then
					p3 = string.find(stringed_table, '}', p + 1)
				else
					p3 = math.min(p3, string.find(stringed_table, '}', p + 1))
				end
				local s = string.sub(stringed_table, p + 1, p3 - 1)
				if tonumber(s) ~= nil then
					t[key] = tonumber(s)
				elseif s == 'true' then
					t[key] = true
				elseif s == 'false' then
					t[key] = false
				else
					error('unknown value "' .. '"')
				end
				
				o = p3
			end
		end
		if string.sub(stringed_table, o, o) == ',' then
			o = o + 1
		end
		p = string.find(stringed_table, '=', o)
		p2 = string.find(stringed_table, '}', o)
	end
	
	return root
end





function table_to_stringed_table(tbl)
	
	local s = '{'
	
	local first = true
	for k,v in pairs(tbl) do
		if first then
			first = false
		else
			s = s .. ','
		end
		if type(k) == 'number' then
			s = s .. '[' .. tostring(k) .. ']'
		elseif type(k) == 'string' then
			s = s .. k
			-- s = s .. '["' .. k .. '"]'
		else
			error('unknown type to convert to stringed table: ' .. type(k))
		end
		s = s .. '='
		if type(v) == 'string' then
			s = s .. '"' .. v .. '"'
		elseif type(v) == 'number' then
			s = s .. tostring(v)
		elseif type(v) == 'table' then
			s = s .. table_to_stringed_table(v)
		elseif type(v) == 'boolean' then
			s = s .. tostring(v)
--		else
--			error('unknown type to convert to stringed table: ' .. tostring(k) .. ' => ' .. type(v))
		end
	end
	return s .. '}'
end



-- borrowed (slightly modified) from the internet
function split(str, delim)
  local out = {}
  local start = 1
  local split_start, split_end = string.find(str, delim, start, true)
  while split_start do
    table.insert(out, string.sub(str, start, split_start-1))
    start = split_end + 1
    split_start, split_end = string.find(str, delim, start, true)
  end
  table.insert(out, string.sub(str,start))
  return out
end


