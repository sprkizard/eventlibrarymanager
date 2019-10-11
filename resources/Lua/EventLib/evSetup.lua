
-- EventMan Hud
rawset(_G, "EVM_HUD", {})

--EvenMan Hooks
rawset(_G, "EVM_HOOK", {})


rawset(_G, "eventIndex", {})
rawset(_G, "events", {})


rawset(_G, "event", {})


addHook("MapLoad", do
	for player in players.iterate do
		-- Player draw renders
		player.renders = {}
		-- Player textStorage for use database
		player.rTextStore = {}
		--player.coroutine = {}
		-- Player textStorage default index
		player.textStore = {
			lineTimer = 0,
			speaker = " ",
			text = " ",
			player = player,
			useTextConfig = false,
			textConfig = {},
			textOptions = {
				auto = false,
				autotime = 3*TICRATE,
				sPos = 0, -- StartPosition
				speed = 1,
				slowspeed = 1,
				ticksfx = sfx_none,
				selection = nil,
				selectNum = 1,
				selectId = nil
			},
		}
		player.hudOptions = {
			disabled = false,
			hidden = false,
			hpHudHidden = false,
			hideValue = 0,
			widescreen = {enabled = false, wideframe = 0},
			wipe = {set = false, pic = "", dest = 10, start = 10, Time = 1, flash = false}
		}
	end
end)


-- Call rendering into the drawing layer
--local renders = {}
rawset(_G, "renders", {}) -- global safe some day?


-- render
-- ---
-- @v - hud hook v
-- @n - name
-- @func - function
-- I guess this would be considered a global render?
-- it creates an entry in the render table to be used in
-- the main draw. the second erases it out of the table
local function render(v, n, func)
	renders[n] = function ( v )
		func(v)
	end
	--TODO: expose c to the draw
end

local function eraseRender(n)
	renders[n] = nil
end
-- the same as above, except creates one in the player struct
-- for players. the second does the same task as the above
local function playerRender(v, n, player, func)
	if (player) then
		if not player.renders then
			player.renders = {}
		end
		player.renders[n] = function ( v )
			func(v)
		end
	end
end

local function erasePlayerRender(n, player)
	if (player) then
		player.renders[n] = nil
	end
end


-- Disable Player Movement (with turn rotation using forceStrafe)
-- @player - userdata player
-- @forceStrafe - modify forceStrafe for turning disable
local function DisablePlayerMovement(player, forceStrafe)
	if (player and player.valid) then
		if (forceStrafe) then
			player.pflags = $1|PF_FORCESTRAFE
		end
		player.powers[pw_nocontrol] = 1
		player.thrustfactor = 0
		player.jumpfactor = 0
		player.charability2 = 0
	end
end

-- Enable Player Movement (with turn rotation using unforceStrafe)
local function EnablePlayerMovement(player, unforceStrafe)
	if (player and player.valid) then
		if (unforceStrafe) then
			player.pflags = $1 & ~PF_FORCESTRAFE
		end
		player.powers[pw_nocontrol] = 0
		player.thrustfactor = skins[player.mo.skin].thrustfactor
		player.jumpfactor = skins[player.mo.skin].jumpfactor
		player.charability2 = skins[player.mo.skin].ability2
	end
end



-- Player text speech calls and functions
-- (store text and things in the player renders)

-- SetTextConfig
-- ---
-- @n - name
-- @player - userdata player
-- @... - table config data
-- Set the text config (options or whatever) for the render used
local function SetTextConfig(n, player, ...)
	-- Temporarily clone the storage (or nothing even happens)
	player.rTextStore[n] = table.clone(player.textStore)
	player.rTextStore[n].useTextConfig = true
	player.rTextStore[n].textConfig = unpack({...})
end


