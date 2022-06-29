AddCSLuaFile()

ENT.Type = "anim"

ENT.PrintName = "Starfall Trigger Box"

function ENT:Initialize()
	self:SetMaterial("models/wireframe")
end

if(CLIENT) then

	function ENT:Draw()
		if self:GetMaterial() == "models/wireframe" then
			render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self:OBBMins(), self:OBBMaxs(), color_white, true)
		end
	end

end

if(SERVER) then

	function ENT:SetSize(mins, maxs)
		self:PhysicsInitBox(mins, maxs)
	end
	
end