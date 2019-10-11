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



-- TODO: Change to player hook
addHook("ThinkFrame", do

	for player in players.iterate
		
		CreateCustomPlayerCamera(player.mo)
		IndPlayerScreenWipe(player)
	end
end)
