-- Internal functoins

--Attempts to clone a table and returns it.
table.clone = function(source)
	--local debug = true
	local target = {}
	for key, val in pairs(source) do
		if debug then
			CONS_Printf(players[0], "Copying "+key+"; "+val)
		end
		if type(val) == "table" then
			target[key] = table.clone(val)
		else
			target[key] = val
		end
	end
	return target
end

rawset(_G, "ternary", function( cond , T , F )
    if cond then return T else return F end
end)

-- Attempts to sort keys
rawset(_G, "spairs", function(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end)


function table.length(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
