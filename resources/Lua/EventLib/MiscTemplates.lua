/*

------------------------------------------------
--
-- Use gamescenes[] for code named titles, instead of raw numbers
--
------------------------------------------------

rawset(_G, "gamescenes", {

	NONUMBER = -1,
	["GreenFlower01"] = G_GetMap("MAP01"),
})

local gamescenes_meta = {
	__call = function(gamescenes_meta, newtable)
		return gamescenes_meta[newtable]
	end
}
gamescenes = setmetatable(gamescenes, gamescenes_meta)


------------------------------------------------
--
-- Use Snd() for code named tracks, instead of index names
--
------------------------------------------------

rawset(_G, "Snd", {

	["SE_THOK"] = sfx_thok,
	
	["BGM_EV_none"] = "none",
	["BGM_ST_GREENFLOWER"] = "map01",

})
Snd = setmetatable(Snd, {
	__call = function(s, val)
		return s[val] or "none"
	end
})


------------------------------------------------
--
-- Use SPRITES() for code named sprites, instead of SPR_SDRF
--
------------------------------------------------

rawset(_G, "SPRITES", {
	-- Used: *
	["thokgrey"] = SPR_THKG, -- Frames: 1 [A]
})
SPRITES = setmetatable(SPRITES, {
	__call = function(sprn, val)
		--print("called into "..val)
		return sprn[val]
	end
})


------------------------------------------------
--
-- Use maplocation() for coordinates, to bookmark used coordinates
--
------------------------------------------------
rawset(_G, "maplocation", {
	--["PLAYER_MAP_SPAWNPOINT"] = {x = 0*FRACUNIT, y = 0*FRACUNIT, z = 0*FRACUNIT, angle = FixedAngle(90*FRACUNIT)},
})

maplocation = setmetatable(maplocation, {
	__call = function(dmy, new)
		--[[dmy[new].x = $1 * FRACUNIT
		dmy[new].y = $1 * FRACUNIT
		dmy[new].z = $1 * FRACUNIT]]
		return dmy[new]
	end
})


*/
