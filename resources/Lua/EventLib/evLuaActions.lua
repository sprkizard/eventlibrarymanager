
------------------------------------------------------------------------------------
-- EVENTMAN ACTION LIBRARY
------------------------------------------------------------------------------------

-------------------------------------------


rawset(_G, "CONSOLE", {})
rawset(_G, "CHAR", {})
rawset(_G, "SCREEN", {})
rawset(_G, "ACT", {})
rawset(_G, "SOUND", {})
rawset(_G, "CAMERA", {})
rawset(_G, "MAP", {})
rawset(_G, "OBJECT", {})







-->>>>>>>>>>>>>>>>>>>>>>>>>>>
-- "CONSOLE"
-->>>>>>>>>>>>>>>>>>>>>>>>>>>

function CONSOLE:disablejoining(setting)
	if (setting == true) then
		COM_BufInsertText(server, "allowjoin 0")
		print("\x82WARNING:\x80 server joining temporarily disabled")
	else
		COM_BufInsertText(server, "allowjoin 1")
		print("\x82WARNING:\x80 server joining re-enabled")
	end
end

function CONSOLE:forceshowhud(player)
	-- Someone will press f3 and it won't be me, get out of here with that
	COM_BufInsertText(player, "showhud 1")
end


-->>>>>>>>>>>>>>>>>>>>>>>>>>>
-- "CHAR"
-->>>>>>>>>>>>>>>>>>>>>>>>>>>

function CHAR:GetComponent(player, componentType)
	if (player and player.valid) then
		if (componentType == "camera")
			if (player.mo.cam) then
				return player.mo.cam
			end
		end
	end
end



-->>>>>>>>>>>>>>>>>>>>>>>>>>>
-- "ACT"
-->>>>>>>>>>>>>>>>>>>>>>>>>>>
--[[
function ACT:startAnimation(mo, first, last, tics, forceRestart)
	if mo.animstartmarker == first and not forceRestart then return end
	
	mo.animstartmarker = first
	mo.animprocess = runProcess(loopStates, mo, first, last, tics)
end

function ACT:stopAnimation(mo)
	if mo.animprocess then
		killProcess(mo.animprocess)
	end
	mo.animprocess = nil
	mo.animstartmarker = nil
end

rawset(_G, "AnimState", function(mobj, start, last)
	if not (mobj.state >= start)
	and (mobj.state <= last)
		mobj.state = start
	end
	waitSeconds(0)
end)

rawset(_G, "loopStates", function(mo, first, last, tics)
	local cur = first
	local wait = 0
	while true do
		mo.state = cur
		wait = $1+1
		if wait >= tics then
			wait = $1-tics
			cur = $1+1
			if cur > last then
				cur = first
			end
		end
		waitSeconds(0)
	end
end)

rawset(_G, "loopFrames", function(mo, sprite, first, last, tics, loop)
	local cur = first
	local wait = 0
	if (mo) then
		while true do
			if (mo and mo.valid) then
				mo.frame = cur
				mo.sprite = sprite
				wait = $1+1
				if wait >= tics then
					wait = $1-tics
					cur = $1+1
					if cur > last then
						if (type(loop) == "boolean" and loop) then
							cur = first
						elseif (type(loop) == "number" and loop) then
							while true do
								if first == last then
									if (wait >= loop) then
										loop = nil
										cur = last
										mo.frame = cur
										mo.sprite = sprite
										ACT:stopSprAnim(mo)
										break
									end
									mo.frame = last
								else
									if (wait >= loop) then
										loop = nil
										cur = last
										mo.frame = cur
										mo.sprite = sprite
										ACT:stopSprAnim(mo)
										break
									end
									if cur > last then
										cur = first
									end
									
									mo.frame = cur
									if wait % tics == 0 then cur = $1+1 end
								end
								mo.sprite = sprite
								wait = $1+1
								--print(wait..": waiting...")			
								waitSeconds(0)
							end
						else	
							cur = last
							ACT:stopSprAnim(mo)
							--print("no loop")
							break
						end
					end
				end
			end
			waitSeconds(0)
		end
	end
end)

function ACT:startSprAnim(mo, sprite, first, last, tics, loop, seprate, forceRestart)	
	ACT:stopSprAnim(mo)
	
	if mo.spranimstartmarker == first and not forceRestart then return end

	mo.spranimstartmarker = first
	if (seprate) then
		--mo.spranimprocess = runProcess(loopFrames, mo, sprite, first, last, tics, loop)
		mo.spranimprocess = TASK:Regist(function()  
			loopFrames(mo, sprite, first, last, tics, loop)
		end)
	else
		loopFrames(mo, sprite, first, last, tics, loop)
	end
end

function ACT:stopSprAnim(mo)
	if mo.spranimprocess then
		killProcess(mo.spranimprocess)
	end
	mo.spranimprocess = nil
	mo.spranimstartmarker = nil
end

function ACT:swapSprite(mo, spriteN)
	mo.sprite = spriteN
end
]]


