AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName = "Starfall Trigger Box"

function ENT:Initialize()
	self:SetMaterial("models/wireframe")
end

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Radius")
end

if(CLIENT) then

	function ENT:Draw()
		if self:GetMaterial() == "models/wireframe" then
			render.DrawWireframeSphere(self:GetPos(), self:GetRadius(), 10, 10)
		end
	end

end

if(SERVER) then

	function ENT:SetSize(rad)
		self:SetRadius(rad)
		self:PhysicsInitSphere(rad)
		self:SetCollisionBounds(Vector(-rad, -rad, -rad), Vector(rad, rad, rad))
	end
	
end