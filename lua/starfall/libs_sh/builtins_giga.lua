-- Global to all starfalls
local checkluatype = SF.CheckLuaType

local function cleanupRender(instance)
	instance:cleanupRender()
end

local isSP = game.SinglePlayer()

local haspermission = SF.Permissions.hasAccess

local function hudPrepareSafeArgs(instance, ...)
	if SF.IsHUDActive(instance.entity) and (haspermission(instance, nil, "render.hud") or instance.player == SF.Superuser) then
		instance:prepareRender()
		return true, {...}
	end
	return false
end

local controlsLocked = false
local function unlockControls(instance)
	instance.data.input.controlsLocked = false
	controlsLocked = false
	hook.Remove("PlayerBindPress", "sf_keyboard_blockinputEX")
	hook.Remove("PlayerButtonDown", "sf_keyboard_unblockinputEX")
end

local function lockControls(instance)
	instance.data.input.controlsLocked = true
	controlsLocked = true
	
	hook.Add("PlayerBindPress", "sf_keyboard_blockinputEX", function(ply, bind, pressed)
		if bind ~= "+attack" and bind ~= "+attack2" then return true end
	end)
end

if SERVER then
	--- File functions. Allows modification of files.
	-- @name fileServer
	-- @class library
	-- @libtbl fileServer_library
	SF.RegisterLibrary("fileServer")
else
	--- Used to render post processing effects. Requires HUD. (2D Context)
	-- @name drawscreenspace
	-- @class hook
	-- @client
	SF.hookAdd("RenderScreenspaceEffects", "drawscreenspace", hudPrepareSafeArgs, cleanupRender)
	
	--- Steamworks Library
	-- @name steamworks
	-- @class library
	-- @libtbl steamworks_library
	SF.RegisterLibrary("steamworks")
end

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap

local builtins_library = instance.env
local fileServer_library = instance.Libraries.fileServer
local render_library = instance.Libraries.render
local input_library = instance.Libraries.input
local steamworks_library = instance.Libraries.steamworks

local getent
local getply
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
	getply = instance.Types.Player.GetPlayer
end)

--- Forces the current instance to allow HUD drawing. Must be SuperAdmin to use.
-- @server
-- @param Player ply The player to enable the hud on. If CLIENT, will be forced to player()
-- @param boolean active Whether hud hooks should be active. true to force on, false to force off.
function builtins_library.enableHudAdmin(ply, active)
	if !instance.player:IsSuperAdmin() then SF.Throw("You are not a superadmin!") return end
	ply = SERVER and getply(ply)
	checkluatype(active, TYPE_BOOL)

	if ply==instance.player or (instance.player:IsSuperAdmin()) or (not active and SF.IsHUDActive(instance.entity, ply)) then
		SF.EnableHud(ply, instance.entity, nil, active)
	else
		local vehicle = ply:GetVehicle()
		if vehicle:IsValid() and SF.Permissions.getOwner(vehicle)==instance.player then
			SF.EnableHud(ply, instance.entity, vehicle, active)
		else
			SF.Throw("Player must be sitting in owner's vehicle or be owner of the chip!", 2)
		end
	end
end

--- Returns an iterator function that can be used to loop through a table in order of member values, when the values of the table are also tables and contain that member.
-- @shared
-- @param table table Table to create iterator for.
-- @param any key Key of the value member to sort by.
-- @param boolean? descending Whether the iterator should iterate in descending order or not.
-- @return function Iterator function.
-- @return table The table the iterator was created for.
function builtins_library.sortedPairsByMemberValue(tbl, mkey, desc)
	return SortedPairsByMemberValue(tbl, mkey, desc)
end

--- Sets the map's lighting. Slow on big maps with lots of static props.
-- @shared
-- @param string lightstyle The light style. "a" is darkest, "z" is brightest.
function builtins_library.setMapLighting(lightlevel)
	if SERVER then
		engine.LightStyle(0, lightlevel)
		
		local MapEnvLights = ents.FindByClass("light_environment")
			if table.Count(MapEnvLights) == 0 then
				ents.Create("light_environment")
			end
		for k, v in pairs(MapEnvLights) do
			v:Fire("SetPattern", lightlevel)
		end
	else
			render.RedownloadAllLightmaps(true, true)
	end