-->>>>>>>>>>>>>>>>>>>>>>>>>>>
-- "SCREEN"
-->>>>>>>>>>>>>>>>>>>>>>>>>>>


function SCREEN:SetWipe(player, Properties)
	player.hudOptions.wipe = Properties
end

--SCREEN:FADE_IN = 10
--SCREEN:FADE_OUT = 0

function SCREEN:SetFade(player, Properties)
	player.hudOptions.wipe = Properties
end

--[[
function SCREEN:Talk(v, nameOfIndex, user, actor, text, useConfig)
	Speak(v, nameOfIndex, user, actor, text, useConfig)
end


function SCREEN:SetSelectionItems(nameOfIndex, user, cursorsfx, choicesfx, items, selChoiceStart) 
	SetTextConfig(nameOfIndex, user, {selectsfx = cursorsfx,
			idsfx = choicesfx,
			selectNum = selChoiceStart or 1, 
			selection = items})
end

function SCREEN:StartSelectChain(v, nameOfIndex, user) 
	Speak(v, nameOfIndex, user, nil, nil, true)
end

function SCREEN:StartSelection(nameOfIndex, user, cursorsfx, choicesfx, items, selChoiceStart) 
	SetTextConfig(nameOfIndex, user, {selectsfx = cursorsfx,
			idsfx = choicesfx,
			selectNum = selChoiceStart or 1, 
			selection = items})
	Speak(v, nameOfIndex, user, nil, nil, true)
end
]]



-->>>>>>>>>>>>>>>>>>>>>>>>>>>
-- "SOUND"
-->>>>>>>>>>>>>>>>>>>>>>>>>>>

function SOUND:PlayBGM(player, BGM, loop, vol, ply)
	if ply == true
		S_ChangeMusic(BGM, loop, player)
		if not (vol == nil) then
			COM_BufInsertText(player, "DIGMUSICVOLUME "+vol)
		end
	else
		S_ChangeMusic(BGM, loop)
		if not (vol == nil) then
			COM_BufInsertText(player, "DIGMUSICVOLUME "+vol)
		end
	end
end

function SOUND:BgmFadeOut(player, timesec)
end

function SOUND:BgmFadeIn(player, timesec)
end

function SOUND:SetBGMFade(player, volumeValue, timeTic)
end

function SOUND:SetBGMVolume(player, vol)
end

function SOUND:PlaySFX(mo, SE, VOL, player)
	if VOL then
		S_StartSoundAtVolume(mo, SE, VOL, player)
	else
		S_StartSound(mo, SE, player)
	end
end
--[[
function SOUND:stopEnvSound(mo)
	if mo then 
		if mo.envprocess then
			killProcess(mo.envprocess)
		end
		mo.envprocess = nil
		S_StopSound(mo)
	else
		if globalenvprocess then
			killProcess(globalenvprocess)
		end
		globalenvprocess = nil
	end
end

function SOUND:startEnvSound(mo, sfx, player)
	stopEnvSound(mo)
	
	if mo then
		mo.envprocess = runProcess(function()
			while true do 
				if not S_SoundPlaying(mo, sfx) then 
					S_StartSound(mo, sfx, player)
				end 
				waitSeconds(0) 
			end
		end)
	else
		globalenvprocess = runProcess(function()
			while true do 
				if not S_IdPlaying(sfx) then 
					S_StartSound(nil, sfx, player)
				end 
				waitSeconds(0) 
			end
		end)
	end
end
]]


