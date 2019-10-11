-- new thinker-mode system alternative for handling map events!
rawset(_G, "event_states", {})

local running_events = {}

local Event = {}
rawset(_G, "Event", Event)
Event.__index = Event

-- a token we can throw around, basically
local _EVENT_NOT_REALLY_AN_ERROR = {}

local function startEvent(first_state, order)
	local event = {
		state = first_state,
		_order = order or 0,
		_wait = 0,
		finished = false,
	}
	
	setmetatable(event, Event)
	
	local insertIndex = 1
	while running_events[insertIndex] and running_events[insertIndex]._order >= event._order do
		insertIndex = $+1
	end
	
	table.insert(running_events, insertIndex, event)
	
	return event
end

rawset(_G, "startEvent", startEvent)

function Event:wait(tics)
	if self._loop_tracker then
		-- alternate function that will allow for "steps" if this state is doing that style
		self._loop_tracker = $ + tics
		if self.time < self._loop_tracker then
			-- Workaround to return out of function execution here
			error(_EVENT_NOT_REALLY_AN_ERROR)
		end
		
		return self
	end

	self._wait = tics
	return self
end

function Event:once(run_func)
	self:loop(1, run_func)
end

function Event:loop(loop_tics, loop_func)
	if type(loop_func) == "function" then
		self._loop_tracker = $ + loop_tics
		if self.time < self._loop_tracker then
			loop_func()
			-- Workaround to return out of function execution here
			error(_EVENT_NOT_REALLY_AN_ERROR)
		end
	else
		self._loops = loop_tics
	end
	
	return self
end

function Event:doWhile(while_func)
	if self.time == self._loop_tracker and while_func() then
		self.time = $-1
		-- Workaround to return out of function execution here
		error(_EVENT_NOT_REALLY_AN_ERROR)
	end
	self._loop_tracker = $+1
end

function Event:next(next_state)
	self._next_state = next_state
	return self
end

function Event:goto(new_state)
	self.state = new_state
	return self
end

function Event:stop()
	self.finished = true
	return self
end

addHook("MapLoad", do
	while running_events[1] do
		table.remove(running_events)
	end
end)

addHook("ThinkFrame", do
	-- TODO: this can run in titlemap, but only if server
	-- is isolated
	if (titlemapinaction) then return end
	
	-- Sync the running_events table into the server object so that netplay syncs it for us
	if not server._rnm_running_events then
		server._rnm_running_events = running_events
	else
		running_events = server._rnm_running_events
	end

	local index = 1
	
	while running_events[index] do
		local event = running_events[index]
		
		if event.finished then
			table.remove(running_events, index)
			continue
		end
		
		index = $+1
		
		if event._current_state ~= event.state then
			event.time = 0
			event._current_state = event.state
		elseif event._wait > 0 then
			event._wait = $-1
		else
			if event._loops and event.time >= event._loops then
				event._loops = 0 -- prevent loop limit bleed if the next event doesn't set this
				event.state = event._next_state
				event._next_state = nil
				event._current_state = event.state
				event.time = 0
			end
			
			if event_states[event.state] then
				event._loop_tracker = 0
				Event.CURRENT = event
				local result, err = pcall(event_states[event.state], event)
				Event.CURRENT = nil
				--event_states[event.state](event)
				
				--if not result then print("flow test " .. leveltime) end
				if (not result) and err ~= _EVENT_NOT_REALLY_AN_ERROR then
					print("Event error: " .. err)
					event.finished = true
				end
				event.time = $+1
			else
				print("Event state function " .. (event.state or "<NOT SET>") .. " not defined!")
				event.finished = true
			end
		end
		
	end
end)








