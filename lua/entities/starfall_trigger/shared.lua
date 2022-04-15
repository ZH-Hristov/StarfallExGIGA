AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName = "Starfall Trigger"


if(CLIENT) then

	function ENT:Draw()
		self:DrawModel()
	end

end


if(SERVER) then

	function ENT:OnDuplicated(shittytable)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetTrigger(true)
		self:SetSolidFlags( 12 )
		self:DrawShadow(false)
		duplicator.ApplyEntityModifiers( self:GetOwner(), self )
	end
	
	function ENT:PreEntityCopy()
		local modData = self:GetNWVarTable()
		duplicator.StoreEntityModifier( self, "STARFALL_SAVETRIGGERS", modData )
	end

	function ENT:StartTouch(Ent)
		if Ent:GetClass() == self:GetNWString("filter", "player") then
			hook.Run("OnStarfallTrigger", Ent, self:GetNWString("colName", "itdidntwork"), self, 1)
		end
	end
	
	function ENT:EndTouch(Ent)
		if Ent:GetClass() == self:GetNWString("filter", "player") then
			hook.Run("OnStarfallTrigger", Ent, self:GetNWString("colName", "itdidntwork"), self, -1)
		end
	end
	
	function ENT:Touch(Ent)
		if Ent:GetClass() == self:GetNWString("filter", "player") then
			hook.Run("OnStarfallTrigger", Ent, self:GetNWString("colName", "itdidntwork"), self, 0)
		end
	end
	
end