-->>>>>>>>>>>>>>>>>>>>>>>>>>>
-- "CAMERA"
-->>>>>>>>>>>>>>>>>>>>>>>>>>>
function CAMERA:override(player, bool, enableControls)
	if player.mo.cam and player.mo.cam.valid
		if bool and not player.mo.cam.override then
			player.mo.cam.momz = 0
		end
		player.mo.cam.override = bool
		
		player.mo.cam.ctrl = enableControls or false
	end
end

--[[
function CAMERA:netOverride(player, serv, args, enablecontrols)
	netgameCamOverride(player, serv, args, enablecontrols)
end

function CAMERA:release(player)
	if player.camprocess then
		killProcess(player.camprocess)
		player.camprocess = nil
	end
end

function CAMERA:SetEye(player, position, aiming)

	local pos_x, pos_y, pos_z = xyzMod(position)
	if player.mo.cam
		player.awayviewmobj = player.mo.cam
		player.awayviewaiming = position.aiming or aiming or 0
		
		CAMERA:release(player)
		player.camprocess = runProcess(function()
			while true do
				if not player.valid then break end
				player.awayviewtics = 2
				P_TeleportMove(player.mo.cam, position.x, position.y, position.z)
				--P_TeleportMove(player.mo.cam, pos_x, pos_y, pos_z)
				--player.mo.cam.angle = position.angle or 0
				player.awayviewmobj.angle = position.angle or 0
				waitSeconds(0)
				if not (player.mo.cam and player.mo.cam.valid and (
					type(position) ~= "userdata" or position.valid
				))
					break
				end
			end
		end)
	end
end	

function CAMERA:UnsetEye(player, aiming)
	if (player.valid) then
		player.awayviewmobj = player.mo.cam
		player.awayviewaiming = aiming or 0
		
		CAMERA:release(player)
		player.camprocess = runProcess(function()
			while player and player.valid and player.health do
				player.awayviewtics = 2
				waitSeconds(0)
				if not (player.mo.cam and player.mo.cam.valid)
					break
				end
			end
		end)
	end
end

function CAMERA:lookAt(mo, dest, setangle)
	OBJECT:lookAt(mo, dest, setangle)
end

function CAMERA:lookAtZ(player, destination, setangle)
	local x1 = player.mo.cam.x
	local y1 = player.mo.cam.y
	local z1 = player.mo.cam.z
	--local x1 = player.awayviewmobj.x
	--local y1 = player.awayviewmobj.y
	--local z1 = player.awayviewmobj.z
	
	local x2 = destination.x
	local y2 = destination.y
	local z2 = destination.z
	
	if (setangle) then
		CAMERA:UnsetEye(player, R_PointToAngle2(0, 0, FixedHypot(x2 - x1, y2 - y1), z2 - z1))
	else
		return R_PointToAngle2(0, 0, FixedHypot(x2 - x1, y2 - y1), z2 - z1)	
	end
end

function CAMERA:SetRotateZ(player, rotateAngle)
	if (player.mo.valid) then
		player.viewrollangle = rotateAngle
	end
end]]


-->>>>>>>>>>>>>>>>>>>>>>>>>>>
-- "OBJECT"
-->>>>>>>>>>>>>>>>>>>>>>>>>>>

function OBJECT:setAnimState(mo, state)
	if mo and mo.valid
		mo.state = state
	end
end

function OBJECT:setscale(mo, scale, speed)
	if mo and mo.valid
		if speed then
			mo.destscale = scale
			mo.scalespeed = speed
		else
			mo.scale = scale
		end
	end
end

function OBJECT:setgroupscale(mobjs, scale, speed)
	for _,v in pairs(mobjs)
		if v and v.valid
			if speed then
				v.destscale = scale
				v.scalespeed = speed
			else
				v.scale = scale
			end
		end
	end