end

function builtins_library.setMapAmbientLight(clr, brightness)
	local MapEnvLights = ents.FindByClass("light_environment")
	if table.Count(MapEnvLights) == 0 then
		ents.Create("light_environment")
	end
	
	local c = cunwrap(clr)
	
	
	for _, v in pairs(MapEnvLights) do
		v:SetKeyValue("Ambient", c.r.." "..c.g.." "..c.b.." "..brightness)
		v:SetKeyValue("AmbientHDR", c.r.." "..c.g.." "..c.b.." "..brightness)
	end
end

--- Plays a sound from the specified position in the world. If you want to play a sound without a position, such as a UI sound, use playSoundUI instead.
-- @param string path The filepath to the sound.
-- @param Vector pos The pos to play the sound from.
-- @param number lvl Sound level in decibels. 75 is normal. Ranges from 20 to 180, where 180 is super loud. This affects how far away the sound will be heard.
-- @param number pitch An integer describing the sound pitch. Range is from 0 to 255. 100 is normal pitch.
-- @param number volume A float ranging from 0-1 describing the output volume of the sound.
function builtins_library.emitSoundWorld(fp, pos, lvl, pitch, vol)
	checkluatype(fp, TYPE_STRING)
	sound.Play(fp, vunwrap(pos), lvl, pitch, vol)
end

--- Returns a a list of all lists currently in use.
-- @return table The list of all lists, i.e. a table containing names of all lists.
function builtins_library.getAllLists()
	return list.GetTable()
end

--- Returns a list
-- @param string fromList Which list to retrieve. See getAllLists()
function builtins_library.getList(fromList)
	return list.Get(fromList)
end

if SERVER then

	--- Reads a file on server from path. SuperAdmin only.
	-- @server
	-- @param string path Filepath relative to data/.
	-- @return string? Contents, or nil if error
	function fileServer_library.read(path)
		if instance.player == SF.Superuser or instance.player:IsSuperAdmin() then
			return file.Read(path, "DATA")
		end
	end
	
	--- Writes a file to server. SuperAdmin only.
	-- @server
	-- @param string path Filepath relative to data/.
	-- @param string data The data to write
	function fileServer_library.write(filename, data)
		if instance.player == SF.Superuser or instance.player:IsSuperAdmin() then
			file.Write(filename, data)
		end
	end
	
	--- Appends a string to the end of a server file. SuperAdmin only.
	-- @server
	-- @param string path Filepath relative to data/.
	-- @param string data String that will be appended to the file.
	function fileServer_library.append(filename, data)
		if !instance.player:IsSuperAdmin() then return end
		file.Append(filename, data)
	end
	
	--- Reads a file asynchronously on server. Superadmin only.
	-- @server
	-- @param string path Filepath relative to data/.
	-- @param function callback A callback function for when the read operation finishes. It has 3 arguments: `filename` string, `status` number and `data` string
	function fileServer_library.asyncRead(path, callback)
		if !instance.player:IsSuperAdmin() then return end
		checkluatype (path, TYPE_STRING)
		checkluatype (callback, TYPE_FUNCTION)
		file.AsyncRead(path, "DATA", function(_, _, status, data)
			instance:runFunction(callback, path, status, data)
		end)
	end
	
	--- Checks if a file exists
	-- @param string path Filepath relative to data/sf_filedata/.
	-- @return boolean? True if exists, false if not, nil if error
	function fileServer_library.exists(path)
		checkluatype (path, TYPE_STRING)
		return file.Exists(path, "DATA")
	end
	
	--- Enumerates a directory
	-- @param string path The folder to enumerate, relative to data/sf_filedata/.
	-- @param string? sorting Optional sorting argument. Either nameasc, namedesc, dateasc, datedesc
	-- @return table Table of file names
	-- @return table Table of directory names
	function fileServer_library.find(path, sorting)
		return file.Find(path, "DATA", sorting)
	end
	
	--- Creates a directory
	-- @param string path Filepath relative to data/sf_filedata/.
	function fileServer_library.createDir(path)
		if !instance.player:IsSuperAdmin() then return end
		checkluatype (path, TYPE_STRING)
		file.CreateDir(path)
	end
