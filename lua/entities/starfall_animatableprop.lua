
AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.AutomaticFrameAdvance = true

if ( SERVER ) then

	function ENT:Initialize()

		-- This is a silly way to check if the model has a physics mesh or not
		self:PhysicsInit( SOLID_VPHYSICS )

		-- We got no physics? Do some fake shit
		if ( !IsValid( self:GetPhysicsObject() ) ) then
			local mins, maxs = self:OBBMins(), self:OBBMaxs()
			self:SetCollisionBounds( mins, maxs )
			self:SetSolid( SOLID_BBOX )
		end

		self:PhysicsDestroy()
		self:SetMoveType( MOVETYPE_NONE )

	end

end

function ENT:Think()

	self:NextThink( CurTime() )
	return true

end

if ( SERVER ) then return end

function ENT:Draw()

	self:DrawModel()

end

function ENT:DrawTranslucent()

	self:Draw()

end