end

function OBJECT:showobject(mo, setting)
	if mo and mo.valid
		if (setting) then 
			mo.flags2 = $1|MF2_DONTDRAW
		else
			mo.flags2 = $1&~MF2_DONTDRAW
		end
		
	end
end

function OBJECT:setPosition(mo, position)
	if mo and mo.valid
		P_TeleportMove(mo, position.x, position.y, position.z)
		if coroutine.running() then waitSeconds(0) end
	end
end

function OBJECT:translate(mo, x, y, z)
	P_TeleportMove(mo, x, y, z)
	--P_TeleportMove(mo, x*FRACUNIT, y*FRACUNIT, z*FRACUNIT)
end

function OBJECT:translateLocal(mo, point)
	P_TeleportMoveLocal(mo.localSpace, point.x, point.y, point.z)
end
	

rawset(_G, "TWEENS", {
	["easeIn"] = {0,0},
	["easeOut"] = {FRACUNIT,FRACUNIT},
	["easeInOut"] = {0,FRACUNIT},
})
local tween_meta = {
	__call = function(tween_meta, ent, amount)
		return {
			tween_meta[ent][1] + FixedMul((FRACUNIT*1/3)-tween_meta[ent][1], FRACUNIT-(amount or FRACUNIT)),
			tween_meta[ent][2] + FixedMul((FRACUNIT*2/3)-tween_meta[ent][2], FRACUNIT-(amount or FRACUNIT)),
		}
	end
}
TWEENS = setmetatable(TWEENS, tween_meta)


-- delta, p1, p2 are all fixed point
local function bezier(delta, p1, p2)
	-- first iteration
	local p0 = FixedMul(p1, delta)
	p1 = $ + FixedMul(p2-p1, delta)
	p2 = $ + FixedMul(FRACUNIT-p2, delta)
	
	-- second iteration
	p0 = $+FixedMul(p1-p0, delta)
	p1 = $+FixedMul(p2-p1, delta)
	
	-- final pointp
	return p0 + FixedMul(p1-p0, delta)
end
--[[
-- bezier debug stuff
if true then
	local p1 = CV_RegisterVar({"p1", FRACUNIT/3, 0, C_Unsigned})
	local p2 = CV_RegisterVar({"p2", FRACUNIT*2/3, 0, C_Unsigned})
	
	hud.add(function(v)
		for x = 0, 100 do
			local y = FixedMul(bezier(FixedDiv(x, 100), p1.value, p2.value), 100)
			v.drawFill(x+100, y+50, 1, 1, 160)
		end
	end)
end
]]

function OBJECT:moveTo(mo, point, speed, props)--arc, tween)
	if mo and mo.valid then
		local dx = point.x - mo.x -- Obtain vector.
		local dy = point.y - mo.y
		local dz = point.z - mo.z
		local dm = FixedHypot(dz, FixedHypot(dx, dy))
		
		local percent_per_frame = FixedDiv(speed, dm)+1
		local move_time = 0
		local move_delta = 0
		local old_move_offset = {x=0,y=0,z=0}
				-- props.rad
				-- props.rotate
		while move_time < FRACUNIT do
			move_time = $+percent_per_frame
			
			if props and props.tween then
				move_delta = bezier(move_time, props.tween[1], props.tween[2])
			else
				move_delta = move_time
			end
			
			local move_offset = {
				x = FixedMul(dx, move_delta),
				y = FixedMul(dy, move_delta),
				z = FixedMul(dz, move_delta),
			}
			
			if props and props.angle then
				mo.angle = props.angle
			else
				--mo.angle = $1
			end
			
			if props and props.arc then
				local ang = FixedMul(ANGLE_180, move_delta)
				move_offset.x = $-FixedMul(props.arc.x or 0, sin(ang))
				move_offset.y = $-FixedMul(props.arc.y or 0, sin(ang))
				move_offset.z = $-FixedMul(props.arc.z or 0, sin(ang))
			end
			
			P_TeleportMove(mo,
				mo.x + move_offset.x - old_move_offset.x,
				mo.y + move_offset.y - old_move_offset.y,
				mo.z + move_offset.z - old_move_offset.z
			)
			
			old_move_offset = move_offset
			
			if coroutine.running() then wait(0) end
			if not (mo and mo.valid) then
				return
			end
		end
		
		if not (mo and mo.valid) or no_lock then
			return
		end	
		P_TeleportMove(mo, point.x, point.y, point.z) -- Teleport one more time to lock the mobj into the target position.
		if rotate then
			mo.angle = point.angle
		end
		--[[
		local point_x, point_y, point_z = xyzMod(point)
		
		if mo and mo.valid 
			while R_PointToDist2(R_PointToDist2(mo.x, mo.y, point_x, point_y), mo.z, 0, point_z) > rad*FRACUNIT do
			end
		end]]
	end
