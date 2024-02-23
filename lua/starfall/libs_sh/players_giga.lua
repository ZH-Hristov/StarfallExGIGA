-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

--Can only return if you are the first argument
local function returnOnlyOnYourself(instance, args, ply)
	if args[1] and instance.player == ply or superOrAdmin(instance) then return args[2] end
end

local function adminOnlyReturnHook(instance, args, ply)
	if instance.player:IsAdmin() then return args[2] end
end

local function superOrAdmin(instance)
	if instance.player == SF.Superuser then return true end
	if instance.player:IsSuperAdmin() then return true end
	return false
end

duplicator.RegisterEntityModifier( "STARFALL_SAVETRIGGERS", function(ply, dent, data)
	for k, v in pairs(data) do
		if isnumber(v) then
			dent:SetNWFloat(k, v)
		elseif isstring(v) then
			dent:SetNWString(k, v)
		elseif isvector(v) then
			dent:SetNWVector(k, v)
		elseif isentity(v) then
			dent:SetNWEntity(k, v)
		end
	end
end)

--- CMoveData type
-- @name CMoveData
-- @class type
-- @libtbl cmv_methods
-- @libtbl cmv_meta
SF.RegisterType("CMoveData", false, true, debug.getregistry().CMoveData)

--- CUserCmd type
-- @name CUserCmd
-- @class type
-- @libtbl cuc_methods
-- @libtbl cuc_meta
SF.RegisterType("CUserCmd", false, true, debug.getregistry().CUserCmd)

--- ProjectedTexture type
-- @name ProjectedTexture
-- @class type
-- @client
-- @libtbl pt_methods
-- @libtbl pt_meta
SF.RegisterType("ProjectedTexture", false, true, debug.getregistry().ProjectedTexture)

--- Called when a player makes contact with the ground after a jump or a fall.
-- @name OnPlayerHitGround
-- @class hook
-- @shared
-- @param Player ply Player
-- @param boolean inWater Did the player land in water?
-- @param boolean onFloater Did the player land on an object floating in the water?
-- @param number speed The speed at which the player hit the ground
-- @return boolean? Return true to suppress default action. Admin Only.
SF.hookAdd("OnPlayerHitGround", nil, nil, adminOnlyReturnHook)

--- Called when a player jumps.
-- @name OnPlayerJump
-- @class hook
-- @shared
-- @param Player ply Player
-- @param number speed The velocity/impulse of the jump
SF.hookAdd("OnPlayerJump", nil, nil)

--- Animation updates (pose params etc) should be done here.
-- @name UpdateAnimation
-- @class hook
-- @shared
-- @param Player ply Player
-- @param Vector velocity The player's velocity.
-- @param number maxSeqGroundSpeed Speed of the animation - used for playback rate scaling.
SF.hookAdd("UpdateAnimation", nil, nil)

--- Called after the player's think.
-- @name PlayerPostThink
-- @class hook
-- @shared
-- @param Player ply The player.
SF.hookAdd("PlayerPostThink")

--- Allows you to translate player activities.
-- @name TranslateActivity
-- @class hook
-- @shared
-- @param Player ply The player
-- @param number act The activity. See https://wiki.facepunch.com/gmod/Enums/ACT
-- @return number The new, translated activity.
SF.hookAdd("TranslateActivity", nil, nil, function(instance, args, ply, act)
	if ply:GetOwner() == instance.player or superOrAdmin(instance) or instance.player==SF.Superuser then
		if args[2] then return args[2] end
	end
end)

--- This hook is used to calculate animations for a player.
--- This hook must return the same values at the same time on both, client and server. On client for players to see the animations, on server for hit detection to work properly.
-- @name CalcMainActivity
-- @class hook
-- @shared
-- @param Player ply The player
-- @param Vector velocity The velocity of the player.
-- @return number Enums/ACT for the activity the player should use. A nil return will be treated as ACT_INVALID.
SF.hookAdd("CalcMainActivity", nil, nil, function(instance, args, ply, velocity)
	if ply:GetOwner() == instance.player or superOrAdmin(instance) or instance.player==SF.Superuser then
		if args[2] then return args[2], args[3] end
	end
end)

--- Called when a player takes bullet damage.
-- @name ScalePlayerDamage
-- @class hook
-- @shared
-- @param Player ply The player taking damage.
-- @param number hitgroup The hitgroup (hitbox) enum where the player took damage.
-- @param entity attacker The attacker.
-- @param entity inflictor The inflictor.
-- @param number dmg The amount of damage.
-- @param number dmgtype The damage type enum.
-- @param Vector dmgpos Damage pos.
-- @param Vector dmgforce Damage force.
-- @return number? Return to scale the damage by the scaler variable.
SF.hookAdd("ScalePlayerDamage", nil, function(instance, ply, hitgr, dmg) 
	return true, {
		instance.WrapObject(ply),
		hitgr,
		instance.WrapObject(dmg:GetAttacker()),
		instance.WrapObject(dmg:GetInflictor()),
		dmg:GetDamage(),
		dmg:GetDamageType(),
		instance.Types.Vector.Wrap(dmg:GetDamagePosition()),
		instance.Types.Vector.Wrap(dmg:GetDamageForce())
	}
	end, function(instance, args, ply, hitgr, dmginfo)
	if args[2] and superOrAdmin(instance) then dmginfo:ScaleDamage(args[2]) end
end)

--- Allows you to change the players inputs before they are processed by the server.
-- @name StartCommand
-- @class hook
-- @shared
-- @param Player ply The player.
-- @param CUserCmd cmd The usercommand.
SF.hookAdd("StartCommand", nil, function(instance, ply, cmd)
	return true, {
		instance.WrapObject(ply),
		instance.WrapObject(cmd)
	}
end)

--- SetupMove is called before the engine process movements. This allows us to override the players movement.
-- @name SetupMove
-- @class hook
-- @shared
-- @param Player ply The player whose movement we are about to process.
-- @param CMoveData mv The move data to override/use.
-- @param CUserCmd cmd The command data.
SF.hookAdd("SetupMove", nil, function(instance, ply, mv, cmd)
	return true, {
		instance.WrapObject(ply),
		instance.WrapObject(mv),
		instance.WrapObject(cmd)
	}
end)

--- Allows you to change the players movements before they're sent to the server.
-- @name CreateMove
-- @class hook
-- @client
-- @param CUserCmd cmd The command data.
SF.hookAdd("CreateMove", nil, function(instance, cmd)
	return true, {
		instance.WrapObject(cmd)
	}
end)

--- FinishMove is called after the engine process movements.
-- @name FinishMove
-- @class hook
-- @shared
-- @param Player ply The player whose movement was processed.
-- @param CMoveData mv The processed.
SF.hookAdd("FinishMove", nil, function(instance, ply, mv)
	return true, {
		instance.WrapObject(ply),
		instance.WrapObject(mv)
	}
end)

--- Called whenever a player steps. Return true to mute the normal sound if superadmin.
-- @name PlayerFootstep
-- @return boolean? Return true to mute normal sound.
-- @class hook
-- @param Player ply The stepping player.
-- @param Vector pos The position of the step.
-- @param number step Foot that is stepped. 0 for left, 1 for right.
-- @param string sound Sound that is going to play.
-- @param number volume Volume of the footstep
SF.hookAdd("PlayerFootstep", nil, function(instance, ply, pos, step, sound, vol) return true, {
	instance.WrapObject(ply),
	instance.Types.Vector.Wrap(pos),
	step,
	sound,
	vol
} end, adminOnlyReturnHook)

--- Called when a player presses a button.
-- @name PlayerButtonDown
-- @class hook
-- @param Player ply Player who pressed the button.
-- @param number button The button.
SF.hookAdd("PlayerButtonDown", nil, function(instance, ply, button) return true, {
	instance.WrapObject(ply),
	button
} end, nil)

--- Called when a player releases a button.
-- @name PlayerButtonUp
-- @class hook
-- @param Player ply Player who released the button.
-- @param number button The button.
SF.hookAdd("PlayerButtonUp", nil, function(instance, ply, button) return true, {
	instance.WrapObject(ply),
	button
} end, nil)

--- Called to decide whether a pair of entities should collide with each other. This is only called if Entity:setCustomCollisionCheck was used on one or both entities. This hook must return the same value consistently for the same pair of entities. This hook can cause all physics to break under certain conditions.
-- @name ShouldCollide
-- @class hook
-- @param Entity ent1 The first entity in the collision poll.
-- @param Entity ent2 The second entity in the collision poll.
-- @return boolean Whether the entities should collide.
SF.hookAdd("ShouldCollide", nil, function(instance, ent1, ent2) return true, {instance.WrapObject(ent1), instance.WrapObject(ent2)} end, adminOnlyReturnHook)

