-- Do not add a duplicate script
if evm_added == true then return end

rawset(_G, "evm_added", true)

rawset(_G, "dev_Name", "rnm39")
rawset(_G, "dev_Desc", "EventMan (event index) was made by reinamoon (chi.miru)"
.." do not use my script without permission from me")
rawset(_G, "dev_Year", "2016-2017")

rawset(_G, "evm_version_string", "v0.03")
rawset(_G, "evm_version", 0)
rawset(_G, "evm_subversion", 03)

-- not plusc destroy incompatible functions
if (MODID == 15) then

else
	if pcall(function() return S_GetMusicPosition end) then --[[function exists]] else
		print("S_GetMusicPosition and S_SetMusicPosition do not exist in this build. Destroying functions..")
		rawset(_G, "S_GetMusicPosition", function()
			return 0
		end)
		rawset(_G, "S_SetMusicPosition", function()
			return 0
		end)
	end
	
	if pcall(function() return P_SetActiveMotionBlur end) then --[[function exists]] else
		print("P_SetActiveMotionBlur does not exist in this build. Destroying function..")
		rawset(_G, "P_SetActiveMotionBlur", function()
			return 0
		end)
	end
	
	if pcall(function() return G_SetDisplayPlayer end) then --[[function exists]] else
		print("G_SetDisplayPlayer does not exist in this build. Destroying function..")
		rawset(_G, "G_SetDisplayPlayerr", function()
			return 0
		end)
	end
end

if (MODID == 15) then

else
	if pcall(function() return P_SetActiveMotionBlur end) then --[[function exists]] else
		print("P_SetActiveMotionBlur does not exist in this build. Destroying function..")
		rawset(_G, "P_SetActiveMotionBlur", function()
			return 0
		end)
	end

end

if (MODID == 15) then

else
	if pcall(function() return G_SetDisplayPlayer end) then --[[function exists]] else
		print("G_SetDisplayPlayer does not exist in this build. Destroying function..")
		rawset(_G, "G_SetDisplayPlayerr", function()
			return 0
		end)
	end
end