else

	--- Forcefully runs a concmd as long as the owner of the chip is a superadmin.
	-- @param string cmd The console command to run.
	function builtins_library.concmdEX(cmd)
		if !instance.player:IsSuperAdmin() then return end
		LocalPlayer():ConCommand(cmd)
	end

	--- Sets the internal parameter INT_RENDERPARM_WRITE_DEPTH_TO_DESTALPHA. Allows you to make masks for rendertargets.
	-- @param boolean enable Enable writing depth to destination alpha.
	function render_library.setWriteDepthToDestAlpha(enable)
		render.SetWriteDepthToDestAlpha(enable)
	end

	--- Draws the Color Modify shader, which can be used to adjust colors on screen. Must be in drawscreenspace hook. Note that if you leave out a field, it will retain its last value which may have changed if another caller uses this function.
	-- @client
	-- @param table modifyparameters Color modification parameters. See https://wiki.facepunch.com/gmod/Shaders/g_colourmodify
	function render_library.drawColorModify(modparams)
		DrawColorModify(modparams)
	end

	--- Draws the bloom shader, which creates a glowing effect from bright objects. Must be in drawscreenspace hook.
	-- @client
	-- @param number darken Determines how much to darken the effect. A lower number will make the glow come from lower light levels. A value of 1 will make the bloom effect unnoticeable. Negative values will make even pitch black areas glow.
	-- @param number multiply Will affect how bright the glowing spots are. A value of 0 will make the bloom effect unnoticeable.
	-- @param number sizeY The size of the bloom effect along the horizontal axis.
	-- @param number sizeX The size of the bloom effect along the vertical axis.
	-- @param number passes Determines how much to exaggerate the effect.
	-- @param number colormultiply Will multiply the colors of the glowing spots, making them more vivid.
	-- @param number red How much red to multiply with the glowing color. Should be between 0 and 1.
	-- @param number green How much green to multiply with the glowing color. Should be between 0 and 1.
	-- @param number blue How much blue to multiply with the glowing color. Should be between 0 and 1.
	function render_library.drawBloom(darken, multiply, sizex, sizey, passes, colormultiply, red, green, blue)
		DrawBloom(darken, multiply, sizex, sizey, passes, colormultiply, red, green, blue)
	end
	
	--- Draws a material overlay on the screen. Must be in drawscreenspace hook.
	-- @client
	-- @param string matpath This will be the material that is drawn onto the screen.
	-- @param number refractamount This will adjust how much the material will refract your screen.
	function render_library.drawMaterialOverlay(mat, refract)
		DrawMaterialOverlay(mat, refract)
	end
	
	--- Creates a motion blur effect by drawing your screen multiple times. Must be in drawscreenspace hook.
	-- @client
	-- @param number addalpha How much alpha to change per frame.
	-- @param number drawalpha How much alpha the frames will have. A value of 0 will not render the motion blur effect.
	-- @param number delay Determines the amount of time between frames to capture.
	function render_library.drawMotionBlur(addalpha, drawalpha, delay)
		DrawMotionBlur(addalpha, drawalpha, delay)
	end
	
	--- Draws the sharpen shader, which creates more contrast. Must be in drawscreenspace hook.
	-- @client
	-- @param number contrast How much contrast to create.
	-- @param number distance How large the contrast effect will be.
	function render_library.drawSharpen(contrast, dist)
		DrawSharpen(contrast, dist)
	end
	
	--- Draws the sobel shader, which detects edges and draws a black border. Must be in drawscreenspace hook.
	-- @client
	-- @param number threshold Determines the threshold of edges. A value of 0 will make your screen completely black.
	function render_library.drawSobel(thres)
		DrawSobel(thres)
	end
	
	--- Draws the toy town shader, which blurs the top and bottom of your screen. This can make very large objects look like toys, hence the name. Must be in drawscreenspace hook.
	-- @client
	-- @param number passes An integer determining how many times to draw the effect. A higher number creates more blur.
	-- @param number height The amount of screen which should be blurred on the top and bottom.
	function render_library.drawToyTown(pass, height)
		DrawToyTown(pass, height)
	end
	
	--- Sets the color modulation.
	-- @client
	-- @param number r The red channel multiplier normal ranging from 0-1.
	-- @param number g The green channel multiplier normal ranging from 0-1.
	-- @param number b The blue channel multiplier normal ranging from 0-1.
	function render_library.setColorModulation(r, g, b)
		if instance.player == SF.Superuser or instance.player:IsSuperAdmin() then
			render.SetColorModulation(r, g, b)
		end
	end
	
	--- Sets the lighting origin.
	-- @param Vector pos The position from which the light should be "emitted".
	function render_library.setLightingOrigin(pos)
		if !instance.player:IsSuperAdmin() then return end
		render.SetLightingOrigin(vunwrap(pos))
	end
	
	--- Sets up the local lighting for any upcoming render operation. Up to 4 local lights can be defined, with one of three different types (point, directional, spot).
	--- Disables all local lights if called with no arguments.
	-- @param table lights A table containing up to 4 tables for each light source that should be set up. Each of these tables should contain the properties of its associated light source, see https://wiki.facepunch.com/gmod/Structures/LocalLight.
	function render_library.setLocalModelLights(tbl)
		if !instance.player:IsSuperAdmin() then return end
		render.SetLocalModelLights(instance.Sanitize(tbl))
	end
	
	--- Overrides the write behaviour of all next rendering operations towards the alpha channel of the current render target.
	-- @param boolean enable Enable or disable the override.
	-- @param boolean shouldwrite If the previous argument is true, sets whether the next rendering operations should write to the alpha channel or not. Has no effect if the previous argument is false.
	function render_library.overrideAlphaWriteEnable(enable, shouldwrite)
		if !instance.player:IsSuperAdmin() then return end
		render.OverrideAlphaWriteEnable( enable, shouldwrite )
	end
	
	--- Play a sound file directly on the client (such as UI sounds, etc).
	-- @client
	-- @param string path The path to the sound file, which must be relative to the sound/ folder.
	function builtins_library.playSoundUI(snd)
		surface.PlaySound(snd)
	end
		
	local pixelVisList = {}
	function DrawVolLight( ent, mul, dark, size, distance, mindist )
		local pos = ent:GetPos()
		local cl = ent:GetClass()
		local scrpos = pos:ToScreen()

		-- This is dirty, yeah
		local dista = -1
		for k, t in pairs( pixelVisList ) do
			if ( t.c != cl ) then continue end
			dista = Vector( scrpos.x, scrpos.y, 0 ):Distance( Vector( t.x, t.y, 0 ) )
			if ( dista < mindist ) then break end
		end
		if ( dista > 0 && dista < mindist ) then return end

		local viewdiff = ( pos - EyePos() )
		local viewdir = viewdiff:GetNormal()
		local dot = ( viewdir:Dot( EyeVector() ) - 0.8 ) * 5
		local dp = math.Clamp( ( ( 1.5 + dot ) * 0.666 ), 0, 1 )
		local Dist = EyePos():Distance( pos )
		dot = dot * dp

		if ( dot > 0 && Dist < distance ) then
			DrawSunbeams( dark, ( mul * dot ) / math.Clamp( Dist / distance, 1, 100 * ( mul * dot ) ), size / Dist, scrpos.x / ScrW(), scrpos.y / ScrH() )
			table.insert( pixelVisList, { x = scrpos.x, y = scrpos.y, c = cl } )
		end
	end

	local function VolLightTestLOS( ent1, ent2 )
		local trace = util.TraceLine( {
			start = ent1:GetShootPos(),
			endpos = ent2:GetPos(),
			filter = { ent1, ent2, ent2:GetParent() }
		 } )

		return trace.Hit
	end

	--- Draw volumetric light coming from an entity. Based off Rubat's Adv. Light Rays. Must be in drawscreenspace hook.
	-- @client
	-- @param Entity drawent The entity to draw light from.
	-- @param number multiply How strong the effect will be.
	-- @param number darken How much to suppress the effect.
	-- @param number size How big the light source will be.
	-- @param number maxdist How far the effect can be seen.
	-- @param number mindist The minimum distance (on screen, not in-game world) between each effect entity in pixels. If you're unsure, set it to 128.
	function render_library.drawVolLight(ent, mul, dark, size, distance, mindist)
		if VolLightTestLOS( LocalPlayer(), eunwrap(ent) ) then return end
		DrawVolLight(eunwrap(ent), mul, dark, size, distance, mindist)
	end
	
	--- Locks game controls for typing purposes. SuperAdmin only.
	-- @client
	-- @param boolean enabled Whether to lock or unlock the controls
	function input_library.lockControlsEX(enabled)
		if !instance.player:IsSuperAdmin() then SF.Throw("You are not a superadmin!") return end
		checkluatype(enabled, TYPE_BOOL)
		checkpermission(instance, nil, "input")

		if not SF.IsHUDActive(instance.entity) and (enabled or not instance.data.input.controlsLocked) then
			SF.Throw("No HUD component connected", 2)
		end

		if enabled then
			lockedControlCooldown = CurTime()
			lockControls(instance)
		else
			unlockControls(instance)
		end
	end
	
	--- Loads a GMod save from the workshop. SP only.
	-- @client
	-- @param number saveid The save's workshop ID.
	function builtins_library.loadWorkshopSave(id)
		if !game.SinglePlayer then return end
		
		steamworks.DownloadUGC( id, function( name )
			RunConsoleCommand("gm_load", name)
		end )
	end
	
	--- Downloads a file from the supplied addon and saves it as a .cache file in garrysmod/cache folder.
	-- @client
	-- @param number previewid The Preview ID of workshop item.
	-- @param function callback The function to process retrieved data. The first and only argument is a string, containing path to the saved file.
	function steamworks_library.download(previd, callback)
		if !isSP then return end
		
		steamworks.Download(previd, true, function(name)
			instance:runFunction(callback, name)
		end)
	end
	
	--- Retrieves info about supplied Steam Workshop addon.
	-- @client
	-- @param number workshopid The ID of Steam Workshop item.
	-- @param function callback The function to process retrieved data, with one argument which is the data about the item. See https://wiki.facepunch.com/gmod/Structures/UGCFileInfo.
	function steamworks_library.fileInfo(wsid, callback)
		if !isSP then return end
		
		steamworks.FileInfo(wsid, function(tbl)
			instance:runFunction(callback, tbl)
		end)
	end
	
	--- Retrieves a customized list of Steam Workshop addons.
	-- @client
	-- @param string? type The type of items to retrieve. Check https://wiki.facepunch.com/gmod/steamworks.GetList
	-- @param table? tags A table of tags to match.
	-- @param number? offset How much of results to skip from first one. Mainly used for pages.
	-- @param number? toRetrieve How much items to retrieve, up to 50 at a time.
	-- @param number? days When getting Most Popular content from Steam, this determines a time period. ( 7 = most popular addons in last 7 days, 1 = most popular addons today, etc )
	-- @param number? userid "0" to retrieve all addons, "1" to retrieve addons only published by you, or a valid SteamID64 of a user to get workshop items of.
	-- @param function callback The function to process retrieved data. The first and only argument is a table, containing all the info, or nil in case of error.
	function steamworks_library.getList(tp, tags, offset, retr, days, userid, callback)
		tp = tp or "popular"
		offset = offset or 0
		retr = retr or 5
		days = days or 7
		userid = userid or 0
		
		steamworks.GetList(tp, tags, offset, retr, days, userid, function(data)
			instance:runFunction(callback, data)
		end)
	end
	
	--- Loads the specified image from the /cache folder, used in combination steamworks.download. Most addons will provide a 512x512 png image.
	-- @client
	-- @param string name The name of the file.
	-- @return Material The material, returns nil if the cached file is not an image.
	function builtins_library.addonMaterial(name)
		if !isSP then return end

		return instance.Types.Material.Wrap(AddonMaterial(name))
	end
	
	--- Opens specified URL in the steam overlay browser.
	-- @client
	-- @param string url URL to open, it has to start with either http:// or https://.
	function steamworks_library.openURL(url)
		if !isSP then return end
		
		gui.OpenURL(url)
	end
end

end