--- Library for creating Starfall triggers.
-- @name trigger
-- @class library
-- @libtbl trigger_library
SF.RegisterLibrary("trigger")

--- Library for creating Projected Textures.
-- @name projectedtexture
-- @class library
-- @client
-- @libtbl projectedtexture_library
SF.RegisterLibrary("projectedtexture")

if SERVER then

	--- Called when a player takes damage from falling, allows to override the damage.
	-- @name GetFallDamage
	-- @class hook
	-- @server
	-- @param Player ply The player
	-- @param number speed The fall speed
	-- @return number New fall damage
	SF.hookAdd("GetFallDamage", nil, nil, adminOnlyReturnHook)
	
	--- Returns true if the player should take damage from the given attacker. SuperAdmin only.
	-- @name PlayerShouldTakeDamage
	-- @class hook
	-- @server
	-- @param Player ply The Player
	-- @param entity attacker The attacker
	-- @return boolean Allow damage
	SF.hookAdd("PlayerShouldTakeDamage", nil, nil, adminOnlyReturnHook)
	
	--- Called when an NPC takes damage.
	-- @name ScaleNPCDamage
	-- @class hook
	-- @server
	-- @param npc npc The NPC that takes damage
	-- @param number hitgroup The hitgroup (hitbox) enum where the NPC took damage.
	-- @param entity attacker The attacker.
	-- @param entity inflictor The inflictor.
	-- @param number dmg The amount of damage.
	-- @param number dmgtype The damage type enum.
	-- @param Vector dmgpos Damage pos.
	-- @param Vector dmgforce Damage force.
	-- @return number? Return to scale the damage by the scaler variable.
	SF.hookAdd("ScaleNPCDamage", nil, function(instance, ply, hitgr, dmg) 
		return true, {
			instance.WrapObject(ply),
			hitgr,
			instance.WrapObject(dmg:GetAttacker()),
			instance.WrapObject(dmg:GetInflictor()),
			dmg:GetDamage(),
			dmg:GetDamageType(),
			instance.Types.Vector.Wrap(dmg:GetDamagePosition()),
			instance.Types.Vector.Wrap(dmg:GetDamageForce())
		}
		end, function(instance, args, ply, hitgr, dmginfo)
		if args[2] and superOrAdmin(instance) then dmginfo:ScaleDamage(args[2]) end
	end)
	
	--- Called when a Starfall trigger is activated.
	-- @name OnStarFallTrigger
	-- @class hook
	-- @server
	-- @param Player ply The player that activated the trigger.
	-- @param string trigid The trigger's ID name.
	-- @param entity trigger The trigger entity that was activated.
	-- @param number state The touch state. Returns 1 if the touch was just started, -1 if the touch just ended, 0 for every tick the entity is being touched.
	SF.hookAdd("OnStarfallTrigger")
	
	--- Called when an entity is damaged
	-- @name EntityTakeDamageAdmin
	-- @class hook
	-- @server
	-- @param Entity target Entity that is hurt
	-- @param Entity attacker Entity that attacked
	-- @param Entity inflictor Entity that inflicted the damage
	-- @param number amount How much damage
	-- @param number type Type of the damage
	-- @param Vector position Position of the damage
	-- @param Vector force Force of the damage
	-- @return boolean Return true to block the damage event.
	SF.hookAdd("EntityTakeDamage", "entitytakedamageadmin", function(instance, target, dmg)
		return true, {
			instance.WrapObject(target),
			instance.WrapObject(dmg:GetAttacker()),
			instance.WrapObject(dmg:GetInflictor()),
			dmg:GetDamage(),
			dmg:GetDamageType(),
			instance.Types.Vector.Wrap(dmg:GetDamagePosition()),
			instance.Types.Vector.Wrap(dmg:GetDamageForce())
		}
	end, adminOnlyReturnHook)
	
	--- Returns whether or not a player is allowed to pick an item up. Return false to disallow pickup. (Admin only)
	--- Admins can return to set whether the pickup is allowed.
	-- @name PlayerCanPickupItem
	-- @class hook
	-- @server
	-- @param Player player Player attempting to pick up
	-- @param Entity item The item the player is attempting to pick up
	SF.hookAdd("PlayerCanPickupItem", nil, function(instance, ply, item)
		return true, {
			instance.WrapObject(ply),
			instance.WrapObject(item)
		}
	end, adminOnlyReturnHook)
	
	--- Called when an entity receives a damage event, after passing damage filters, etc.
	-- @name PostEntityTakeDamage
	-- @class hook
	-- @server 
	-- @param Entity target Entity that is hurt
	-- @param Entity attacker Entity that attacked
	-- @param Entity inflictor Entity that inflicted the damage
	-- @param number amount How much damage
	-- @param boolean took Whether the entity actually took the damage. (For example, shooting a Strider will generate this event, but it won't take bullet damage).
	-- @param number type Type of the damage
	-- @param Vector position Position of the damage
	-- @param Vector force Force of the damage
	SF.hookAdd("PostEntityTakeDamage", nil, function(instance, target, dmg, took)
		return true, {
			instance.WrapObject(target),
			instance.WrapObject(dmg:GetAttacker()),
			instance.WrapObject(dmg:GetInflictor()),
			dmg:GetDamage(),
			took,
			dmg:GetDamageType(),
			instance.Types.Vector.Wrap(dmg:GetDamagePosition()),
			instance.Types.Vector.Wrap(dmg:GetDamageForce())
		}
	end, nil)
	
	--- Called to give players the default set of weapons. Return true to prevent default loadout. (Admin only)
	-- @name PlayerLoadout
	-- @class hook
	-- @server
	-- @param Player Player to give weapons to.
	SF.hookAdd("PlayerLoadout", nil, function(instance, ply)
		return true, {
			instance.WrapObject(ply)
		}
	end, adminOnlyReturnHook)
	
	--- Called when a player switches their weapon. Allows overriding if admin.
	-- @name PlayerSwitchWeaponEX
	-- @class hook
	-- @server
	-- @param Player ply Player changing weapon
	-- @param Weapon oldwep Old weapon
	-- @param Weapon newweapon New weapon
	-- @return boolean Return true to disallow weapon switch.
	SF.hookAdd("PlayerSwitchWeapon", "playerswitchweaponex", nil, adminOnlyReturnHook)
	
	--- Called when a serverside ragdoll of an entity has been created.
	-- @name CreateEntityRagdoll
	-- @class hook
	-- @server
	-- @param Entity owner Entity that owns the ragdoll.
	-- @param Entity ragdoll The ragdoll entity.
	SF.hookAdd("CreateEntityRagdoll", nil, function(instance, owner, rag)
		return true, {
			instance.WrapObject(owner),
			instance.WrapObject(rag)
		}
	end)
	
else

	--- Allows you to modify the supplied User Command with mouse input. This could be used to make moving the mouse do funky things to view angles.
	-- @name InputMouseApply
	-- @class hook
	-- @client
	-- @param CUserCmd cmd User command.
	-- @param number x The amount of mouse movement across the X axis this frame.
	-- @param number y The amount of mouse movement across the Y axis this frame.
	-- @param Angle ang The current view angle.
	-- @return boolean? Return true if we modified something.
	SF.hookAdd("InputMouseApply", nil, nil, adminOnlyReturnHook)
	
	--- Called whenever an entity becomes a clientside ragdoll.
	-- @name CreateClientsideRagdoll
	-- @class hook
	-- @client
	-- @param Entity owner Entity that owns the ragdoll.
	-- @param Entity ragdoll The ragdoll entity.
	SF.hookAdd("CreateClientsideRagdoll", nil, function(instance, owner, rag)
		return true, {
			instance.WrapObject(owner),
			instance.Types.Entity.Wrap(rag)
		}
	end)
end

return function(instance)

local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local player_methods, player_meta, wrap, unwrap = instance.Types.Player.Methods, instance.Types.Player, instance.Types.Player.Wrap, instance.Types.Player.Unwrap
local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local wep_meta, wwrap, wunwrap, weapon_methods = instance.Types.Weapon, instance.Types.Weapon.Wrap, instance.Types.Weapon.Unwrap, instance.Types.Weapon.Methods
local veh_meta, vhwrap, vhunwrap = instance.Types.Vehicle, instance.Types.Vehicle.Wrap, instance.Types.Vehicle.Unwrap
local cwrap, cunwrap = instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local cmv_meta, cuc_meta, cmv_methods, cuc_methods = instance.Types.CMoveData, instance.Types.CUserCmd, instance.Types.CMoveData.Methods, instance.Types.CUserCmd.Methods
local npc_methods, npc_meta, npcwrap, npcunwrap = instance.Types.Npc.Methods, instance.Types.Npc, instance.Types.Npc.Wrap, instance.Types.Npc.Unwrap
local pt_meta, pt_methods = instance.Types.ProjectedTexture, instance.Types.ProjectedTexture.Methods
local trigger_library, projectedtexture_library = instance.Libraries.trigger, instance.Libraries.projectedtexture
local math_library = instance.Libraries.math
local instancekey = "SF_"..instance.entity:EntIndex().."_"

local function getply(self)
	local ent = unwrap(self)
	if ent:IsValid() then
		return ent
	else
		SF.Throw("Entity is not valid.", 3)
	end
end

local FrozenPlayers, triggers, nwents, animatableprops

local nwvarremovecase = {
	Int = function(ent, key) ent:SetNW2Int(key, nil) end,
	Float = function(ent, key) ent:SetNW2Float(key, nil) end,
	String = function(ent, key) ent:SetNW2String(key, nil) end,
	Vector = function(ent, key) ent:SetNW2Vector(key, nil) end,
	Angle = function(ent, key) ent:SetNW2Angle(key, nil) end,
	Bool = function(ent, key) ent:SetNW2Bool(key, nil) end,
	Player = function(ent, key) ent:SetNW2Entity(key, nil) end,
	Entity = function(ent, key) ent:SetNW2Entity(key, nil) end
}

instance:AddHook("initialize", function()
	FrozenPlayers = {}
	triggers = {}
	nwents = {}
	animatableprops = {}
end)

instance:AddHook("deinitialize", function()
	if #FrozenPlayers > 0 then
		for _, v in pairs(FrozenPlayers) do
			v:Freeze(false)
		end
	end
	
	if #triggers > 0 then
		for _, v in pairs(triggers) do
			SafeRemoveEntity(v)
		end
	end

	for ent, _ in pairs(animatableprops) do
		SafeRemoveEntity(ent)
	end
	
	if !table.IsEmpty(nwents) then
		for ent, _ in ipairs(nwents) do
			local curent = Entity(ent)
			local curtbl = curent:GetNW2VarTable()
			for k, v in pairs(curtbl) do
				if string.StartWith(k, instancekey) and k.type then
					nwvarremovecase[v.type](curent, k)
				end
			end
		end
	end
end)

--- Cubic Hermite spline algorithm.
--@param number Fraction From 0 to 1, where alongside the spline the point will be.
--@param Vector p0 First point for the spline.
--@param Vector tan0 Tangent for the first point for the spline.
--@param Vector p1 Second point for the spline.
--@param Vector tan1 Tangent for the second point for the spline.
--@return Vector Point on the cubic Hermite spline, at given fraction.
function math_library.cubicHermiteSpline(frac, p0, tan0, p1, tan1)
	return vwrap( math.CHSpline(frac, vunwrap(p0), vunwrap(tan0), vunwrap(p1), vunwrap(tan1)) )
end

--- Sets the specified integer on the entity's datatable.
--@param number key Goes from 0 to 31.
--@param number int The integer to write on the entity's datatable. This will be cast to a 32-bit signed integer internally.
function ents_methods:setDTInt(key, int)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		eunwrap(self):SetDTInt(key, int)
	end
end

--- Sets the specified float on the entity's datatable.
--@param number key Goes from 0 to 31.
--@param number float The float to write on the entity's datatable.
function ents_methods:setDTFloat(key, float)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		eunwrap(self):SetDTFloat(key, float)
	end
end

--- Sets the specified vector on the entity's datatable.
--@param number key Goes from 0 to 31.
--@param Vector vec The vector to write on the entity's datatable.
function ents_methods:setDTVector(key, vec)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		eunwrap(self):SetDTVector(key, vunwrap(vec))
	end
end

--- Sets the specified angle on the entity's datatable.
--@param number key Goes from 0 to 31.
--@param Angle vec The angle to write on the entity's datatable.
function ents_methods:setDTAngle(key, ang)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		eunwrap(self):SetDTAngle(key, aunwrap(ang))
	end
end

--- Sets the specified string on the entity's datatable.
--@param number key Goes from 0 to 3.
--@param string str The string to write on the entity's datatable, can't be more than 512 characters per string.
function ents_methods:setDTString(key, str)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		eunwrap(self):SetDTString(key, str)
	end
end

--- Sets the specified bool on the entity's datatable.
--@param number key Goes from 0 to 31.
--@param boolean bool The boolean to write on the entity's metatable.
function ents_methods:setDTBool(key, bool)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		eunwrap(self):SetDTBool(key, bool)
	end
end

--- Sets the specified entity on the entity's datatable.
--@param number key Goes from 0 to 31.
--@param Entity ent The entity to write on this entity's datatable.
function ents_methods:setDTEntity(key, ent)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		eunwrap(self):SetDTEntity(key, eunwrap(ent))
	end
end

--- Get an int stored in the datatable of the entity.
--@param number key Goes from 0 to 31. Specifies what key to grab from datatable.
--@return number 32-bit signed integer
function ents_methods:getDTInt(key)
	return eunwrap(self):GetDTInt(key)
end

--- Get a float stored in the datatable of the entity.
--@param number key Goes from 0 to 31. Specifies what key to grab from datatable.
--@return number Requested float.
function ents_methods:getDTFloat(key)
	return eunwrap(self):GetDTFloat(key)
end

--- Get a vector stored in the datatable of the entity.
--@param number key Goes from 0 to 31. Specifies what key to grab from datatable.
--@return Vector Requested vector.
function ents_methods:getDTVector(key)
	return vwrap(eunwrap(self):GetDTVector(key))
end

--- Get an angle stored in the datatable of the entity.
--@param number key Goes from 0 to 31. Specifies what key to grab from datatable.
--@return Angle Requested angle.
function ents_methods:getDTAngle(key)
	return awrap(eunwrap(self):GetDTAngle(key))
end

--- Get a string stored in the datatable of the entity.
--@param number key Goes from 0 to 3. Specifies what key to grab from datatable.
--@return string Requested string.
function ents_methods:getDTString(key)
	return eunwrap(self):GetDTString(key)
end

--- Get a bool stored in the datatable of the entity.
--@param number key Goes from 0 to 31. Specifies what key to grab from datatable.
--@return boolean Requested bool.
function ents_methods:getDTBool(key)
	return eunwrap(self):GetDTBool(key)
end

--- Get an entity stored in the datatable of the entity.
--@param number key Goes from 0 to 31. Specifies what key to grab from datatable.
--@return Entity Requested entity.
function ents_methods:getDTEntity(key)
	return ewrap(eunwrap(self):GetDTEntity(key))
end

--- Marks the entity to call GM:ShouldCollide.
-- @param boolean enable Enable or disable the custom collision check.
function ents_methods:setCustomCollisionCheck(new)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		eunwrap(self):SetCustomCollisionCheck(new)
	end
end

--- Returns players death ragdoll.
-- @return Entity The ragdoll. Unlike normal clientside ragdolls (C_ClientRagdoll), this will be a C_HL2MPRagdoll on the client, and hl2mp_ragdoll on the server.
function player_methods:getRagdollEntity()
	return ewrap(getply(self):GetRagdollEntity())
end

--- Returns whether this entity has the specified spawnflags bits set.
--@param number flag The spawnflag bits to check.
--@return boolean Whether the entity has that spawnflag set or not.
function ents_methods:hasSpawnFlags(val)
	return eunwrap(self):HasSpawnFlags(val)
end

--- Returns the delta movement and angles of a sequence of the entity's model.
--@param number seqid The sequence index. See Entity:lookupSequence.
--@param number startcyc The sequence start cycle. 0 is the start of the animation, 1 is the end.
--@param number endcyc The sequence end cycle. 0 is the start of the animation, 1 is the end. Values like 2, etc are allowed.
--@return boolean Whether the operation was successful.
--@return Vector The delta vector of the animation, how much the model's origin point moved.
--@return Angle The delta angle of the animation.
function ents_methods:getSequenceMovement(seq, startcyc, endcyc)
	local ent = eunwrap(self)

	local success, deltaVec, deltaAng = ent:GetSequenceMovement(seq, startcyc, endcyc)
	return success, vwrap(deltaVec), awrap(deltaAng)
end

--- Returns the frame of the currently played sequence. This will be a number between 0 and 1 as a representation of sequence progress.
--@return The frame of the currently played sequence.
function ents_methods:getCycle()
	return eunwrap(self):GetCycle()
end

--- Adds keys to the move data, as if player pressed them.
-- @shared
-- @param number keys Key(s) to add, check builtin IN_KEY enums.
function cmv_methods:addKey(keys)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:AddKey(keys)
	end
end

--- Sets the pressed buttons on the move data.
-- @shared
-- @param number buttons A number representing which buttons are down, check builtin IN_KEY enums.
function cmv_methods:setButtons(buttons)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetButtons(buttons)
	end
end

--- Removes keys from the move data, as if player didn't press them.
-- @shared
-- @param number keys Key(s) to remove, check builtin IN_KEY enums.
function cmv_methods:removeKey(keys)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		local newbuttons = bit.band(cmd:GetButtons(), bit.bnot(keys))
		cmd:SetButtons(newbuttons)
	end
end

--- Gets which buttons are down
-- @return An integer representing which buttons are down, see IN_KEY enums.
function cmv_methods:getButtons()
	local cmd = ounwrap(self)
	return cmd:GetButtons()
end

--- Sets players forward speed.
-- @param number speed Forward speed
function cmv_methods:setForwardSpeed(speed)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetForwardSpeed(speed)
	end
end

--- Sets players side speed.
-- @param number speed Side speed
function cmv_methods:setSideSpeed(speed)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetSideSpeed(speed)
	end
end

-- Returns the angle the player is moving at.
-- @return angle The move direction.
function cmv_methods:getMoveAngles()
	local cmd = ounwrap(self)
	return awrap(cmd:GetMoveAngles())
end

--- Gets the player's position.
-- @return Vector The player's position.
function cmv_methods:getOrigin()
	local cmd = ounwrap(self)
	return vwrap(cmd:GetOrigin())
end

--- Sets the player's velocity.
-- @param Vector vel The velocity to set.
function cmv_methods:setVelocity(new)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetVelocity(vunwrap(new))
	end
end

--- Sets players up speed.
-- @param number speed Up speed
function cmv_methods:setUpSpeed(speed)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetUpSpeed(speed)
	end
end

--- Removes all keys from the command.
function cuc_methods:clearButtons()
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:ClearButtons()
	end
end

--- Clears the movement from the command.
function cuc_methods:clearMovement()
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:ClearMovement()
	end
end

--- Sets speed the client wishes to move forward with, negative if the clients wants to move backwards.
-- @param number speed The new speed to request. The client will not be able to move faster than their set walk/sprint speed.
function cuc_methods:setForwardSpeed(speed)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetForwardSpeed(speed)
	end
end

--- Sets speed the client wishes to move forward with, negative if the clients wants to move backwards.
-- @param number speed The new speed to request. The client will not be able to move faster than their set walk/sprint speed.
function cuc_methods:setSideSpeed(speed)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetSideSpeed(speed)
	end
end

--- Sets speed the client wishes to move upwards with, negative to move down.
-- @param number speed The new speed to request.
function cuc_methods:setUpSpeed(speed)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetUpSpeed(speed)
	end
end

--- Sets the buttons as a bitflag.
-- @shared
-- @param number buttons Bitflag representing which buttons are "down", check builtin IN_KEY enums.
function cuc_methods:setButtons(buttons)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetButtons(buttons)
	end
end

--- Removes a key bit from the current key bitflag.
-- @shared
-- @param number key Bitflag to be removed from the key bitflag, check builtin IN_KEY enums.
function cuc_methods:removeKey(key)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:RemoveKey(key)
	end
end

--- Returns true if the specified button(s) is pressed.
-- @param number key Bitflag representing which button to check, see builtin IN_KEY enums.
-- @return boolean Is key down or not
function cuc_methods:keyDown(key)
	local cmd = ounwrap(self)
	return ounwrap(cmd:KeyDown(key))
end

--- Sets speed the client wishes to move forward with, negative if the clients wants to move backwards.
-- @param number speed The new speed to request. The client will not be able to move faster than their set walk/sprint speed.
function cuc_methods:setForwardMove(speed)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetForwardMove(speed)
	end
end

--- Sets speed the client wishes to move sidewards with, positive to move right, negative to move left.
-- @param number speed The new speed to request.
function cuc_methods:setSideMove(speed)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetSideMove(speed)
	end
end

--- Sets the direction the client wants to move in.
-- @param Angle ang New view angles.
function cuc_methods:setViewAngles(ang)
	local cmd = ounwrap(self)
	ang = aunwrap(ang)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetViewAngles(ang)
	end
end

--- Sets the delta of the angular horizontal mouse movement of the player.
-- @param number newspeed Angular horizontal move delta.
function cuc_methods:setMouseX(new)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetMouseX(new)
	end
end

--- Sets the delta of the angular horizontal mouse movement of the player.
-- @param number newspeed Angular horizontal move delta.
function cuc_methods:setMouseY(new)
	local cmd = ounwrap(self)
	if superOrAdmin(instance) or instance.player==SF.Superuser then
		cmd:SetMouseY(new)
	end
end

--- Returns whether the key is down or not
-- @param number key The key to test, see IN_KEY enums.
-- @return boolean Is the key down or not
function cmv_methods:keyDown(key)
	local cmd = ounwrap(self)
	return ounwrap(cmd:KeyDown(key))
end


--- Simulates a push on the client's screen
-- @shared
-- @param Angle punchangle The angle in which to push the player's screen
function player_methods:viewPunch(ang)
	local ang = aunwrap(ang)
	
	checkpermission(instance, getply(self), "entities.setRenderProperty")
	getply(self):ViewPunch(ang)
end

--- Strips a player of their weapons
-- @server
function player_methods:stripWeapons()
	if superOrAdmin(instance) then
		getply(self):StripWeapons()
	end
end

--- Gives ammo to a player
-- @server
-- @param number amount The amount of ammo to give
-- @param string|number idorname The string ammo name or number id of the ammo
function player_methods:giveAmmo(amount, ammotype, hidePopup)
	if superOrAdmin(instance) then
		getply(self):GiveAmmo(amount, ammotype, hidePopup)
	end
end

--- Sets the amount of the specified ammo for the player
-- @server
-- @param number amount The amount to set the ammo to
-- @param string|number idorname The string ammo name or number id of the ammo
function player_methods:setAmmo(amount, ammotype)
	if superOrAdmin(instance) then
		getply(self):SetAmmo(amount, ammotype)
	end
end

--- Sets the player's normal walking speed. Not sprinting, not slow walking. Default is 200.
-- @shared 
-- @param number newspeed The new walk speed when sv_friction is below 10. Higher sv_friction values will result in slower speed. Has to be 7 or above or the player won't be able to move.
function player_methods:setWalkSpeed(mvsp)
	if superOrAdmin(instance) then
		getply(self):SetWalkSpeed(mvsp)
	end
end

--- Sets the player's sprint speed. Default is 400.
-- @shared 
-- @param number newspeed The new sprint speed when sv_friction is below 10. Higher sv_friction values will result in slower speed. Has to be 7 or above or the player won't be able to move.
function player_methods:setRunSpeed(mvsp)
	if superOrAdmin(instance) then
		getply(self):SetRunSpeed(mvsp)
	end
end

--- Sets the player's slow walking speed, which is activated via +walk keybind.
-- @shared 
-- @param number newspeed The new slow walking speed.
function player_methods:setSlowWalkSpeed(mvsp)
	if superOrAdmin(instance) then
		getply(self):SetSlowWalkSpeed(mvsp)
	end
end

--- Sets the crouched walk speed multiplier. Doesn't work for values above 1.
-- @shared 
-- @param number newspeed The walk speed multiplier that crouch speed should be.
function player_methods:setCrouchedWalkSpeed(mvsp)
	if superOrAdmin(instance) then
		getply(self):SetCrouchedWalkSpeed(mvsp)
	end
end

--- Gets whether a key was just pressed this tick.
-- @shared
-- @param number key Key that was pressed. Check builtin IN_KEY enums.
function player_methods:keyPressed(key)
	return getply(self):KeyPressed(key)
end

--- Return activity id out of sequence id.
-- @shared
-- @param number|string seqid The sequence ID
-- @return number activity The activity ID.
function ents_methods:getSequenceActivity(act)
	if isstring(act) then act = eunwrap(self):LookupSequence(act) end
	return eunwrap(self):GetSequenceActivity(act)
end

--- Set an entity's model.
-- @shared
-- @param string mdlname The path to the model.
function ents_methods:setModel(model)
	if eunwrap(self):GetOwner() == instance.player or instance.player==SF.Superuser or instance.player:IsAdmin() then
		eunwrap(self):SetModel(model)
	end
end

--- Gets whether a key was down one tick ago.
-- @shared
-- @param number key Key to check. IN_KEY table values
-- @return boolean Whether the key is down
function player_methods:keyDownLast(key)
	checkluatype(key, TYPE_NUMBER)

	return getply(self):KeyDownLast(key)
end

--- Sets the jump power, eg. the velocity the player will applied to when he jumps.
-- @param number jumpPower The new jump velocity.
function player_methods:setJumpPower(new)
	if superOrAdmin(instance) then
		getply(self):SetJumpPower(new)
	end
end

--- Sets local position relative to the parented position. This is for use with Entity:SetParent to offset position.
-- @param Vector newpos The local position.
function ents_methods:setLocalPos(new)
	if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
		eunwrap(self):SetLocalPos(vunwrap(new))
	end
end

--- Sets angles relative to angles of Entity:getParent
-- @param Angle newang The local angle.
function ents_methods:setLocalAngles(new)
	if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
		eunwrap(self):SetLocalAngles(aunwrap(new))
	end
end

--- Returns entity's position relative to it's parent.
-- @return Vector Relative position.
function ents_methods:getLocalPos()
	return eunwrap(self):GetLocalPos()
end

--- Returns the rotation of the entity relative to its parent entity.
-- @return Relative angle.
function ents_methods:getLocalAngles()
	return eunwrap(self):GetLocalAngles()
end

--- No restrictions setParentEx
-- @param Entity parent New parent.
function ents_methods:setParentEx(prnt)
	if superOrAdmin(instance) then
		eunwrap(self):SetParent(prnt and eunwrap(prnt) or nil)
	end
end

--- Gets the player's hands entity.
-- @return Entity The hands entity if player has one.
function player_methods:getHands()
	return ewrap(eunwrap(self):GetHands())
end

--- Sets the render angles of a player. Value set by this function is reset to player's angles (Entity:GetAngles) right after GM:UpdateAnimation.
-- @param Angle newAng The new render angles to set
function player_methods:setRenderAngles(ang)
	if superOrAdmin(instance) then
		eunwrap(self):SetRenderAngles(aunwrap(ang))
	end
end

--- Returns the player's specified ViewModel.
-- Each player has 3 view models by default, but only the first one is used.
-- @param number vmnum optional index of the view model to return, can range from 0 to 2
-- @return Entity The view model entity.
function player_methods:getViewModelEX(num)
	return ewrap(eunwrap(self):GetViewModel(num))
end

--- Plays a sequence directly from a sequence number, similar to Player:playGesture. This function has the advantage to play sequences that haven't been bound to an existing ACT enum.
-- @param number slot Gesture slot using GESTURE_SLOT enum
-- @param number sequenceID The sequence ID to play, can be retrieved with Entity:lookupSequence.
-- @param number cycle The cycle to start the animation at, ranges from 0 to 1.
-- @param boolean autokill If the animation should not loop. true = stops the animation, false = the animation keeps playing.
function player_methods:addVCDSequenceToGestureSlot(slot, sid, cyc, autokill)
	local ent = eunwrap(self)
	autokill = autokill or true
	if isstring(sid) then sid = ent:LookupSequence(sid) end
	if ent:GetOwner() == instance.player or superOrAdmin(instance) then
		ent:AddVCDSequenceToGestureSlot(slot, sid, cyc, autokill)
	end
end

--- Retrieves a networked integer (whole number) value that was previously set by Entity:setNWInt.
-- @param string key The key that is associated with the value.
-- @param number fallback The value to return if we failed to retrieve the value (If it isn't set).
function ents_methods:getNWInt(key, val)
	return eunwrap(self):GetNW2Int(instancekey..key, val)
end

--- Retrieves a networked string value at specified index on the entity that is set by Entity:setNWString.
-- @param string key The key that is associated with the value
-- @param string fallback The value to return if we failed to retrieve the value. (If it isn't set)
function ents_methods:getNWString(key, val)
	return eunwrap(self):GetNW2String(instancekey..key, val)
end

--- Retrieves a networked vector value at specified index on the entity that is set by Entity:setNWVector.
-- @param string key The key that is associated with the value
-- @param Vector fallback The value to return if we failed to retrieve the value.
function ents_methods:getNWVector(key, val)
	return eunwrap(self):GetNW2Vector(instancekey..key, vunwrap(val))
end

--- Retrieves a networked float value at specified index on the entity that is set by Entity:setNWFloat.
-- @param string key The key that is associated with the value
-- @param number fallback The value to return if we failed to retrieve the value.
function ents_methods:getNWFloat(key, val)
	return eunwrap(self):GetNW2Float(instancekey..key, val)
end

--- Retrieves a networked angle value at specified index on the entity that is set by Entity:getNWAngle.
-- @param string key The key that is associated with the value
-- @param Angle fallback The value to return if we failed to retrieve the value.
function ents_methods:getNWAngle(key, val)
	return eunwrap(self):GetNW2Angle(instancekey..key, aunwrap(val))
end

--- Retrieves a networked boolean value at specified index on the entity that is set by Entity:setNWBool.
-- @param string key The key that is associated with the value
-- @param boolean fallback The value to return if we failed to retrieve the value.
function ents_methods:getNWBool(key, val)
	return eunwrap(self):GetNW2Bool(instancekey..key, val)
end

--- Retrieves a networked entity value at specified index on the entity that is set by Entity:setNWEntity.
-- @param string key The key that is associated with the value
-- @param Entity fallback The value to return if we failed to retrieve the value. (If it isn't set)
function ents_methods:getNWEntity(key, val)
	return ewrap(eunwrap(self):GetNW2Entity(instancekey..key, val))
end

---Makes the physics object of the entity a sphere.
---This function will automatically destroy any previous physics objects.
-- @server
-- @param number solidType The solid type of the physics object to create, see Enums/SOLID. Should be SOLID_VPHYSICS (6) in most cases.
-- @return boolean Returns true on success, false otherwise. This will fail if the entity's current model has no associated physics mesh.
function ents_methods:physicsInitStatic(val)
	if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
		return eunwrap(self):PhysicsInitStatic(val)
	end
end

--- Returns the duration of given layer.
-- @param number layerID The layer ID.
-- @return The duration of the layer
function ents_methods:getLayerDuration(lid)
	return eunwrap(self):GetLayerDuration(lid)
end

--- Sets the duration of given layer.
-- @param number layerID The layer ID.
-- @param number duration The new duration of the layer in seconds.
function ents_methods:setLayerDuration(lid, dur)
	if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
		eunwrap(self):SetLayerDuration(lid, dur)
	end
end

--- Sets layer blend in amount.
-- @param number layerID The layer ID.
-- @param number blendIn How long it takes for the anim to blend in.
function ents_methods:setLayerBlendIn(lid, blend)
	if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
		eunwrap(self):SetLayerBlendIn(lid, blend)
	end
end

--- Returns the weight of given layer.
-- @param number layerID The layer ID.
-- @return number The duration of the layer
function ents_methods:getLayerWeight(lid)
	return eunwrap(self):GetLayerWeight(lid)
end

--- Sets the layer weight. This influences how strongly the animation should be overriding the normal animations of the entity.
-- @param number layerID The layer ID.
-- @param number newWeight The new layer weight.
function ents_methods:setLayerWeight(lid, weight)
	if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
		eunwrap(self):SetLayerWeight(lid, weight)
	end
end

--- Sets layer blend out amount.
-- @param number layerID The layer ID.
-- @param number blendOut How long it takes for the anim to blend out.
function ents_methods:setLayerBlendOut(lid, blend)
	if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
		eunwrap(self):SetLayerBlendOut(lid, blend)
	end
end

--- Returns the layer playback rate. See also Entity:getLayerDuration.
-- @param number layerID The layer ID.
-- @return number The current playback rate.
function ents_methods:getLayerPlaybackRate(lid)
	return eunwrap(self):GetLayerPlaybackRate(lid)
end

--- Sets the layer playback rate. See also Entity:setLayerDuration.
-- @param number layerID The layer ID.
-- @param number rate The new playback rate.
function ents_methods:setLayerPlaybackRate(lid, rate)
	if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
		eunwrap(self):SetLayerPlaybackRate(lid, rate)
	end
end

--- Gets the cycle of given layer.
-- @param number layerID The layer ID.
-- @return number The animation cycle/frame for given layer.
function ents_methods:getLayerCycle(lid)
	return eunwrap(self):GetLayerCycle(lid)
end

--- Sets the animation cycle/frame of given layer.
-- @param number layerID The layer ID.
-- @param number cycle The new animation cycle/frame for given layer.
function ents_methods:setLayerCycle(lid, cyc)
	if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
		eunwrap(self):SetLayerCycle(lid, cyc)
	end
end

--- Gets the sequence of given layer.
-- @param number layerID The layer ID.
-- @return number The sequenceID of the layer.
function ents_methods:getLayerSequence(lid)
	return eunwrap(self):GetLayerSequence(lid)
end

--- Sets the sequence of given layer.
-- @param number layerID The layer ID.
-- @param number seqid The sequenceID to set. See Entity:lookupSequence.
function ents_methods:setLayerSequence(lid, seq)
	if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
		eunwrap(self):SetLayerSequence(lid, seq)
	end
end

--- Returns whether the given layer ID is valid and exists on this entity.
-- @param numner layerID The Layer ID.
-- @return boolean Whether the given layer ID is valid and exists on this entity.
function ents_methods:isValidLayer(lid)
	return eunwrap(self):IsValidLayer(lid)
end

--- Animates an animatable prop
-- @shared
-- @param number|string animation Animation number or string name.
-- @param number? frame Optional int (Default 0) The starting frame number. Does nothing if nil
-- @param number? rate Optional float (Default 1) Frame speed. Does nothing if nil
function ents_methods:setAnimation(animation, frame, rate)
	local ent = eunwrap(self)
	if !superOrAdmin(instance) or ent:GetClass() != "starfall_animatableprop" then return end

	if isstring(animation) then
		animation = ent:LookupSequence(animation)
	elseif not isnumber(animation) then
		SF.ThrowTypeError("number or string", SF.GetType(animation), 2)
	end
	
	if animation~=nil then
		ent:ResetSequence(animation)
	end
	if frame ~= nil then
		checkluatype(frame, TYPE_NUMBER)
		ent:SetCycle(frame)
	end
	if rate ~= nil then
		checkluatype(rate, TYPE_NUMBER)
		ent:SetPlaybackRate(rate)
	end
end

if SERVER then

	--- Lets you change the number of bullets in the given weapons primary clip.
	--@server
	--@param number ammo The amount of bullets the clip should contain.
	function weapon_methods:setClip1(val)
		local wep = wunwrap(self)
		if superOrAdmin(instance) then
			wep:SetClip1(val)
		end
	end
	
	--- Lets you change the number of bullets in the given weapons secondary clip.
	--@server
	--@param number ammo The amount of bullets the clip should contain.
	function weapon_methods:setClip2(val)
		local wep = wunwrap(self)
		if superOrAdmin(instance) then
			wep:SetClip2(val)
		end
	end
	
	--- Fires bullets from an entity.
	--@server
	--@param table bulletData Bullet data table, check https://wiki.facepunch.com/gmod/Structures/Bullet
	function ents_methods:fireBullets(bulletData)
		if superOrAdmin(instance) then
			local ent = eunwrap(self)

			bulletData = instance.Unsanitize(bulletData)
			local sfCallback = bulletData.Callback
			if sfCallback then
				bulletData.Callback = function(shooter, data)
					instance:runFunction(sfCallback, instance.Types.Player.Wrap(shooter), instance.Sanitize(data))
				end
			end
			ent:FireBullets(bulletData)
		end
	end

	--- Scales the model of the entity, if the entity is a Player or an NPC the hitboxes will be scaled as well.
	--@server
	--@param number newScale A float to scale the model by. 0 will not draw anything. A number less than 0 will draw the model inverted.
	function ents_methods:setModelScale(scale)
		if superOrAdmin(instance) then
			local ent = eunwrap(self)
			ent:SetModelScale(scale)
			ent:Activate()
		end
	end
	
	--- Plays a scripted sequence on an NPC. Allows for root motion.
	-- @server
	-- @param string entryanim? If set, specifies the sequence or activity which plays before the Action Animation.
	-- @param string actionanim Sequence or activity which is the "main" animation.
	-- @param boolean loopactionanim? Whether to loop the action animation. The animation used must be one that's actually intended to loop.
	-- @param boolean overrideAI? Overrides the NPC's current state to play the script, regardless of whether they're in combat or otherwise.
	-- @param boolean nointerruptions? Prevents the NPC from being interrupted by damage, etc.
	function npc_methods:playScriptedSequence(entryanim, actionanim, loopaction, overrideai, nointerruptions)
		local flags = 4096
		if overrideai then flags = flags + 64 end
		if nointerruptions then flags = flags + 32 end
		local npc = npcunwrap(self)
		npc:SetName("SF_SSNPC_"..instance.entity:EntIndex()..npc:EntIndex())
		local ss = ents.Create("scripted_sequence")
		ss:SetKeyValue("m_fMoveTo", "0")
		if loopaction then ss:SetKeyValue("m_bLoopActionSequence", "1") end
		ss:SetKeyValue("m_iszEntity", npc:GetName())
		if entryanim then ss:SetKeyValue("m_iszEntry", entryanim) end
		ss:SetKeyValue("m_iszPlay", actionanim)
		ss:SetKeyValue("spawnflags", tostring(flags))
		ss:SetPos(vector_origin)
		ss:Spawn()
		ss:Fire("BeginSequence", "", 0)
	end
	
	--- Returns the weapon the NPC is carrying.
	--@server
	--@return Entity The NPC's current weapon.
	function npc_methods:getActiveWeapon()
		local npc = npcunwrap(self)
		
		return ewrap(npc:GetActiveWeapon())
	end
	
	--- Makes a physics prop into an animatable prop entity.
	-- @server
	--@return Entity animatableProp The prop as an animatable prop.
	function ents_methods:makeAnimatable()
		local ent = eunwrap(self)
		if !superOrAdmin(instance) or ent:GetClass() != "prop_physics" then return end
		
		local prop_animatable = ents.Create( "starfall_animatableprop" )
		prop_animatable:SetModel( ent:GetModel() )
		prop_animatable:SetPos( ent:GetPos() )
		prop_animatable:SetAngles( ent:GetAngles() )
		prop_animatable:SetSequence( ent:GetSequence() )
		prop_animatable:SetCycle( ent:GetCycle() )
		prop_animatable:SetSkin( ent:GetSkin() or 0 )
		
		prop_animatable:Spawn()
		prop_animatable:Activate()
		
		prop_animatable.EntityMods = ent.EntityMods
		
		ent:Remove()
		animatableprops[prop_animatable] = true
		return ewrap(prop_animatable)
	end
	
	--- Sets the mapping name of the entity. Same as the ent_setname console command.
	-- @server
	-- @param string name The name to set for the entity.
	function ents_methods:setName(name)
		local ent = eunwrap(self)
		if ent:GetOwner() == instance.player or superOrAdmin(instance) then
			ent:SetName(name)
		end
	end

	--- Adds a gesture animation to the entity and plays it.
	-- @param number seqId The sequence ID to play as the gesture. See Entity:lookupSequence,
	-- @return number The layer id of the added gesture.
	function ents_methods:addGestureSequence(seq)
		if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
			return eunwrap(self):AddGestureSequence(seq)
		end
	end

	--- Adds a gesture animation to the entity and plays it.
	-- @param number seqIdThe sequence ID to play as the gesture. See Entity:lookupSequence.
	-- @return number The layer id of the added gesture.
	function ents_methods:addLayeredSequence(seq, priority)
		if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
			return eunwrap(self):AddLayeredSequence(seq, priority)
		end
	end
	
	--- Sets a networked integer (whole number) value on the entity. The value can then be accessed with Entity:getNWInt both from client and server.
	-- @param string key The key to associate the value with.
	-- @param number value The value to set.
	-- @server
	function ents_methods:setNWInt(key, val)
		local ent = eunwrap(self)
		if !nwents[ent:EntIndex()] then nwents[ent:EntIndex()] = true end
		if superOrAdmin(instance) or instance.player == SF.Superuser then
			ent:SetNW2Int(instancekey..key, val)
		end
	end
	
	--- Sets a networked string value on the entity. The value can then be accessed with Entity:getNWString both from client and server.
	-- @param string key The key to associate the value with.
	-- @param string value The value to set, up to 199 characters.
	-- @server
	function ents_methods:setNWString(key, val)
		local ent = eunwrap(self)
		if !nwents[ent:EntIndex()] then nwents[ent:EntIndex()] = true end
		if superOrAdmin(instance) then
			ent:SetNW2String(instancekey..key, val)
		end
	end
	
	--- Sets a networked vector value on the entity. The value can then be accessed with Entity:getNWVector both from client and server.
	-- @param string key The key to associate the value with.
	-- @param Vector value The value to set.
	-- @server
	function ents_methods:setNWVector(key, val)
		local ent = eunwrap(self)
		if !nwents[ent:EntIndex()] then nwents[ent:EntIndex()] = true end
		if superOrAdmin(instance) or instance.player == SF.Superuser then
			ent:SetNW2Vector(instancekey..key, vunwrap(val))
		end
	end
	
	--- Sets a networked float (number) value on the entity. The value can then be accessed with Entity:getNWFloat both from client and server.
	-- @param string key The key to associate the value with.
	-- @param number value The value to set.
	-- @server
	function ents_methods:setNWFloat(key, val)
		local ent = eunwrap(self)
		if !nwents[ent:EntIndex()] then nwents[ent:EntIndex()] = true end
		if superOrAdmin(instance) or instance.player == SF.Superuser then
			ent:SetNW2Float(instancekey..key, val)
		end
	end
	
	--- Sets a networked angle value on the entity. The value can then be accessed with Entity:getNWAngle both from client and server.
	-- @param string key The key to associate the value with.
	-- @param Angle value The value to set.
	-- @server
	function ents_methods:setNWAngle(key, val)
		local ent = eunwrap(self)
		if !nwents[ent:EntIndex()] then nwents[ent:EntIndex()] = true end
		if superOrAdmin(instance) or instance.player == SF.Superuser then
			ent:SetNW2Angle(instancekey..key, aunwrap(val))
		end
	end
	
	--- Sets a networked boolean value on the entity. The value can then be accessed with Entity:getNWBool both from client and server.
	-- @param string key The key to associate the value with.
	-- @param boolean value The value to set.
	-- @server
	function ents_methods:setNWBool(key, val)
		local ent = eunwrap(self)
		if !nwents[ent:EntIndex()] then nwents[ent:EntIndex()] = true end
		if superOrAdmin(instance) or instance.player == SF.Superuser then
			ent:SetNW2Bool(instancekey..key, val)
		end
	end
	
	--- Sets a networked entity value on the entity. The value can then be accessed with Entity:getNWEntity both from client and server.
	-- @param string key The key to associate the value with.
	-- @param Entity value The value to set.
	-- @server
	function ents_methods:setNWEntity(key, val)
		local ent = eunwrap(self)
		if !nwents[ent:EntIndex()] then nwents[ent:EntIndex()] = true end
		if superOrAdmin(instance) or instance.player == SF.Superuser then
			ent:SetNW2Entity(instancekey..key, eunwrap(val))
		end
	end
	
	--- Freeze the player. Frozen players cannot move, look around, or attack. Key bindings are still called.
	-- @server
	-- @param boolean frozen Whether the player should be frozen.
	function player_methods:freeze(frozen)
		if superOrAdmin(instance) then
			getply(self):Freeze(frozen)
			if frozen then table.insert(FrozenPlayers, getply(self)) end
		end
	end
	
	--- Sets the entity's move type.
	-- @server
	-- @param number movetype The new movetype, see https://wiki.facepunch.com/gmod/Enums/MOVETYPE
	function ents_methods:setMoveType(movetype)
		if superOrAdmin(instance) then
			eunwrap(self):SetMoveType(movetype)
		end
	end
	
	--- Sets the entity's collision group. No restrictions, admin only.
	-- @param number group The COLLISION_GROUP value to set it to
	function ents_methods:setCollisionGroupEX(group)
		if !superOrAdmin(instance) then SF.Throw("You are not an admin!", 2) end
		checkluatype(group, TYPE_NUMBER)
		if group < 0 or group >= LAST_SHARED_COLLISION_GROUP then SF.Throw("Invalid collision group value", 2) end
		local ent = eunwrap(self)

		ent:SetCollisionGroup(group)
	end
	
	--- Applies damage to an entity
	-- @param number amt Damage amount
	-- @param Entity attacker Damage attacker
	-- @param Entity inflictor Damage inflictor
	-- @param Vector dmgpos Sets the position of where the damage gets applied to.
	-- @param Vector dmgforce Sets the directional force of the damage.
	-- @param number dmgtype Sets the damage type. See https://wiki.facepunch.com/gmod/Enums/DMG
	function ents_methods:applyDamageEX(amt, attacker, inflictor, pos, force, dmgtype)
		ent = ounwrap(self)
		checkpermission(instance, ent, "entities.applyDamage")
		
		local d = DamageInfo()
		d:SetDamage(amt)
		d:SetAttacker(ounwrap(attacker))
		d:SetInflictor(ounwrap(inflictor))
		d:SetDamagePosition(vunwrap(pos) or vector_origin)
		d:SetDamageForce(vunwrap(force) or vector_origin)
		d:SetDamageType(dmgtype or 0)
		
		ent:TakeDamageInfo(d)
	end
	
	--- Gets the Entity's mapping name. This is also the name set be the ent_setname command.
	-- @server
	-- @return string The entity's mapping name if it has one.
	function ents_methods:getName()
		return eunwrap(self):GetName()
	end
	
	--- Creates a trigger
	-- @server
	-- @param string name The name ID of the trigger.
	-- @param string model The model to use for the trigger.
	-- @param Vector pos The position to spawn the trigger at.
	-- @param boolean? dontRemovewithchip If true, won't remove trigger when chip is removed.
	-- @param string? filter Entity class to filter. Default: "player"
	-- @return Entity returns the created trigger entity.
	function trigger_library.create(name, model, pos, undo, filter)
		local colly = ents.Create("starfall_trigger")
		if !undo then
			table.insert(triggers, colly)
		end
		colly:SetNWString("colName", name)
		colly:SetNWString("filter", filter or "player")
		colly:SetModel(model)
		colly:SetPos( vunwrap(pos) )
		colly:PhysicsInit(SOLID_VPHYSICS)
		colly:SetMoveType(MOVETYPE_NONE)
		colly:GetPhysicsObject():Wake()
		colly:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		colly:SetTrigger(true)
		colly:SetSolidFlags(12)
		colly:DrawShadow(false)
		return ewrap(colly)
	end
	
	--- Creates a trigger box with a custom size.
	-- @server
	-- @param Vector origin The position the middle of the trigger will be in.
	-- @param Vector mins The size of the bottom corner.
	-- @param Vector maxs The size of the opposite corner.
	-- @param string|table filter A string or table of strings of entity classes. Trigger will be activated only by these classes. Filters players by default.
	-- @param function onEnter The function to run when a valid entity enters the trigger. 2 args are passed (Entity which entered and the trigger itself)
	-- @param function? onExit The function to run when a valid entity exits the trigger. Same args as onEnter
	-- @return Entity The trigger entity.
	function trigger_library.createBox(origin, mins, maxs, filter, onEnter, onExit)
		local colly = ents.Create("starfall_triggerbox")
		table.insert(triggers, colly)
		colly:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		colly:SetMaterial("models/wireframe")
		colly:SetPos( vunwrap(origin) )
		colly:SetSize(vunwrap(mins), vunwrap(maxs))
		colly:SetMoveType(MOVETYPE_NONE)
		colly:GetPhysicsObject():Wake()
		colly:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		colly:SetTrigger(true)
		colly.filter = {}
		
		if filter then
			if type(filter) == "string" then
				filter = {filter}
			end
			
			for _, cls in pairs(filter) do
				colly.filter[cls] = true
			end
		else
			colly.filter = {player = true}
		end
		
		function colly:StartTouch(ent)
			local cls = ent:GetClass()
			if self.filter[cls] then
				instance:runFunction(onEnter, ewrap(ent), ewrap(self))
			end
		end
		
		if onExit then
			function colly:EndTouch(ent)
				local cls = ent:GetClass()
				if self.filter[cls] then
					instance:runFunction(onExit, ewrap(ent), ewrap(self))
				end
			end
		end
		
		colly:SetSolidFlags(12)
		colly:DrawShadow(false)
		return ewrap(colly)
	end

	--- Creates a trigger sphere with a custom radius.
	-- @server
	-- @param Vector origin The position the middle of the trigger will be in.
	-- @param number radius The radius of the sphere.
	-- @param string|table filter A string or table of strings of entity classes. Trigger will be activated only by these classes. Filters players by default.
	-- @param function onEnter The function to run when a valid entity enters the trigger.
	-- @param function? onExit The function to run when a valid entity exits the trigger.
	-- @return Entity The trigger entity.
	function trigger_library.createSphere(origin, radius, filter, onEnter, onExit)
		local colly = ents.Create("starfall_triggersphere")
		table.insert(triggers, colly)
		colly:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		colly:SetMaterial("models/wireframe")
		colly:SetPos( vunwrap(origin) )
		colly:SetSize(radius)
		colly:SetMoveType(MOVETYPE_NONE)
		colly:GetPhysicsObject():Wake()
		colly:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		colly:SetTrigger(true)
		colly.filter = {}
		
		if filter then
			if type(filter) == "string" then
				filter = {filter}
			end
			
			for _, cls in pairs(filter) do
				colly.filter[cls] = true
			end
		else
			colly.filter = {player = true}
		end
		
		function colly:StartTouch(ent)
			local cls = ent:GetClass()
			if self.filter[cls] then
				instance:runFunction(onEnter, ewrap(ent))
			end
		end
		
		if onExit then
			function colly:EndTouch(ent)
				local cls = ent:GetClass()
				if self.filter[cls] then
					instance:runFunction(onExit, ewrap(ent))
				end
			end
		end
		
		colly:SetSolidFlags(12)
		colly:DrawShadow(false)
		return ewrap(colly)
	end
	
	--- Sets an entity's local velocity
	-- @server
	-- @param Vector velocity Velocity to apply to entity.
	function ents_methods:setLocalVelocity(velocity)
		if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
			eunwrap(self):SetLocalVelocity(vunwrap(velocity))
		end
	end
	
	--- Makes the entity play a .vcd scene.
	-- @server
	-- @param string scene Filepath to scene.
	-- @param number? delay Delay in seconds until the scene starts playing.
	function ents_methods:playScene(scene, delay)
		if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
			eunwrap(self):PlayScene(scene, delay)
		end
	end
	
	--- Returns whether the target/given entity is visible from the this entity. This is meant to be used only with NPCs.
	-- @server
	-- @param Entity target Entity to check for visibility to.
	-- @return boolean Within line of sight?
	function ents_methods:visible(target)
		return eunwrap(self):Visible(eunwrap(target))
	end
	
	--- Returns true if supplied vector is visible from the entity's line of sight.
	-- @server
	-- @param Vector vectocheck The position to check for visibility.
	-- @return boolean Within line of sight?
	function ents_methods:visibleVec(target)
		return eunwrap(self):VisibleVec(vunwrap(target))
	end
	
	--- Forces the player to pickup an existing weapon entity. The player will not pick up the weapon if they already own a weapon of given type, or if the player could not normally have this weapon in their inventory.
	-- @server
	-- @param Weapon newwep The weapon to try to pick up.
	-- @param boolean? ammoOnly If set to true, the player will only attempt to pick up the ammo from the weapon. The weapon will not be picked up even if the player doesn't have a weapon of this type, and the weapon will be removed if the player picks up any ammo from it.
	function player_methods:pickupWeapon(wep, ammoonly)
		if getply(self):GetOwner() == instance.player or superOrAdmin(instance) then
			getply(self):PickupWeapon(eunwrap(wep), ammoonly)
		end
	end
	
	--- Sets a player's armor.
	--@server
	--@param number amount The amount that the player armor is going to be set to.
	function player_methods:setArmor(val)
		if getply(self):GetOwner() == instance.player or superOrAdmin(instance) then
			getply(self):SetArmor(val)
		end
	end
	
	--- Sets the maximum amount of armor the player should have. This affects default built-in armor pickups, but not Player:setArmor.
	--@server
	--@param number max The new max armor value.
	function player_methods:setMaxArmor(val)
		if getply(self):GetOwner() == instance.player or superOrAdmin(instance) then
			getply(self):SetMaxArmor(val)
		end
	end
	
	--- Forces an entity to spawn. Initializes the entity and starts its networking. If called on a player, it will respawn them.
	-- @server
	function ents_methods:spawn()
		if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
			eunwrap(self):Spawn()
		end
	end
	
	--- Initializes a static physics object of the entity using its current model. If successful, the previous physics object is removed.
	--- This is what used by entities such as func_breakable, prop_dynamic, item_suitcharger, prop_thumper and npc_rollermine while it is in its "buried" state in the Half-Life 2 Campaign.
	--- If the entity's current model has no physics mesh associated to it, no physics object will be created.
	-- @server
	-- @param number radius The radius of the sphere.
	-- @param string physMat Physical material from surfaceproperties.txt
	-- @return boolean Returns true on success, false otherwise.
	function ents_methods:physicsInitSphere(radius, physmat)
		if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
			return eunwrap(self):PhysicsInitSphere(radius, physmat)
		end
	end

else

	local ptextures
	
	instance:AddHook("initialize", function()
		ptextures = {}
	end)
	
	instance:AddHook("deinitialize", function()
		if #ptextures > 0 then
			for _, v in ipairs(ptextures) do
				v:Remove()
			end
		end
	end)

	--- Creates a ProjectedTexture
	-- @client
	-- @return ProjectedTexture The PT.
	function projectedtexture_library.create()
		local pt = ProjectedTexture()
		table.insert(ptextures, pt)
		return instance.WrapObject(pt)
	end
	
	--- Move the Projected Texture to the specified position.
	-- @client
	-- @param Vector newpos Position to move PT to.
	function pt_methods:setPos(pos)
		ounwrap(self):SetPos(vunwrap(pos))
	end
	
	--- Sets the angles (direction) of the projected texture.
	-- @client
	-- @param Angle newang Angle.
	function pt_methods:setAngles(ang)
		ounwrap(self):SetAngles(aunwrap(ang))
	end
	
	--- Sets the distance at which the projected texture ends.
	-- @client
	-- @param number newfarz New distance.
	function pt_methods:setFarZ(new)
		ounwrap(self):SetFarZ(new)
	end
	
	--- Sets the distance at which the projected texture starts.
	-- @client
	-- @param number newfarz New distance. Setting this to 0 will disable the projected texture completely! This may be useful if you want to disable a projected texture without actually removing it.
	function pt_methods:setNearZ(new)
		ounwrap(self):SetNearZ(new)
	end
	
	--- Sets the FOV of the PT.
	-- @client
	-- @param number newfov Must be higher than 0 and lower than 180.
	function pt_methods:setFOV(new)
		ounwrap(self):SetFOV(new)
	end
	
	--- Enable or disable shadows cast from the projected texture.
	-- @client
	-- @param boolean newstate New state.
	function pt_methods:setEnableShadows(new)
		ounwrap(self):SetEnableShadows(new)
	end

	--- Sets the brightness of the PT.
	-- @client
	-- @param number newbrightness The brightness to give the projected texture.
	function pt_methods:setBrightness(new)
		ounwrap(self):SetBrightness(new)
	end
	
	--- Sets the color of the projected texture.
	-- @client
	-- @param Color newcolor New color.
	function pt_methods:setColor(new)
		ounwrap(self):SetColor(cunwrap(new))
	end
	
	--- Sets the shadow "filter size" of the projected texture. 0 is fully pixelated, higher values will blur the shadow more. The initial value is the value of r_projectedtexture_filter ConVar.
	-- @client
	-- @param number newfilter New filter size.
	function pt_methods:setShadowFilter(new)
		ounwrap(self):SetShadowFilter(new)
	end
	
	--- Updates the Projected Texture and applies all previously set parameters. Required after most PT methods are used.
	-- @client
	function pt_methods:update()
		ounwrap(self):Update()
	end
	
	--- Sets the texture to be projected.
	-- @client
	-- @param string newtexture The name of the texture.
	function pt_methods:setTexture(new)
		ounwrap(self):SetTexture(new)
	end
	
	--- Changes the current projected texture between orthographic and perspective projection.
	-- @client
	-- @param boolean enable When false, all other arguments are ignored and the texture is reset to perspective projection.
	-- @param number left The amount of units left from the projected texture's origin to project.
	-- @param number top The amount of units upwards from the projected texture's origin to project.
	-- @param number right The amount of units right from the projected texture's origin to project.
	-- @param number bottom The amount of units downwards from the projected texture's origin to project.
	function pt_methods:setOrthographic(enable, left, top, right, bottom)
		ounwrap(self):SetOrthographic(enable, left, top, right, bottom)
	end
	
	--- Sets the target entity for this projected texture, meaning it will only be lighting the given entity and the world.
	-- @client
	-- @param Entity newtarget Sets the target entity for this projected texture, meaning it will only be lighting the given entity and the world.
	function pt_methods:setTargetEntity(new)
		ounwrap(self):SetTargetEntity(eunwrap(new))
	end
	
	--- For animated textures, this will choose which frame in the animation will be projected.
	-- @client
	-- @param number newframe The frame index to use.
	function pt_methods:setTextureFrame(new)
		ounwrap(self):SetTextureFrame(new)
	end
	
	--- Removes the projected texture. After calling this, ProjectedTexture:isValid will return false, and any hooks with the projected texture as the identifier will be automatically deleted.
	-- @client
	function pt_methods:remove()
		ounwrap(self):Remove()
	end
	
	--- Returns true if the projected texture is valid (i.e. has not been removed), false otherwise. Instead of calling this directly it's a good idea to call isValid in case the variable is nil.
	-- @client
	-- @return boolean Is the PT valid?
	function pt_methods:isValid()
		return ounwrap(self):IsValid()
	end
	
	--- Forces the entity to reconfigure its bones. You might need to call this after changing your model's scales or when manually drawing the entity multiple times at different positions.
	-- @client
	function ents_methods:setupBones()
		if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
			eunwrap(self):SetupBones()
		end
	end
	
	--- Removes a clientside entity.
	-- @client
	function ents_methods:removeClient()
		if eunwrap(self):GetOwner() == instance.player or superOrAdmin(instance) then
			eunwrap(self):Remove()
		end
	end

	--- Sets up clientside anim event handling.
	-- @client
	-- @param function callback The callback function to run when an anim event happens. Has 4 args (pos, ang, event number, name string).
	-- @param boolean suppress Suppress the event?
	function ents_methods:setupAnimEventHandler(callback, suppress)
		local eu = eunwrap(self)
		suppress = suppress or false

		function eu:FireAnimationEvent(pos, ang, evnum, str)
			instance:runFunction(callback, pos, ang, evnum, str)
			return suppress
		end
	end
	
end

end