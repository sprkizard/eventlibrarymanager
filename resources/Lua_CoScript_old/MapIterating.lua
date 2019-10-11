
------------------------------------------------------------------------------------
-- MAP ITERATING MANAGEMENT
------------------------------------------------------------------------------------

--local use_iterators = false
rawset(_G, "ThingList", {})
rawset(_G, "MapThingList", {})
rawset(_G, "LineList", {})
rawset(_G, "SectorList", {})

-- ThingList
local mobj_iteratelist = {
	MT_BLUECRAWLA,
}


-- MapThingList
local mobj_mapthinglist_iteratelist = {
	MT_BLUECRAWLA,
}

-- CustomThingList
local mobj_customthinglist1_iteratelist = {
	MT_BLUECRAWLA,
}

--[[
for i=1, #mobj_iteratelist do
	addHook("MobjSpawn", function(mo)
		table.insert(ThingList, mo)
		--print("added object type: "..tostring(mo.type).." of "..tostring(mo))
	end, mobj_iteratelist[i])

	addHook("MobjRemoved", function(mo)
		for i=1, #ThingList do
			if ThingList[i] == mo then
				table.remove(ThingList, i)
				break
			end
		end
		--print("removed object type: "..tostring(mo.type).." of "..tostring(mo))
	end, mobj_iteratelist[i])
end

for i=1, #mobj_mapthinglist_iteratelist do
	addHook("MobjSpawn", function(mo)
		table.insert(MapThingList, mo)
		--print("added object type: "..tostring(mo.type).." of "..tostring(mo))
	end, mobj_mapthinglist_iteratelist[i])

	addHook("MobjRemoved", function(mo)
		for i=1, #MapThingList do
			if MapThingList[i] == mo then
				table.remove(MapThingList, i)
				break
			end
		end
		--print("removed object type: "..tostring(mo.type).." of "..tostring(mo))
	end, mobj_mapthinglist_iteratelist[i])
end
]]



addHook("MapLoad", do
	for line in lines.iterate do
		table.insert(LineList, line)
	end
	for sector in sectors.iterate do
		table.insert(SectorList, sector)
	end
end)

addHook("MapChange", do
	MapThingList = {}
	ThingList = {}
	LineList = {}
	SectorList = {}
end)
