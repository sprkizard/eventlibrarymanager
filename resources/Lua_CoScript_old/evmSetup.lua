--=================================================================
-- EventMan (event index) was made by me reinamoon (chi.miru)
-- do not use my script without permission from me
--
-- extra assist: Nev3r
-- reinamoon 2016/2017
--=================================================================


------------------------------------------------------------------------------------
-- EVENTMAN SETUP
------------------------------------------------------------------------------------

-- EventMan Hud
rawset(_G, "EVM_HUD", {})


-- Index stores events functions and information
-- Exposed globally (unless problems arise)
rawset(_G, "eventIndex", {})
rawset(_G, "events", {})


-- Variable used to call functions or variables within
-- Exposed globally
rawset(_G, "event", {})

-- Set up the structure beforehand (this may fail?)
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

-- Register a new event to the index
event.newevent = function(eventName, coroutineFunction)

	-- Store our content here
	local ret = {lines = {}}

	-- Shove coroutine into the index
	ret.coroutine = coroutineFunction

	-- Index cutevent and return it
	eventIndex[eventName] = ret
	return ret

end

-- Begin a event or function from the index
event.beginEvent = function(eventName, user, storedLocation, ret)
	
	-- user is almost always, player
	
	-- If it's a name string we can search the index
	if type(eventName) == "string" then

		-- warning: Name isn't in the Index
		assert(eventIndex[eventName], "Event (" .. eventName .. ") does not exist.")
		
		-- Run the function
		--TASK:Run(function() eventIndex[eventName].coroutine(user) end)
		
		if ret then
			return function(user) eventIndex[eventName].coroutine(user) end
		else
			-- Store in specific area
			if type(storedLocation) == "userdata" or type(storedLocation) == "table" then
				--store[eventName] = TASK:Run(function() eventIndex[eventName].coroutine(user) end)
				storedLocation[eventName] = TASK:Run(function() eventIndex[eventName].coroutine(user) end)
				--print("yes")
			else
				TASK:Run(function() eventIndex[eventName].coroutine(user) end)
			end
		end
	-- If it doesn't have a name, we can 
	-- run one right off the bat
	elseif type(eventName) == "function" then
		TASK:Run(eventName)
	end
end




--`````````````````````````````````````````
-- EVENTMAN SETUP (text and graphic engine)
--`````````````````````````````````````````

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

-- GetSelectionID
-- ---
-- @n - name
-- @player - userdata player
-- This specifically returns a selection id for us
local function GetSelectionID(n, player)
	return player.rTextStorage[n].textOptions.selectId
end

-- GetCurrentSelection
-- ---
-- @n - name
-- @player - userdata player
-- This specifically returns the current selection num for us
local function GetCurrentSelection(n, player)
	return player.rTextStorage[n].textOptions.selectNum
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


