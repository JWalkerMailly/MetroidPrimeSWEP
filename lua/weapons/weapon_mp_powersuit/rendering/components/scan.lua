
local ScanPoints   = WGLComponent:New(POWERSUIT, "ScanPoints");
ScanPoints.Icon    = Material("huds/scan/scan");
ScanPoints.IconRed = Material("huds/scan/scanred");
ScanPoints.Color   = Color(255, 255, 255, 255);

function ScanPoints:Draw(weapon)

	if (!weapon.RenderScanPoints || IsValid(weapon:GetMorphBall())) then return; end

	-- Don't draw scan icons if the visor does not allow locking on all entities.
	local visor = weapon:GetVisor();
	if (!visor.AllowLockAll) then return; end

	-- Iterate all viable scan points.
	for k,v in pairs(game.MetroidPrimeLogBook.Entities) do

		-- Make sure entity is still valid.
		if (!IsValid(v) || v:GetOwner() == weapon:GetOwner()) then continue; end

		-- Make sure entity passes filtering.
		if (!visor.LockOnFilter(v)) then continue; end

		-- Render scan point sprite.
		local pos      = v:GetLockOnPosition();
		local dir      = (EyePos() - pos);
		local forward  = dir:GetNormalized();
		local distance = dir:Length() / weapon.Helmet.Constants.Visor.LockOnDistance;
		local size     = math.Clamp(60 * distance, 0, 60);
		local icon     = (v.LogBook && v.LogBook.Important) && self.IconRed || self.Icon;

		if (weapon.LogBookDatabase[v:GetClass()]) then self.Color.a = 100; end
		render.SetMaterial(icon);
		render.DrawSprite(pos + forward * (v:BoundingRadius() + size), size, size, self.Color);
		self.Color.a = 255;
	end
end