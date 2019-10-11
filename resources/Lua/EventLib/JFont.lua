--=================================================================
-- FONT
-- ---------
-- FONT-DRAWING
--=================================================================

if (useJFont) then

local function SplitString(str)
  local t = {}
  local function helper(line) table.insert(t, line) return "" end
  helper((str:gsub("(.-)\r?\n", helper)))
  return t
end

local function RRStringWidth(string)
 if string == nil then return false end
 string = tostring(string)
 
 local templength = 0
 local finallength = 0
 
 for i = 1, #string
  if string:sub(i):byte() == 32
   templength = $1+7
  end
  
  if (string:sub(i):byte() > 32 and string:sub(i):byte() < 126)
   templength = $1+7
  end
  
 /* if string:sub(i):byte() == 10
   templength = 0
  end*/
  
  if templength > finallength
   finallength = templength
  end
 end
 
 return finallength
end

local function RRDrawString(v, x, y, string, flags, color, align)
	local trans = (flags & V_ALPHAMASK)
	flags = $1|V_ALLOWLOWERCASE
	if color != nil and tonumber(color) >= 1 and tonumber(color) <= 25
		color = v.getColormap(-1, color)
	else
		color = nil
	end
	
	if string == nil
		return false
	end
	
	string = tostring(string)
	
	local ls = SplitString(string)
	 
	for segment = 1, #ls
		local line = ls[segment]
		local cx = x << FRACBITS
		local cy = y << FRACBITS
		if align and type(align) == "string"
			if align == "center"
				cx = (x-(RRStringWidth(ls[segment])/2)) << FRACBITS
			elseif align == "right"
				cx = (x-RRStringWidth(ls[segment])) << FRACBITS
			end
		end
		local char
		
		//--Recognize rainbow
		local rainbow = 0
		local rainbowcolors = {
			// color list??
			SKINCOLOR_RED,
			SKINCOLOR_ORANGE,
			SKINCOLOR_YELLOW,
			SKINCOLOR_NEONGREEN,
			SKINCOLOR_TEAL,
			SKINCOLOR_LAVENDER,
		}
		/*
			SKINCOLOR_RED,
			SKINCOLOR_ORANGE,
			SKINCOLOR_YELLOW,
			SKINCOLOR_GREEN,
			SKINCOLOR_BLUE,
			SKINCOLOR_PURPLE,
		*/
		//--Recognize others
		local vibrating = 0
		local swirl = 0
		local cxshake, cyshake = 0, 0
		local scale = FRACUNIT
		local i = 0
		
		//for i = 1, #line
		while i < #line do i = $+1
			//--SPECIAL TYPE: RAINBOW/COLOR
			if line:byte(i) == 130
				color = nil
				rainbow = 0
				continue
			end
			
			if line:byte(i) >= 131 and line:byte(i) <= 155
				color = v.getColormap(-1, line:sub(i):byte() - 130)
				rainbow = 0
				continue
			end
			
			if line:byte(i) >= 156 and line:byte(i) <= 160 then
				rainbow = leveltime/(line:byte(i)-155) + 1
				continue
			end

			if rainbow then
				rainbow = $1+1
				while rainbow > #rainbowcolors do
					rainbow = $1-#rainbowcolors
				end
				color = v.getColormap(-1, rainbowcolors[rainbow])
			end
			//-----------------------------------------------
			
			//--SPECIAL TYPE: PAPER MARIO EFFECT
			if line:byte(i) == 161 then
				vibrating = (leveltime/1)*(leveltime/1)*3
				swirl = 0
				continue
			end
			//--Disable text animation
			if line:byte(i) == 162 then
				vibrating = 0
				cxshake = 0
				cyshake = 0
				swirl = 0
				continue
			end
			//--Enable text swirl
			if line:byte(i) == 163 then
				swirl = leveltime*2+1
				continue
			end
			//--Scale text size
			if line:sub(i, i+6) == "<scale " then
				i = $+7
				local holder = ""
				while line:byte(i) ~= (">"):byte() do
					holder = $ .. line:sub(i, i)
					i = $+1
				end
				
				scale = FloatF(holder)
				continue
			end
			//--Randomize and path text movement
			if swirl then
				swirl = $1+2
				cxshake = FixedDiv(cos(swirl<<27), 28000)
				cyshake = FixedDiv(sin(swirl<<27), 28000)
			elseif vibrating then
				vibrating = (($1+4896)*$1+634890)%2984735+1
				cxshake = cos(vibrating*364) * 2
				vibrating = (($1+4896)*$1+634890)%2984735+1
				cyshake = cos(vibrating*382) * 2
				/*
				vibrating = (($1+4896)*$1+634890)%2984735+1
				cxshake = FixedMul(cos(vibrating*2964), 2)
				vibrating = (($1+4896)*$1+634890)%2984735+1
				cyshake = FixedMul(cos(vibrating*3482), 2)*/
			end
			//-----------------------------------------------

			char = line:sub(i, i)
			
			if not (flags & V_ALLOWLOWERCASE)
				char = tostring(char):upper()
			end
			
			if not char:byte() or char:byte() == 32
				cx = $1+7*scale
				continue
			end

			local charpatch
			
			if color != nil
				charpatch = v.cachePatch(string.format("RRFNC%03d", char:byte()))
			else
				charpatch = v.cachePatch(string.format("RRFNT%03d", char:byte()))
			end

			//v.drawScaled((cx+cxshake)<<FB, (cy+cyshake)<<FB, FloatF("0.6"), charpatch, trans, color)
			v.drawScaled(
				cx+cxshake, cy+cyshake+(8*(FRACUNIT-scale)),
				scale, charpatch, trans, color)
			
			cx = $1+7*scale
		end
		
		if (flags & V_RETURN8)
			y = $1+8
		else
			y = $1+12
		end
	end
end
/*
local function colors(v, p)
	local a = v.cachePatch("RRFNC065")
	for i = 1, 25 do
		v.draw(i*8, 150, a, 0, v.getColormap(-1, i))
	end
	
	RRDrawString(v, 312, 100, "It was then that he realized\nhis pretty font was \136right-aligned,\n\130and that some of it was also \143colorful.\n\n\130But whatever.", 0, nil, "right")
end

hud.add(colors)*/
rawset(_G, "RRDrawString", RRDrawString)
rawset(_G, "jDrawString", RRDrawString)

end