
-- Stores a list of parented and child objects
rawset(_G, "OPairList", {})

OPairList.parented = {}

local function addParent(child, parent, inpSpace, useRelativeAngle)
    local pos
    for i=1, #OPairList.parented do
        pos = i
        if OPairList.parented[i] == parent then
            break
        end
    end
    table.insert(OPairList.parented, (pos or 0)+1, child)
    child.parent = parent
	if (type(inpSpace) == "boolean") then
		child.localSpace = {x = child.x-parent.x,
							y = child.y-parent.y,
							z = child.z-parent.z}
	else
		child.localSpace = inpSpace or {x = 0, y = 0, z = 0} //{0, 0, 0}
	end
	if (useRelativeAngle) then
		child.relAngle = true
	end
end

local function detachParent(mo)
	for i=1, #OPairList.parented do 
		if OPairList.parented[i] == mo then 
			table.remove(OPairList.parented, i)
		end
	end
	mo.localSpace = {x = 0, y = 0, z = 0}
	mo.parent = nil
	mo.relAngle = nil
end

addHook("MapChange", do //Clear the OPairList.parented table on level change.
    OPairList.parented = {}
end)
addHook("ThinkFrame", do //Game thinker for the parenting system.
    for i=1, #OPairList.parented do
        while not OPairList.parented[i].valid do //There's one entry (or consecutive ones) that doesn't exist anymore? Let's remove it from the list.
            table.remove(OPairList.parented, i)
            print("\x84Note\x80: A mobj in the OPairList.parented table has been removed from the game.") //Purely informational note, disable at will.
            if #OPairList.parented == 0 then //Special case - The mobj we have removed from the table happened to be the last one in there, we exit the function.
                return
            end
        end
        local mo = OPairList.parented[i]
        local l, m = cos(mo.parent.angle), sin(mo.parent.angle)
        if (mo.relAngle) then
			P_TeleportMove(
				mo,
				mo.parent.x + FixedMul(m, mo.localSpace.x) + FixedMul(l, mo.localSpace.y),
				mo.parent.y - FixedMul(l, mo.localSpace.x) + FixedMul(m, mo.localSpace.y),
				mo.parent.z + mo.localSpace.z
			)
		else
			P_TeleportMove(
				mo,
				mo.parent.x + mo.localSpace.x,
				mo.parent.y + mo.localSpace.y,
				mo.parent.z + mo.localSpace.z
			)
		end
    end
end)


rawset(_G, "addParent", addParent)
rawset(_G, "addChild", addParent)
rawset(_G, "detatchParent", detatchParent)