end

function OBJECT:setAnglePoint(mo, dest)
	return R_PointToAngle2(mo.x, mo.y, dest.x, dest.y)
end

function OBJECT:lookAt(mo, dest, setangle)
	if (setangle) then
		mo.angle = R_PointToAngle2(mo.x, mo.y, dest.x, dest.y)
	else
		return R_PointToAngle2(mo.x, mo.y, dest.x, dest.y)
	end
end
	
function OBJECT:setAngle(mo, angle)
	if (mo and mo.valid) then
		mo.angle = angle
	end
end

function OBJECT:Find(objectType, data, search_doomednum)
	for mobjs in thinkers.iterate("mobj")
		if (data) then
			if (search_doomednum) then
				-- Search by doomednum
				if (mobjinfo[mobjs.type].doomednum == objectType) 
				and ((data.flags == nil) or (mobjs.flags & data.flags))
				and ((data.options == nil) or (mobjs.spawnpoint.options & data.options))
				and ((data.angle == nil) or (mobjs.spawnpoint.angle == data.angle))
				and ((data.id == nil) or (mobjs.spawnpoint.extrainfo == data.id))
				--and ((data.idval == nil) or (mobjs.extrainfo == data.idval))
				and (mobjs.valid)
					return mobjs
				end
			else
				-- Search by object type
				if (mobjs.type == objectType) 
				and ((data.flags == nil) or (mobjs.flags & data.flags))
				and ((data.options == nil) or (mobjs.spawnpoint.options & data.options))
				and ((data.angle == nil) or (mobjs.spawnpoint.angle == data.angle))
				and ((data.id == nil) or (mobjs.spawnpoint.extrainfo == data.id))
				--and ((data.idval == nil) or (mobjs.extrainfo == data.idval))
				and (mobjs.valid)
					return mobjs
				end
			end
		else
			if (mobjs.type == objectType) 
			and (mobjs.valid)
				return mobjs
			end
		end
	end
end

	
function OBJECT:CreateNew(objectType, loc, param)
	local point_x, point_y, point_z
	if (type(loc) == "userdata" and loc.valid) then
		point_x = loc.x
		point_y = loc.y
		point_z = loc.z
	else
		point_x, point_y, point_z = loc.x, loc.y, loc.z
	end
	--local point_x, point_y, point_z = xyzMod(loc)
	
	--local newspawn = P_SpawnMobj(point_x,point_y,point_z, objectType)
	local newspawn = P_SpawnMobj(loc.x, loc.y, loc.z, objectType)
	
	-- Set any kind of extra info on spawn
	newspawn.extrainfo = ((param != nil and param.id != nil) and param.id) or 0
	--newspawn.spawnangle = ((param != nil and param.spawnangle != nil) and param.spawnangle) or 0
	return newspawn
end

function OBJECT:CreateObjects(...)
	local rets = {}
	for k,v in ipairs({...})
		--OBJECT:CreateNew(v.obj, v.loc)
		table.insert(rets, OBJECT:CreateNew(v.obj, v.loc, {v.id} or nil))--unpack(list)
	end
	return unpack(rets)
end