-- This handles the player renders loop for coroutines
-- (can also be used in a couroutine instead of being in main)
local function handlePRTextLoop(n, player, speaker, text, useTextConfig)
	if (player and player.valid) then

		-- Make a copy of the original text storage to reset everything
		-- use custom text config options if wanted
		if (useTextConfig == true) then
			player.rTextStore[n].textOptions = table.clone(player.rTextStore[n].textConfig)
		else
			player.rTextStore[n] = table.clone(player.textStore)
		end

		-- Reset Timer, set strings (and options when made avail)
		player.rTextStore[n].lineTimer = 0
		player.rTextStore[n].speaker = speaker
		player.rTextStore[n].text = text
		--player.rTextStore[n].textOptions = {}

		-- Shortcut keywords
		local cSpeaker = player.rTextStore[n].speaker
		local cText = player.rTextStore[n].text
		local tOptions = player.rTextStore[n].textOptions

		-- Set up options defaults
		tOptions.auto = tOptions.auto or false -- False by default
		tOptions.autotime = tOptions.autotime or 3*TICRATE -- Timesecs 3 by defailt
		tOptions.speed = tOptions.speed or 2 -- 1 by default
		tOptions.sPos = tOptions.sPos or 0	-- 0 by default
		tOptions.ticksfx = tOptions.ticksfx or sfx_none
		tOptions.selectNum = tOptions.selectNum or 1	-- 0 by default
		
		-- A short local function to clear text and speaker
		-- (is this even allowed inside here?)
		-- (will this error later?)
		local clearText = function()
			player.rTextStore[n].speaker = nil
			player.rTextStore[n].text = nil
		end
				
		-- Start our loop to stay in (while should work..)
		while true

			--Shortcut lineTimer
			local lineTimer = player.rTextStore[n].lineTimer
			
			-- (alternate speed formula)
			local rSpeed = lineTimer/tOptions.speed + tOptions.sPos
			
			-- Sound ticker (can be set in options)
			if (tOptions.ticksfx) then
				if (lineTimer + tOptions.sPos/tOptions.speed <= cText:len()) and not (cText:sub(0,lineTimer + tOptions.sPos/tOptions.speed):byte() == 0)
				and (lineTimer % tOptions.speed == 0) then
					S_StartSound(nil, tOptions.ticksfx or sfx_none, player)
				end
				--if cText and (rSpeed <= cText:len()) and not (cText:sub(0, rSpeed):byte() == 0)
				--and (lineTimer % tOptions.speed == 0) then
				--	S_StartSound(nil, sfx_thok, player)
				--end
			end
			
			
			-- We have a selection index, so begin it at the end of the line
			if (tOptions.selection) then
				if (cText == nil or lineTimer >= (cText:len()-tOptions.sPos)*tOptions.speed) then
					-- After end of line, control moves selection index down and
					if (player.buttonstate["down"] == 1) then
						player.rTextStorage[n].textOptions.selectNum = $1+1
						if player.rTextStorage[n].textOptions.selectNum > #tOptions.selection then
							player.rTextStorage[n].textOptions.selectNum = 1
						end
						S_StartSound(nil, tOptions.selectsfx or sfx_none, player)
					-- moves selection index up
					elseif (player.buttonstate["up"] == 1) then
						player.rTextStorage[n].textOptions.selectNum = $1-1
						if player.rTextStorage[n].textOptions.selectNum < 1 then
							player.rTextStorage[n].textOptions.selectNum = #tOptions.selection
						end
						S_StartSound(nil, tOptions.selectsfx or sfx_none, player)
					end
					-- Select, return the selected id, and break the loop
					if (player.buttonstate[BT_JUMP] == 1) then
						local returnId = tOptions.selection[player.rTextStorage[n].textOptions.selectNum].id
						--local returnId = player.rTextStorage[n].textOptions.selectNum
						S_StartSound(nil, tOptions.idsfx or sfx_none, player)
						player.rTextStorage[n].textOptions.selectId = returnId
						clearText()
						break
					end
					-- Stick off the ground a bit (stops 2nd ability)
					player.mo.z = $1+10
				end
			-- or
			elseif (lineTimer >= (cText:len()-tOptions.sPos)*tOptions.speed) then
				-- When automatic is turned on, break the loop after defined time
				if (tOptions.auto and lineTimer >= (cText:len()-tOptions.sPos)*tOptions.speed + tOptions.autotime) then
					clearText()
					break
				-- otherwise we wait for button input
				elseif not tOptions.auto and player.cmd.buttons & BT_JUMP then--(player.buttonstate[BT_JUMP] == 1) then
					clearText()
					break
				-- or we can wait without auto when movement is static
				end
			end

			-- Increment timer
			-- TODO: Slower text speeds
			player.rTextStore[n].lineTimer = player.rTextStore[n].lineTimer + 1*tOptions.speed

			--print("inside pr text loop")
			waitSeconds(0)
		end
	end
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
				v.drawString(20, 158, cSpeaker, V_ALLOWLOWERCASE|V_MONOSPACE, "left")
			end
			v.drawString( 8, 168, cText:sub(0, strCut):gsub("%z+", ""), V_ALLOWLOWERCASE, "left")
		end

	end
end


--`````````````````````````````````````````
-- EVENTMAN SETUP (HUD engine)
--`````````````````````````````````````````

-- Drawing Layer: it scans the render tables
-- and draws from their functions
--[[
local function corouHUDLayer(v, player, cam)

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
hud.add(corouHUDLayer, "game")]]



-- Drawing Layer: it scans the render tables
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







-- EVENTMAN Z_HUD
local function evm_zhud(v, stplyr, cam)
	--if (mapheaderinfo[gamemap].limit) then	
		--for k,huditem in spairs(EVM_HUD, function(t,a,b) return t[b].z_index < t[a].z_index end) do -- desc
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









-- works like renders and playerrenders, but used for adding
-- content into the main game loop through "tagging" it inside
-- of the loop
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




--____________________________________________________
-- External use functions
--____________________________________________________


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



--`````````````````````````````````````````
-- EVENTMAN SETUP (mapheader options)
--`````````````````````````````````````````

----------------------------------------------
-- Scan MAINCFG mapheaderinfo
local hud_is_off = false
addHook("MapChange", function(gamemap)

	for player in players.iterate

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
		
		clearProcesses()
		--EnablePlayerMovement(player, true)
	end
end)

-- Scan and set on map load
addHook("MapLoad", function(gamemap)
	
	clearProcesses()
	for player in players.iterate
		
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
		event.beginEvent(mapheaderinfo[gamemap].globalevent:gsub("%z", ""), server)
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
rawset(_G, "GetSelectionID", GetSelectionID)
rawset(_G, "GetCurrentSelection", GetCurrentSelection)
rawset(_G, "DisablePlayerMovement", DisablePlayerMovement)
rawset(_G, "EnablePlayerMovement", EnablePlayerMovement)
rawset(_G, "SetTextConfig", SetTextConfig)
--[[rawset(_G, "handlePRTextLoop", handlePRTextLoop)
rawset(_G, "handlePRTextDrawing", handlePRTextDrawing)]]
rawset(_G, "Speak", Speak)
rawset(_G, "WaitForKey", WaitForKey)
rawset(_G, "WaitForKeyHeld", WaitForKeyHeld)
rawset(_G, "setFTag", setFTag)
rawset(_G, "removeFTag", removeFTag)
rawset(_G, "attachLoop", setFTag)
rawset(_G, "destroyLoop", removeFTag)
rawset(_G, "netgameCamOverride", netgameCamOverride)
rawset(_G, "syncNetgameText", syncNetgameText)
----------------------------------------------