-- This handles the player renders loop for thinkers
-- (can also be used in a thinker instead of being in main)
local function t_handlePRTextLoop(n, player, speaker, text, useTextConfig)
	local event = Event.CURRENT

	if (player and player.valid) then
		
		event:once(do
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
			
			-- Set up options defaults
			local tOptions = player.rTextStore[n].textOptions
			tOptions.auto = tOptions.auto or false -- False by default
			tOptions.autotime = tOptions.autotime or 3*TICRATE -- Timesecs 3 by defailt
			tOptions.speed = tOptions.speed or 2 -- 1 by default
			tOptions.sPos = tOptions.sPos or 0	-- 0 by default
			tOptions.ticksfx = tOptions.ticksfx or sfx_none
			tOptions.selectNum = tOptions.selectNum or 1	-- 0 by default
		end)

		-- Shortcut keywords
		local cSpeaker = player.rTextStore[n].speaker
		local cText = player.rTextStore[n].text
		local tOptions = player.rTextStore[n].textOptions

		-- A short local function to clear text and speaker
		-- (is this even allowed inside here?)
		-- (will this error later?)
		local function clearText()
			player.rTextStore[n].speaker = nil
			player.rTextStore[n].text = nil
		end
				
		-- Start our loop to stay in (while should work..)
		event:doWhile(do
			--Shortcut lineTimer
			local lineTimer = player.rTextStore[n].lineTimer
			
			-- (alternate speed formula)
			local rSpeed = lineTimer/tOptions.speed + tOptions.sPos
			
			-- Sound ticker (can be set in options)
			if (tOptions.ticksfx) then
				if (lineTimer + tOptions.sPos/tOptions.speed <= cText:len()) and not (cText:sub(0,lineTimer + tOptions.sPos/tOptions.speed):byte() == 0)
				and (lineTimer % tOptions.speed == 0) then
					S_StartSound(nil, tOptions.ticksfx or sfx_none) -- (7-26-2017: used to have player, unsure if problematic without)
				end
				--if cText and (rSpeed <= cText:len()) and not (cText:sub(0, rSpeed):byte() == 0)
				--and (lineTimer % tOptions.speed == 0) then
				--	S_StartSound(nil, sfx_thok, player)
				--end
			end
			
			--[[
				{
					{top-left option, top-right option},
					{bottom-left option, bottom-right option},
				}
			]]
			
			-- We have a selection index, so begin it at the end of the line
			if (tOptions.selection) then
				if (cText == nil or lineTimer >= (cText:len()-tOptions.sPos)*tOptions.speed) then
					local textOptions = player.rTextStore[n].textOptions
					-- After end of line, control moves selection index down and
					if #tOptions.selection > 1 then
						if (player.buttonstate["down"] == 1) then
							textOptions.selectNum = $1+1
							if textOptions.selectNum > #tOptions.selection then
								textOptions.selectNum = 1
							end
							S_StartSound(nil, tOptions.selectsfx or sfx_none, player)
						-- moves selection index up
						elseif (player.buttonstate["up"] == 1) then
							textOptions.selectNum = $1-1
							if textOptions.selectNum < 1 then
								textOptions.selectNum = #tOptions.selection
							end
							S_StartSound(nil, tOptions.selectsfx or sfx_none, player)
						end
					end
					
					local optgroup = tOptions.selection[player.rTextStore[n].textOptions.selectNum]
					if not optgroup.text then
						-- Initialize subselectnum if needed
						if not textOptions.subselectNum then
							textOptions.subselectNum = 1
						elseif textOptions.subselectNum > #optgroup then
							textOptions.subselectNum = #optgroup
						end
						
						-- This column has multiple (horizontal) entries, so allow left and right movement too
						if (player.buttonstate["right"] == 1) then
							textOptions.subselectNum = $1+1
							if textOptions.subselectNum > #optgroup then
								textOptions.subselectNum = 1
							end
							S_StartSound(nil, tOptions.selectsfx or sfx_none, player)
						-- moves selection index up
						elseif (player.buttonstate["left"] == 1) then
							textOptions.subselectNum = $1-1
							if textOptions.subselectNum < 1 then
								textOptions.subselectNum = #optgroup
							end
							S_StartSound(nil, tOptions.selectsfx or sfx_none, player)
						end
					end
					
					-- Select, return the selected id, and break the loop
					if (player.buttonstate[BT_JUMP] == 1) then
						local returnId = optgroup.id
						if not optgroup.text then returnId = optgroup[textOptions.subselectNum].id end
						--local returnId = player.rTextStore[n].textOptions.selectNum
						S_StartSound(nil, tOptions.idsfx or sfx_none, player)
						player.rTextStore[n].textOptions.selectId = returnId
						clearText()
						return false
					end
					-- Stick off the ground a bit (stops 2nd ability)
					--player.mo.z = $1+10
				end
			-- or
			elseif (lineTimer >= (cText:len()-tOptions.sPos)*tOptions.speed) then
				-- When automatic is turned on, break the loop after defined time
				if (tOptions.auto and lineTimer >= (cText:len()-tOptions.sPos)*tOptions.speed + tOptions.autotime) then
					clearText()
					return false
				-- otherwise we wait for button input
				elseif not tOptions.auto and player.cmd.buttons & BT_JUMP then--(player.buttonstate[BT_JUMP] == 1) then
					clearText()
					return false
				-- or we can wait without auto when movement is static
				end
			end

			-- Increment timer
			-- TODO: Slower text speeds
			player.rTextStore[n].lineTimer = player.rTextStore[n].lineTimer + 1*tOptions.speed

			--print("inside pr text loop")
			return true
		end)
	end
end



-- Patch together all three functions to pull together a
-- speaking function (can be used seperately)
-- arg [v]: hud v
-- arg [n]: renders name to create/apply to
-- arg [speaker]: the speaker of the text if available
-- arg [text]: the text to be printed, nil if none
-- arg [useTextConfig]: allows SetTextConfig to apply an options list
local function t_Speak(n, player, speaker, text, useTextConfig)
	local v = "ssiudogdf"
	if (player) then
		playerRender(v, n, player, function(v)
			handlePRTextDrawing(v, n, player) end)
		t_handlePRTextLoop(n, player, speaker, text, useTextConfig)
	else
		for p in players.iterate do
			playerRender(v, n, p, function(v)
			handlePRTextDrawing(v, n, p) end)
		end
		t_handlePRTextLoop(n, server, speaker, text, useTextConfig)
	end
end


rawset(_G, "t_Speak", t_Speak)
