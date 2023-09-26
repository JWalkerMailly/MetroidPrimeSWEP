
local ScanPoints  = WGLComponent:New(POWERSUIT, "ScanPoints");
ScanPoints.Icon   = Material("huds/scan/scan");

function ScanPoints:Draw(weapon)

	if (!weapon.RenderScanPoints || IsValid(weapon:GetMorphBall())) then return; end

	-- Don't draw scan icons if the visor does not allow locking on all entities.
	local visor = weapon:GetVisor();
	if (!visor.AllowLockAll) then return; end

	-- Iterate all viable scan points.
	for k,v in pairs(game.MetroidPrimeLogBook.Entities) do

		-- Make sure entity is still valid.
		if (!IsValid(v) || v:GetOwner() == weapon:GetOwner()) then continue; end

		-- Render scan point sprite.
		local pos      = v:WorldSpaceCenter();
		local dir      = (EyePos() - pos);
		local forward  = dir:GetNormalized();
		local distance = dir:Length() / weapon.Helmet.Constants.Visor.LockOnDistance;
		local size     = math.Clamp(60 * distance, 0, 60);
		render.SetMaterial(self.Icon);
		render.DrawSprite(pos + forward * (v:BoundingRadius() + size), size, size, color_white);
	end
end