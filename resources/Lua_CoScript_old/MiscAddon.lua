

------------------------------------------------------------------------------------
-- MISC FUNCTIONS
------------------------------------------------------------------------------------

-- Set Display Player (named f12)
-- ---
-- @player - userdata player
-- @playerNum - the player number/node
-- @allDisp - display all (or local)

local function changeDispPlayer(player, playerNum, allDisp)
	-- There needs to be a value
	if not (playerNum or type(playerNum) == "string") then
		print("\x82WARNING:\x80 " .. "No player specified")
	end

	-- Change display on local playernumber or change all
	if not (allDisp) then
		G_SetDisplayPlayer(player, playerNum, false)
	else
		G_SetDisplayPlayer(player, playerNum, true)
	end
	--print("Viewpoint: "..player.name.."("..#player..")")
end

COM_AddCommand("f12", changeDispPlayer)



-- ready (check ready status) (defunct)
-- ---
-- @player - userdata player
-- @scene - scene name

local function ready(player, scene)
	player.ready = true
	for player in players.iterate
		if player.playerstate == PST_LIVE and not player.ready
			return
		end
	end
	-- if (global == true)
	cutscene.startGlobal(scene)
	-- else
	-- cutscene.start(scene, player)
	-- 	print("Not for local yet!")
	-- end
end
rawset(_G, "ready", ready)
COM_AddCommand("ready", ready)



-- G_GetMap (GetMap)
-- ---
-- @map - string map to get
--
local function G_GetMap(map)

	-- Store all Alpha and Numeric
	local alphaLeft = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local alphaRight = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	-- Return map if not inside extended range
	if (map:sub(0, 1):find("%d") and map:sub(2,2):find("%d")) then
		--print(map)
		return map
	-- Check inside substrings for extended ranges
	elseif (map:sub(0, 1):find("%a") and map:sub(2, 2):find("%a"))
	or  (map:sub(0, 1):find("%a") and map:sub(2, 2):find("%d")) then
		local left = alphaLeft:find(map:sub(0, 1))
		--print(left-1)
		local right = alphaRight:find(map:sub(2, 2))
		--print(right-1)
		local leftA = left-1
		local rightA = right-1
		
		--print("Map " ..((36*leftA + rightA) + 100) )
		return ((36*leftA + rightA) + 100)
	else
		error("G_GetMap() entry '"..map.."' not recognized")
		return 0
	end
end
rawset(_G, "G_GetMap", G_GetMap)


local function xyzMod(point)
	
	local point_x, point_y, point_z
	
	if (point.x%FRACUNIT == 0) 
		point_x = point.x
	else
		point_x = point.x*FRACUNIT
	end
	
	if (point.y%FRACUNIT == 0) 
		point_y = point.y
	else
		point_y = point.y*FRACUNIT
	end
	
	if (point.z%FRACUNIT == 0) 
		point_z = point.z
	else
		point_z = point.z*FRACUNIT
	end

	return point_x, point_y, point_z
end
rawset(_G, "xyzMod", xyzMod)


-- P_TeleportMoveLocal (Local Position Teleport)
-- ---
-- @mo - object
-- @x y z - position
-- TeleportMove for objects that are not userdata
local function P_TeleportMoveLocal(mo, nx, ny, nz)
	-- TODO: instead of double xyz, swap with c_xyz
	local coords = {x = nx, y = ny, z = nz}
	--local mod_x, mod_y, mod_z = xyzMod(coords)
	
	if (type(mo) == "table") then
		mo.x = nx
		mo.y = ny
		mo.z = nz
	end
end

rawset(_G, "P_TeleportMoveLocal", P_TeleportMoveLocal)



rawset(_G, "FloatFixed", function(src)
	if src == nil then return nil end
	if not src:find("^-?%d+%.%d+$") then -- Not a valid number!
		--print("FAK U THIS NUMBER IS SHITE")
		if tonumber(src) then
			return tonumber(src)*FRACUNIT
		else
			return nil
		end
	end
	local decPlace = src:find("%.")
	local whole = tonumber(src:sub(1, decPlace-1))*FRACUNIT
	--print(whole)
	local dec = src:sub(decPlace+1)
	--print(dec)
	local decNumber = tonumber(dec)*FRACUNIT
	for i=1,dec:len() do
		decNumber = $1/10
	end
	if src:find("^-") then
		return whole-decNumber
	else
		return whole+decNumber
	end
end)

local function AngleToInt(value)
	local angle = AngleFixed(value)/FRACUNIT
	return angle
end
rawset(_G, "AngleToInt", AngleToInt)




-- TimeSec (convert float string to fixed time seconds)
-- ---
-- @in_value - string in_value

rawset(_G, "TimeSec", function(in_value) 
	return FixedMul(FloatF(in_value), 1000)
end)



-- TimeSecT (convert string number to ticrate in seconds)
-- ---
-- @in_value - string in_value

rawset(_G, "TimeSecT", function(in_value) 
	return (tonumber(in_value) * TICRATE)
end)



-- TimeMs (convert string number tics (ms))
-- ---
-- @in_value - string in_value

rawset(_G, "TimeMs", function(in_value) 
	return tonumber(in_value)
end)




-- *************************
-- Axis2D Function Extension
-- *************************

if axis2d then

	print("Axis2D Loaded")
	
-- axis2d.SetAxis
-- ---
-- @value - number

function axis2d.SetAxis(object, axisNumber)
	axis2d.SwitchAxis(object, axisNumber)
end


end

-------------------------------------------

local HALF_SCREEN_WIDTH_FIXED = 160<<FRACBITS
local HALF_SCREEN_HEIGHT_FIXED = 100<<FRACBITS
local FRACUNIT_X_9999 = 9999*FRACUNIT
local FRACUNIT = FRACUNIT
local ANGLE_90 = ANGLE_90
local ANGLE_270 = ANGLE_270
local R_PointToAngle2 = R_PointToAngle2
local FixedMul = FixedMul
local FixedDiv = FixedDiv

--Snippet function from RedEnchilada, converts world to screen cords
--Slightly modified to stop throwing divide by zero errors
local function R_GetScreenCoords(p, c, mx, my, mz)
    local camx, camy, camz, camangle, camaiming
    if p.awayviewtics then
        local mo = p.awayviewmobj
        camx = p.mo.x
        camy = mo.y
        camz = mo.z
        camangle = mo.angle
        camaiming = p.awayviewaiming
    elseif c.chase then
        camx = c.x
        camy = c.y
        camz = c.z
        camangle = c.angle
        camaiming = c.aiming
    else
        local mo = p.mo
        camx = mo.x
        camy = mo.y
        camz = mo.z+p.viewheight
        camangle = mo.angle
        camaiming = p.aiming
    end
    camaiming = FixedMul(HALF_SCREEN_WIDTH_FIXED, tan($1+ANGLE_90))
    
    local x = camangle-R_PointToAngle2(camx, camy, mx, my)
    local distfact = FixedMul(FRACUNIT, cos(x))
    if x > ANGLE_90 or x < ANGLE_270 then
        x = FRACUNIT_X_9999
    else
        x = FixedMul(tan(x+ANGLE_90), HALF_SCREEN_WIDTH_FIXED)+HALF_SCREEN_WIDTH_FIXED
    end
    
    local y = camz-mz

    if (calc1 ~= 0) then 
        y = FixedDiv(y, calc1)
    end
    
    y = (y*160)+HALF_SCREEN_HEIGHT_FIXED
    y = y+camaiming
    
    local scale = 0
    
    local calc2 = FixedMul(distfact, R_PointToDist2(camx, camy, mx, my))
    if (calc2 ~= 0) then
        scale = FixedDiv(HALF_SCREEN_WIDTH_FIXED, calc2)
    end
    --print(scale)
    
    return x, y, scale
end


rawset(_G, "R_GetScreenCoords", R_GetScreenCoords)