function OBJECT:DestroyObjects(objects)
	for _,v in pairs(objects)
		P_RemoveMobj(v)
	end
end



------------------------------------------------------------------------------------
-- EVENTMAN 'THINKER' ACTION LIBRARY
------------------------------------------------------------------------------------






--<><><><><><><><><><><><><><><>
-- "CONSOLE"
--<><><><><><><><><><><><><><><>

--<><><><><><><><><><><><><><><>
-- "CHAR"
--<><><><><><><><><><><><><><><>

--<><><><><><><><><><><><><><><>
-- "ACT"
--<><><><><><><><><><><><><><><>

--<><><><><><><><><><><><><><><>
-- "SCREEN"
--<><><><><><><><><><><><><><><>

--<><><><><><><><><><><><><><><>
-- "SOUND"
--<><><><><><><><><><><><><><><>

--<><><><><><><><><><><><><><><>
-- "CAMERA"
--<><><><><><><><><><><><><><><>

function CAMERA:t_override(event, player, bool, enableControls)
	if player.mo.cam and player.mo.cam.valid
		if bool and not player.mo.cam.override then
			player.mo.cam.momz = 0
		end
		player.mo.cam.override = bool
		
		player.mo.cam.ctrl = enableControls or false
	end
end

function CAMERA:t_netOverride(event, player, serv, args, enablecontrols)
	netgameCamOverride(player, serv, args, enablecontrols)
end

function CAMERA:t_release(player)
	if player.camprocess then
		player.camprocess:stop()
		player.camprocess = nil
	end
end

function event_states.CameraTSetEye(event)
	local player = event.player
	local position = event.position
	
	if not player.valid then
		event:stop()
		return
	end
	
	if player.camprocess ~= event then
		event:stop()
		return
	end
	
	if not (player.mo.cam and player.mo.cam.valid and (
		type(position) ~= "userdata" or position.valid
	))
		event:stop()
		return
	end

	player.awayviewtics = 2
	P_TeleportMove(player.mo.cam, position.x, position.y, position.z)
	--player.mo.cam.angle = position.angle or 0
	player.awayviewmobj.angle = position.angle or 0
end

function CAMERA:t_SetEye(player, position, aiming)

	if player.mo.cam
		player.awayviewmobj = player.mo.cam
		player.awayviewaiming = position.aiming or aiming or 0
		
		CAMERA:t_release(player)

		P_TeleportMove(player.mo.cam, position.x, position.y, position.z)
		player.camprocess = startEvent("CameraTSetEye")
		player.camprocess.player = player
		player.camprocess.position = position
	end
end	

function event_states.CameraTUnsetEye(event)
	local player = event.player

	if not (player and player.valid and player.health) then
		event:stop()
		return
	end
	if not (player.mo.cam and player.mo.cam.valid) then
		event:stop()
		return
	end
	
	player.awayviewtics = 2
end

function CAMERA:t_UnsetEye(player, aiming)
	--print("do?")
	if (player.valid) then
		--print("do!")
		player.awayviewmobj = player.mo.cam
		player.awayviewaiming = aiming or 0

		CAMERA:t_release(player)
		player.camprocess = startEvent("CameraTUnsetEye")
		player.camprocess.player = player
	end
end

function CAMERA:t_lookAt(mo, dest, setangle)
	OBJECT:lookAt(mo, dest, setangle)
end

function CAMERA:t_lookAtZ(player, destination, setangle)
	local x1 = player.mo.cam.x
	local y1 = player.mo.cam.y
	local z1 = player.mo.cam.z
	--local x1 = player.awayviewmobj.x
	--local y1 = player.awayviewmobj.y
	--local z1 = player.awayviewmobj.z
	
	local x2 = destination.x
	local y2 = destination.y
	local z2 = destination.z
	
	local aiming = R_PointToAngle2(0, 0, FixedHypot(x2 - x1, y2 - y1), z2 - z1)
	
	if (setangle) then
		player.awayviewaiming = aiming
		--CAMERA:t_UnsetEye(player, aiming)
	end
	
	return aiming
