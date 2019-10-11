------------------------------------------------------------------------------------
-- EVENTMAN BACK-END
------------------------------------------------------------------------------------
-- ============================================================================
-- Coroutine management - There's a way we can keep ordered events
-- here, and they're useful for stepping along a function
-- in a specific way
-- Original set of functions moderately/heavily modified 
-- from mohiji 
-- (https://bitbucket.org/mohiji/luacoroutinedemo)

-----------------------------------------------
local function verboseRun(co, ...)
	local table = {coroutine.resume(co, ...)}
	if not table[1] then
		print("\x82WARNING:\x80 " .. table[2])
	end
	return unpack(table)
end

local WAITING_ON_TIME = {}

local WAITING_ON_SIGNAL = {}

local CURRENT_TIME = 0


local function waitSeconds(seconds)

    local co = coroutine.running()

    assert(co ~= nil, "The main thread cannot wait!")

    local wakeupTime = CURRENT_TIME + seconds
	table.insert(WAITING_ON_TIME, {co, wakeupTime})

    return coroutine.yield(co)
end

rawset(_G, "waitSeconds", waitSeconds)
rawset(_G, "wait", waitSeconds)


local function killProcess(co)
    --[[local index = 1
	while index <= #WAITING_ON_TIME do
        if co == WAITING_ON_TIME[index][1] then
			table.remove(WAITING_ON_TIME, index)
			return
		else
			index = $1+1
        end
    end]]
	--local index = 1
	for i, proc in pairs(WAITING_ON_TIME) do
		if co == proc[1] then
			table.remove(WAITING_ON_TIME, i)
			--print("killed")
			return
		end
	end
	--print("didn't kill :(")
end
rawset(_G, "killProcess", killProcess)


local function wakeUpWaitingThreads(deltaTime)
    CURRENT_TIME = CURRENT_TIME + deltaTime

    local index = 1
	while index <= #WAITING_ON_TIME do
		local co, wakeupTime = unpack(WAITING_ON_TIME[index])
        if wakeupTime < CURRENT_TIME then
			table.remove(WAITING_ON_TIME, index)
			verboseRun(co)
		else
			index = $1+1
        end
    end
end

addHook("ThinkFrame", do wakeUpWaitingThreads(1) end)
	

local function waitSignal(signalName)
    local co = coroutine.running()
    assert(co ~= nil, "The main thread cannot wait!")

    if WAITING_ON_SIGNAL[signalStr] == nil then
	
        WAITING_ON_SIGNAL[signalName] = { co }
    else
        table.insert(WAITING_ON_SIGNAL[signalName], co)
    end

    return coroutine.yield()
end
rawset(_G, "waitSignal", waitSignal)
rawset(_G, "waitForSignal", waitSignal)


local function signal(signalName)
    local threads = WAITING_ON_SIGNAL[signalName]
    if threads == nil then return end

    WAITING_ON_SIGNAL[signalName] = nil
    for _, co in ipairs(threads) do
        verboseRun(co)
    end
end
rawset(_G, "signal", signal)


local function runProcess(func, ...)

    local co = coroutine.create(func)
    verboseRun(co, ...)
	return co
end
rawset(_G, "runProcess", runProcess)


local function clearProcesses()
	WAITING_ON_TIME = {}
	WAITING_ON_SIGNAL = {}
end
rawset(_G, "clearProcesses", clearProcesses)



rawset(_G, "TASK", {})

function TASK:Run(func, ...)
	local co = coroutine.create(func)
	verboseRun(co, ...)
	return co
	--return ret
end


function TASK:Regist(func, ...)
	return runProcess(func, ...)
end
	
function TASK:Kill(co)
	killProcess(co)
	return ret
end

function TASK:Destroy(co)
	killProcess(co)
end
-------------------------------------------

