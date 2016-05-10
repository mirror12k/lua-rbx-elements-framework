

-- borrowed from some internet page
function isINF(v)
  return v == math.huge or v == -math.huge
end
-- this too
function isNAN(v)
  return v ~= v
end



-- returns each element subtracted from the next, effectively taking the dx/dy of a data set
-- inverse opperation of list_integral
function list_delta(list)
	local l = {}
	l[1] = list[1]
	for i = 2,#list do
		l[i] = list[i] - list[i-1]
	end
	return l
end


-- returns each element add to the next, effectively taking the integral of a data set
-- inverse opperation of list_delta
function list_integral(list)
	local l = {}
	l[1] = list[1]
	for i = 2,#list do
		l[i] = list[i] + l[i-1]
	end
	return l
end