-- This handles the player renders drawings for text
-- by drawing it out of its own render tables
local function handlePRTextDrawing(v, n, player)
	
	if (player and player.rTextStore[n]) then

		--TODO: box setting
		-- Shortcut keywords
		local cSpeaker = player.rTextStore[n].speaker
		--TODO: text effects (eg. $player, etc)
		local cText = player.rTextStore[n].text
		local lineTimer = player.rTextStore[n].lineTimer
		local tOptions = player.rTextStore[n].textOptions
		-- Shortcut linetimer feed 
		local strCut = player.rTextStore[n].lineTimer + tOptions.sPos/tOptions.speed


		-- Handle speaker and text entries
		if (player.rTextStore[n].text) then

			-- TODO box fade
			-- TODO custom graphic, scaling
			--Draw the box (or entry graphic)
			v.drawScaled(0, 160*FRACUNIT, FRACUNIT/2, v.cachePatch("DLGWIN4"), V_50TRANS) --V_60TRANS

			--Draw the items needed
			if (player.rTextStore[n].speaker) then
				if (useJFont) then
					-- use the font this used to be bundled with
					jDrawString(v, 20, 158, cSpeaker, V_ALLOWLOWERCASE|V_MONOSPACE, 0, "left")
				else
					v.drawString(20, 158, cSpeaker, V_ALLOWLOWERCASE|V_MONOSPACE, "left")
				end
			end
			if (useJFont) then
				-- use the font this used to be bundled with
				jDrawString(v, 8, 168, cText:sub(0, strCut):gsub("%z+", ""), V_ALLOWLOWERCASE, 0, "left")	
			else
				v.drawString( 8, 168, cText:sub(0, strCut):gsub("%z+", ""), V_ALLOWLOWERCASE, "left")
			end
		end
		
		-- Handle the selection display
		if (tOptions.selection) then
		-- RedEnchilada select my arm.
		-- like if you agree.
		
			if cText == nil or (lineTimer >= (cText:len()-tOptions.sPos)*tOptions.speed) then
				-- Scan the selection table
				for k,sel in ipairs(tOptions.selection) do
					
					local pos_x = 316
					
					if not sel.text then
						
						pos_x = $ - (sel.spacing or tOptions.selection.spacing or 80) * (#sel - 1)
						
						for k2,subsel in ipairs(sel) do
							
							local sub_x = pos_x
							local selectionText = subsel.text
						
							-- Apply highlighted selection
							-- and shift it a bit to the left
							if (k == tOptions.selectNum and k2 == tOptions.subselectNum) then
								-- use the font this used to be bundled with, or not
								if (useJFont) then
									if selectionText:len()>0 selectionText = "\182 \154" .. selectionText end
								else
									if selectionText:len()>0 selectionText = "\x82 " .. selectionText end
								end
								sub_x = $-6
							end
							
							-- Draw the selectionindex items
							-- use the font this used to be bundled with, or not
							if (useJFont) then
								jDrawString(v, sub_x, 152-(#tOptions.selection-k)*10, selectionText, V_ALLOWLOWERCASE, 0, "right")
							else
								v.drawString(sub_x, 152-(#tOptions.selection-k)*10, selectionText, V_ALLOWLOWERCASE, "right")
							end
							
							pos_x = $+(sel.spacing or tOptions.selection.spacing or 80)
						end
					
					else
					
						local selectionText = sel.text
						
						-- Apply highlighted selection
						-- and shift it a bit to the left
						if (k == tOptions.selectNum) then
						
							-- use the font this used to be bundled with, or not
							if (useJFont) then
								if selectionText:len()>0 selectionText = "\182 \154" .. selectionText end
							else
								if selectionText:len()>0 selectionText = "\x82 " .. selectionText end
							end
							pos_x = 310
						end
						
						-- Draw the selectionindex items
						
						-- use the font this used to be bundled with, or not
						if (useJFont) then
							jDrawString(v, pos_x, 152-(#tOptions.selection-k)*10, selectionText, V_ALLOWLOWERCASE, 0, "right")
						else
							v.drawString(pos_x, 152-(#tOptions.selection-k)*10, selectionText, V_ALLOWLOWERCASE, "right")
						end
					end
				end
			end
		end
	end
end



------------------------------------------------
--
-- EventManager HUD Setup
--
------------------------------------------------

local client = nil
--rawset(_G, "client_player", nil)

local function clientplayer(v, stplyr, cam)
	client = stplyr
end
hud.add(clientplayer, "game")


-- Drawing Layer: this scans the render tables
-- and draws from their functions

EVM_HUD["evm_HUDlayer"] = {z_index = 50, func = 
function(v, player, cam)
	
	-- To save memory (probably), check for renders when they
	-- exist instead of all the time
	if (player and player.renders) then
		
		-- Scan renders for any drawing
		for k, fun in pairs(player.renders) do
			if type(fun) == "function" then
				fun( v )
			end
		end
	end

	-- Scan renders for any drawing
	for k, fun in pairs(renders) do
		if type(fun) == "function" then
			fun( v )
		end
	end
end
}


EVM_HUD["widescreen"] = {z_index = -1, func = 
function(v, player, cam)
	if (player.hudOptions and player.hudOptions.widescreen.enabled == true) then
		if leveltime % 3 == 0 then 
			player.hudOptions.widescreen.wideframe = min($1+1, 8)
		end
		v.drawScaled(0, 0*FRACUNIT, FRACUNIT/v.dupx(), v.cachePatch("CINEFWD"..player.hudOptions.widescreen.wideframe), 0)
	elseif (player.hudOptions.widescreen.enabled == false) and player.hudOptions.widescreen.wideframe > 0 then
		if leveltime % 2 == 0 then 
			player.hudOptions.widescreen.wideframe = max($1-1, 0)
		end
		v.drawScaled(0, 0*FRACUNIT, FRACUNIT/v.dupx(), v.cachePatch("CINEREV"..player.hudOptions.widescreen.wideframe), 0)
	end
end
}

EVM_HUD["wipefade"] = {z_index = -1, func = 
function(v, player, cam)
	if (player.hudOptions.wipe and player.hudOptions.wipe.dest < 10) then
		local wipe = player.hudOptions.wipe
		v.drawScaled(v.width()/2, v.height()/2, v.dupx()*FRACUNIT, v.cachePatch((wipe.pic) or "WFILL"), wipe.dest<<V_ALPHASHIFT)
	end
end
}






----------------------------------------

-- EventManager ZHud
-- Hud with z Ordering instead of the normal

----------------------------------------

local function evm_zhud(v, stplyr, cam)
	--if (mapheaderinfo[gamemap].limit) then	
		-- List in descending order
		--for k,huditem in spairs(EVM_HUD, function(t,a,b) return t[b].z_index < t[a].z_index end) do -- desc
		
		-- List in ascending order
		for k,huditem in spairs(EVM_HUD, function(t,a,b) return t[a].z_index < t[b].z_index end) do -- asc
			
			-- Do not show indexes of -1
			--if (huditem.z_index == -1) then return end
			--if (huditem.func == nil) then return end
			if not (huditem.z_index == -1) or (huditem.func == nil) then huditem.func(v, stplyr, cam) end
			-- Run hud functions in the table
			--huditem.func(v, stplyr, cam)
		end
	--end
end
hud.add(evm_zhud, "game")

-- SCORES IS NOT F3, DO NOT TREAT IT LIKE ONE
local function evm_zhud_client_scores(v, stplyr, cam)
	if (mapheaderinfo[gamemap].starzone or mapheaderinfo[gamemap].starzonecut) then	
		--for k,huditem in spairs(EVM_HUD, function(t,a,b) return t[b].z_index < t[a].z_index end) do -- desc
		for k,huditem in spairs(EVM_HUD, function(t,a,b) return t[a].z_index < t[b].z_index end) do -- asc
			-- Do not show indexes of -1
			--if (huditem.z_index == -1) then return end
			--if (huditem.func == nil) then return end
			if not (huditem.z_index == -1) or (huditem.func == nil) then huditem.func(v, client, cam) end
			-- Run hud functions in the table
			--huditem.func(v, stplyr, cam)
		end
	end
end
hud.add(evm_zhud_client_scores, "scores")




--[[EVM_HOOK["ScreenWipe"] = {z_index = 1, func = 
function()
	for player in players.iterate do
		IndPlayerScreenWipe(player)
	end
end
}]]

-- EVENTMAN Hook Loader
addHook("ThinkFrame", do
	--if (mapheaderinfo[gamemap].limit) then	
		--for k,hookitem in spairs(EVM_HOOK, function(t,a,b) return t[b].z_index < t[a].z_index end) do -- desc
		for k,hookitem in spairs(EVM_HOOK, function(t,a,b) return t[a].z_index < t[b].z_index end) do -- asc
			-- Disable indexes of -1
			--if (hookitem.z_index == -1) then return end
			--if (hookitem.func == nil) then return end
			if not (hookitem.z_index == -1) or (hookitem.func == nil) then hookitem.func() end
			-- Run hud functions in the table
			--hookitem.func()
		end
	--end
end)






-- works like renders and playerrenders, but used for adding
-- content into the main game loop through "tagging" it inside
-- of the loop
--[[
rawset(_G, "srb2_FunctionTags", {})

local function setFTag(n, func)
	srb2_FunctionTags[n] = function ( )
		func()
	end
end

local function removeFTag(n)
	srb2_FunctionTags[n] = nil
end

addHook("ThinkFrame", do
	for k, fun in pairs(srb2_FunctionTags) do
		if type(fun) == "function" then
			fun( v )
		end
	end
end)
]]



------------------------------------------------
--
-- Misc Event Actions
--
------------------------------------------------

--[[
-- Patch together all three functions to pull together a
-- speaking function (can be used seperately)
-- arg [v]: hud v
-- arg [n]: renders name to create/apply to
-- arg [speaker]: the speaker of the text if available
-- arg [text]: the text to be printed, nil if none
-- arg [useTextConfig]: allows SetTextConfig to apply an options list
local function Speak(v, n, player, speaker, text, useTextConfig)
	if (player) then
		playerRender(v, n, player, function(v)
			handlePRTextDrawing(v, n, player) end)
		handlePRTextLoop(n, player, speaker, text, useTextConfig)
	else
		for p in players.iterate do
			playerRender(v, n, p, function(v)
			handlePRTextDrawing(v, n, p) end)
		end
		handlePRTextLoop(n, server, speaker, text, useTextConfig)
	end
end
]]

local function WaitForKey(player, key)
	if (player) then
		while true
			if (player.buttonstate[key] == 1) then
				break
			end
			waitSeconds(0)
		end
	end
end


local function WaitForKeyHeld(player, key, timeframe)
	if (player) then
		while true
			if (player.buttonstate[key] > timeframe) then
				break
			end
			waitSeconds(0)
		end
	end
end





local function netgameCamOverride(player, serv, args)
	if (args.enabled == true) then
		CAMERA:override(player, true)
		player.awayviewmobj = serv.mo.cam
		player.awayviewtics = 65535*TICRATE--server.awayviewtics
		player.awayviewaiming = serv.awayviewaiming
	else
		CAMERA:override(player, false)
		player.awayviewmobj = args.awayviewmobj or nil
		player.awayviewtics = 1
		player.awayviewaiming = 0
	end
end

local function syncNetgameText(user, origin)
	user.rTextStore = origin.rTextStore
end

local function animationTimerDisplay(v, user)
	local Time = 0
	playerRender(v, "atd_event", server, function(v)
		Time = $1+1
		local Hours = string.format("%02d", G_TicsToHours(Time))
		local Minutes = string.format("%02d", G_TicsToMinutes(Time))
		local Seconds = string.format("%02d", G_TicsToSeconds(Time))
		local Centiseconds = string.format("%02d", G_TicsToCentiseconds(Time))
		local Milliseconds = string.format("%02d", G_TicsToMilliseconds(Time))
		v.drawString(320/2,5, Hours..":"..Minutes..":"..Seconds..":"..Centiseconds, V_ALLOWLOWERCASE|V_MONOSPACE, "center")
	end)
end

local function end_animationTimerDisplay()
	server.renders["atd_event"] = nil
end

local function forcePlayerReborn(player)
	if (netgame) then
		if (player.playerstate == PST_DEAD) then
			if player.lives > 0 then 
				player.playerstate = PST_REBORN
			end
		end
	end
end





--`````````````````````````````````````````
-- EVENTMAN SETUP (mapheader options)
--`````````````````````````````````````````

----------------------------------------------
-- Scan MAINCFG mapheaderinfo
local hud_is_off = false
addHook("MapChange", function(gamemap)

	for player in players.iterate
		
		if (player.camprocess) then
			player.camprocess = nil
		end
		
		-- Start Map as a fake nondrawn scene on map change
		if mapheaderinfo[gamemap].startempty
			--SCREEN:SetWipe(player, {set = true, dest = 0, flash = true, pic = "bfill"})
		else
			--SCREEN:SetWipe(player, {set = false, dest = 10, flash = true})
		end
		
		-- Do not reset the BGM volume level on map change
		--if not mapheaderinfo[gamemap].noresetvolume_onchange
		--	SOUND:SetBGMVolume(player, 35)
		--end
		
		-- Do not clear (public) renders on map change
		if not mapheaderinfo[gamemap].keepRenders_onchange
			renders = {}
		end
		
		-- Do not clear (public) tags on map change
		if not mapheaderinfo[gamemap].keepFunctionTags_onchange
			srb2_FunctionTags = {}
		end
		
		-- Disable the hud on map change
		if mapheaderinfo[gamemap].disablehud_onchange
			hud.disable("score")
			hud.disable("time")
			hud.disable("rings")
			hud.disable("lives")
			-- Failsafe check
			hud_is_off = true
		else
			if (hud_is_off == true or nil) then
				hud.enable("score")
				hud.enable("time")
				hud.enable("rings")
				hud.enable("lives")
				hud_is_off = false
			end
		end
		
		--clearProcesses()
		--EnablePlayerMovement(player, true)
	end
end)

-- Scan and set on map load
addHook("MapLoad", function(gamemap)
	
	--clearProcesses()
	for player in players.iterate
				
		if (player.camprocess) then
			player.camprocess = nil
		end
		
		--[[for k,v in ipairs(eventIndex) do
			TASK:Destroy(eventIndex[k].coroutine)	
		end]]
		
		-- Start Map as a fake nondrawn scene on map load
		if mapheaderinfo[gamemap].startempty_onload
			--SCREEN:SetFill(player, 0, "BLK")
		else
			--SCREEN:SetFill(player, 10, "BLK")
		end
		
		-- Begin an event on map load from the dictionary
		if (mapheaderinfo[gamemap].loadscene or mapheaderinfo[gamemap].loadEvent) then
			event.beginEvent(mapheaderinfo[gamemap].loadscene:gsub("%z", ""), player)
		end	
		
		-- Disable the hud on load
		if mapheaderinfo[gamemap].disablehud_onload
			hud.disable("score")
			hud.disable("time")
			hud.disable("rings")
			hud.disable("lives")
			-- Failsafe check
			hud_is_off = true
		else
			if (hud_is_off == true or nil) then
				hud.enable("score")
				hud.enable("time")
				hud.enable("rings")
				hud.enable("lives")
				hud_is_off = false
			end
		end
	end
	
	if (mapheaderinfo[gamemap].globalscene or mapheaderinfo[gamemap].globalevent) then
		--event.beginEvent(mapheaderinfo[gamemap].globalevent:gsub("%z", ""), server)
	end
	
end)

----------------------------------------------










----------------------------------------------
-- Expose
rawset(_G, "render", render)
--rawset(_G, "renderGraph", render)
--rawset(_G, "eraseGraph", eraseRender)
rawset(_G, "destroyRender", eraseRender)
rawset(_G, "playerRender", playerRender)
rawset(_G, "renderToPlayerScreen", playerRender)
rawset(_G, "erasePlayerRender", erasePlayerRender)
rawset(_G, "destroyUserRender", erasePlayerRender)
--rawset(_G, "GetSelectionID", GetSelectionID)
--rawset(_G, "GetCurrentSelection", GetCurrentSelection)
rawset(_G, "DisablePlayerMovement", DisablePlayerMovement)
rawset(_G, "EnablePlayerMovement", EnablePlayerMovement)
rawset(_G, "SetTextConfig", SetTextConfig)
--rawset(_G, "handlePRTextLoop", handlePRTextLoop)
rawset(_G, "handlePRTextDrawing", handlePRTextDrawing)
--rawset(_G, "Speak", Speak)
rawset(_G, "WaitForKey", WaitForKey)
rawset(_G, "WaitForKeyHeld", WaitForKeyHeld)
rawset(_G, "setFTag", setFTag)
rawset(_G, "removeFTag", removeFTag)
rawset(_G, "attachLoop", setFTag)
rawset(_G, "destroyLoop", removeFTag)
rawset(_G, "netgameCamOverride", netgameCamOverride)
rawset(_G, "syncNetgameText", syncNetgameText)
rawset(_G, "start_animationTimer", animationTimerDisplay)
rawset(_G, "end_animationTimer", end_animationTimerDisplay)
rawset(_G, "forcePlayerReborn", forcePlayerReborn)
----------------------------------------------



