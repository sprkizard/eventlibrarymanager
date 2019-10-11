local function CreateCustomPlayerCamera(mo)
	
	local pmo = mo
	if pmo.aimtarget == nil then
		pmo.aimtarget = mo
	end
	if pmo.cam == nil
		--pmo.cam = P_SpawnMobj(pmo.x,pmo.y+444*FRACUNIT, pmo.z, MT_PCAM)	
		pmo.cam = P_SpawnMobj(pmo.x,pmo.y+444*FRACUNIT, pmo.z, MT_PULL)	
	end

	pmo.cam.fuse = 10
end

local function IndPlayerScreenWipe(player)	
	if (player.hudOptions and player.hudOptions.wipe) then
		local wipe = player.hudOptions.wipe
		if (player.hudOptions.wipe.set) then
			if (player.hudOptions.wipe.flash) then player.hudOptions.wipe.dest = $1 return end
			if (leveltime % (player.hudOptions.wipe.Time or 1) == 0)
				player.hudOptions.wipe.dest = max($1-1, wipe.middest or 0)
			end
		else
			if (player.hudOptions.wipe.flash) then player.hudOptions.wipe.dest = $1 return end
			if (leveltime % (player.hudOptions.wipe.Time or 1) == 0)
				player.hudOptions.wipe.dest = min($1+1, wipe.middest or 10)
			end
		end
	end
end


-- Draws a shadow sprite under the player character
--[[
local function handlePlayerShadows(mo)
	-- TODO: a very very cheap hack to only show in software
	
	-- Shortcut player
	local player = mo.player

	if (player.valid) then
		
		-- check if the player is dead (or should they keep it?)
		if (player.health) and not (player.mo.shadow)
			-- Spawn the shadow
			player.mo.shadow = P_SpawnMobj(player.mo.x,
							player.mo.y, 
							player.mo.z,
							ObjM("soft_shadow"))
			-- Handled in the shadow object, to always follow
			-- the player
			player.mo.shadow.target = player.mo
		end
	end
end
]]


----------------------------------------------------------------------------

-- Todo: Create guide

local enum_DataType =
{
	PARAMETER = 0,
	ANGLES = 1,
	FLAGS = 2,
}

-- A linedef executor for focusing the analog-like player camera
-- on objects, or more
addHook("LinedefExecute", function(line, mo, sector)
	
	local cam = mo.cam
	
	local pointer = nil
	if cam and cam.valid
	if line.flags & ML_EFFECT1 then
		cam.pointer_obj = {
			valid = true,
			x = line.frontside.textureoffset,
			y = line.frontside.rowoffset,
			angle = 0
		}
	-- Search for Default Object
	elseif line.flags & ML_EFFECT2 then
		local obj_type = MT_PUSH --ObjM("campoint") -- get
		if not (
			cam.pointer_obj and cam.pointer_obj.valid and
			cam.pointer_obj.type == obj_type
		) then
			cam.pointer_obj = OBJECT:Find(obj_type, {id=line.tag})
		end
	-- Search By Object Type
	elseif line.flags & ML_EFFECT3 then
		local obj_type = line.frontside.textureoffset/FRACUNIT
		local data_type = line.frontside.rowoffset/FRACUNIT
		
		if not (
			cam.pointer_obj and cam.pointer_obj.valid and
			cam.pointer_obj.type == obj_type
		) then
			-- Search Data Types by row
			if (data_type == enum_DataType.PARAMETER) then
				cam.pointer_obj = OBJECT:Find(obj_type, {id=line.tag}, true)
			elseif (data_type == enum_DataType.ANGLES) then
				-- n/a
			elseif (data_type == enum_DataType.FLAGS) then
				-- n/a
			end
		end
	else
		cam.pointer_obj = nil
	end
	
	cam.destination = {
		angle     = R_PointToAngle2(line.v1.x, line.v1.y, line.v2.x, line.v2.y),
		elevation = line.frontsector.floorheight,
		distance  = R_PointToDist2(line.v1.x, line.v1.y, line.v2.x, line.v2.y),
	}
	
	-- Use pointer object's angle as an offset to angle the camera away from it
	if line.flags & ML_NOCLIMB then
		cam.destination.angle = nil
		cam.pointer_offset_use = 1
	else
		cam.pointer_offset_use = 0
	end
	end
end, "setCam")

//--focus cam on angle
//--focus cam on object