end
--[[
local TANBOUNDX = tan(ANGLE_45, true)
local TANBOUNDY = tan(ANG1*65/2, true)

local function P_ReturnCamBounds(dist)
	return FixedMul(TANBOUNDX, dist), FixedMul(TANBOUNDY, dist)
end

function CAMERA:t_checkawayviewbounds(player)
	
	if (player and player.awayviewmobj)
		local xboundary, yboundary = P_ReturnCamBounds( player.mo.y - player.awayviewmobj.y)	

		if player.mo.x > player.awayviewmobj.x+xboundary then
			--print("out right")
			P_TeleportMove(player.mo, xboundary, player.mo.y, player.mo.z)
		end
		if player.mo.x < player.awayviewmobj.x-xboundary then
			---print("out left")
			P_TeleportMove(player.mo, -xboundary, player.mo.y, player.mo.z)
		end
		if player.mo.z > player.awayviewmobj.z+yboundary then
			--print("out up")
			P_TeleportMove(player.mo, player.mo.x, player.mo.y, yboundary)
		end
		if player.mo.z < player.awayviewmobj.z-yboundary then
			--print("out down")
			P_TeleportMove(player.mo, player.mo.x, player.mo.y, -yboundary)
		end
	end
end
]]
--<><><><><><><><><><><><><><><>
-- "EFFECT"
--<><><><><><><><><><><><><><><>

--<><><><><><><><><><><><><><><>
-- "MAP"
--<><><><><><><><><><><><><><><>

--<><><><><><><><><><><><><><><>
-- "OBJECT"
--<><><><><><><><><><><><><><><>


--rawset(_G, "turnTo", function(mo, dest)
--	return R_PointToAngle2(mo.x, mo.y, dest.x, dest.y)
--end)

function OBJECT:eventMoveTo(event, mo_name, point_name, speed_name, props_name)
	local mo, point, speed, props
	mo = event[mo_name] or mo_name
	point = event[point_name] or point_name
	speed = event[speed_name] or speed_name
	props = event[props_name] or props_name
	
	event:once(do
		local vars = {
			dx = point.x - mo.x,
			dy = point.y - mo.y,
			dz = point.z - mo.z,
		}
		vars.dm = FixedHypot(vars.dz, FixedHypot(vars.dx, vars.dy))
		
		vars.percent_per_frame = FixedDiv(speed, vars.dm)+1
		vars.move_time = 0
		vars.old_move_offset = {x=0,y=0,z=0}
		
		event.moveTo_VARS = vars
	end)
	event:doWhile(do
		local vars = event.moveTo_VARS
		vars.move_time = $+vars.percent_per_frame
		
		local move_delta
		if props and props.tween then
			move_delta = bezier(vars.move_time, props.tween[1], props.tween[2])
		else
			move_delta = vars.move_time
		end
		
		local move_offset = {
			x = FixedMul(vars.dx, move_delta),
			y = FixedMul(vars.dy, move_delta),
			z = FixedMul(vars.dz, move_delta),
		}
		
		if props and props.angle then
			mo.angle = props.angle
		else
			--mo.angle = $1
		end
		
		if props and props.arc then
			local ang = FixedMul(ANGLE_180, move_delta)
			move_offset.x = $-FixedMul(props.arc.x or 0, sin(ang))
			move_offset.y = $-FixedMul(props.arc.y or 0, sin(ang))
			move_offset.z = $-FixedMul(props.arc.z or 0, sin(ang))
		end
		
		P_TeleportMove(mo,
			mo.x + move_offset.x - vars.old_move_offset.x,
			mo.y + move_offset.y - vars.old_move_offset.y,
			mo.z + move_offset.z - vars.old_move_offset.z
		)
		
		vars.old_move_offset = move_offset
		
		if not (mo and mo.valid) then
			return false
		end
		
		return vars.move_time < FRACUNIT
	end)
	event:once(do
		P_TeleportMove(mo, point.x, point.y, point.z) -- Teleport one more time to lock the mobj into the target position.
		event.moveTo_VARS = nil
	end)
end
