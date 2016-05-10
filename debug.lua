




function print_table(tbl, indent)
	indent = indent or ''
	print(indent .. '{')
	for k,v in pairs(tbl) do
		if type(v) == 'table' then
			print(indent .. '[' .. tostring(k) .. '] = ')
			print_table(v,indent .. '  ')
		else
			print(indent .. '[' .. tostring(k) .. '] = ' .. tostring(v) .. ',')
		end
	end
	print(indent .. '}')
end