-- This sets up and handles an analog-like camera
-- where it adjusts itself based on the position the player 
-- character is facing
local function handlePlayerAnalogCamera(mo)
	-- TODO: Handle teleporters and moving outside of
	-- noclippable walls (because the camera gets badly stuck)
	-- TODO: comment this in full detail

	local player = mo.player
	local p_cam = mo.cam
	local self = mo
	--if not player.cutscene
	if p_cam and p_cam.valid then
		if not p_cam.override then
			p_cam.depth_offset = ($ or 0)+(cos(mo.angle-p_cam.angle)*56 - ($ or 0))/20
			
			-- Handle tweening
			if p_cam.destination then
				-- Point toward object if exists
				if p_cam.pointer_obj and p_cam.pointer_obj.valid then
					p_cam.destination.angle = R_PointToAngle2(
						mo.x, mo.y, p_cam.pointer_obj.x, p_cam.pointer_obj.y
					) + p_cam.pointer_obj.angle*p_cam.pointer_offset_use
				end
				
				if not p_cam.sliding then
					p_cam.sliding = {
						angle = p_cam.destination.angle,
						elevation = p_cam.destination.elevation,
						distance = p_cam.destination.distance,
					}
					if p_cam.sliding.angle == nil then
						p_cam.sliding.angle = p_cam.angle
					end
				end
				
				for k,v in pairs(p_cam.destination) do
					local maxmove = FRACUNIT
					if k == "angle" then maxmove = ANG1*3 end
					p_cam.sliding[k] = $ + min(max(v - $, -maxmove), maxmove)
				end
				
				if p_cam.destination.angle == nil then
					p_cam.sliding.angle = $ - player.cmd.sidemove*FRACUNIT*4
						+ (mo.angle - $)/600
				end
				
				for k,v in pairs(p_cam.sliding) do
					p_cam[k] = ($ or 0) + (v - ($ or 0)) / 20
					--print(k.." "..p_cam[k])
				end
				
				local x_off = -FixedMul(cos(p_cam.angle), (p_cam.distance-p_cam.depth_offset))
				local y_off = -FixedMul(sin(p_cam.angle), (p_cam.distance-p_cam.depth_offset))
				local z_off = p_cam.elevation
				--OBJECT:teleport(p_cam, mo.x+x_off, mo.y+y_off, mo.z+z_off)
				
				p_cam.flags = ($ & ~(MF_NOCLIP|MF_NOCLIPHEIGHT)) | MF_SLIDEME
				
				p_cam.momx = mo.x + x_off - p_cam.x
				p_cam.momy = mo.y + y_off - p_cam.y
				p_cam.momz = mo.z + z_off - p_cam.z
				
				--[[if P_AproxDistance(p_cam.momx, p_cam.momy) > 100*FRACUNIT then
					OBJECT:teleport(p_cam, mo.x, mo.y, mo.z)
					while P_AproxDistance(x_off, y_off) > FRACUNIT/4 do
						x_off = $/2
						y_off = $/2
						P_TryMove(p_cam, p_cam.x+x_off, p_cam.y+y_off, true)
					end
					p_cam.momz = z_off
				end]]--
				
				if not P_TryMove(p_cam, p_cam.x+p_cam.momx, p_cam.y+p_cam.momy, true) then
					P_SlideMove(p_cam)
				end
				p_cam.momx = 0
				p_cam.momy = 0
				p_cam.angle = R_PointToAngle2(p_cam.x, p_cam.y, mo.x, mo.y)
				--p_cam.angle = turnTo(p_cam, mo)

				--CAMERA:UnsetEye(player, R_PointToAngle2(0, 0, p_cam.distance, 20*FRACUNIT-p_cam.elevation))
				player.awayviewmobj = p_cam
				player.awayviewtics = 2
				player.awayviewaiming = R_PointToAngle2(0, 0, p_cam.distance, 20*FRACUNIT-p_cam.elevation)
			else
				p_cam.destination = {
					angle = nil,
					distance = 210*FRACUNIT, --321
					elevation = 32*FRACUNIT --80
				}
			end
			COM_BufInsertText(player, "analog on")
		else
			p_cam.flags = ($ | (MF_NOCLIP|MF_NOCLIPHEIGHT)) & ~MF_SLIDEME
			p_cam.destination = nil
			p_cam.sliding = nil
			p_cam.pointer_obj = nil
		end
	end
	--end
	
end

rawset(_G, "setAnalogCamera", function(player, data)
	local pmo = player.mo
	
	if (pmo.cam and pmo.cam.valid) then
		// Setting to offset camera using angle ie inverse
		if (data.offset) then
			pmo.cam.destination.angle = nil
			pmo.cam.pointer_offset_use = 1
		else
			pmo.cam.pointer_offset_use = 0
		end
		// Data inserted for the target object to look to
		pmo.cam.pointer_obj = {
			valid = data.valid,
			x = data.x,
			y = data.y,
			angle = data.angle or 0,
		}
		// Second data for destination ( ? )
		pmo.cam.destination = {
			angle     = data.angle or 0,
			elevation = data.elevation,
			distance = data.distance,
		}
	end

end)
rawset(_G, "handlePlayerAnalogCamera", handlePlayerAnalogCamera)

addHook("MobjThinker", function(mo)
	
	local player = mo.player
	-- Create a custom camera
	CreateCustomPlayerCamera(player.mo)
	IndPlayerScreenWipe(player)
	
	-- Handle analog camera
	handlePlayerAnalogCamera(mo)
	--setAnalogCamera(player, {valid = true, x=0*FRACUNIT, y=0*FRACUNIT,elevation=64*FRACUNIT, distance=122*FRACUNIT})
	
	-- Handle drawing shadows
	--handlePlayerShadows(mo)
	
end, MT_PLAYER)

-- TODO: Change to player hook
--[[
addHook("ThinkFrame", do

	for player in players.iterate
		CreateCustomPlayerCamera(player.mo)
		IndPlayerScreenWipe(player)
	end
end)
]]
