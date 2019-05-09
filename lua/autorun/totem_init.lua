if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("totem/sh_init.lua")
	AddCSLuaFile("totem/cl_init.lua")

	AddCSLuaFile("totem/client/cl_menu.lua")
	AddCSLuaFile("totem/client/cl_lang.lua")
end

include("totem/sh_init.lua")

if SERVER then
	include("totem/init.lua")
else
	include("totem/cl_init.lua")
end
