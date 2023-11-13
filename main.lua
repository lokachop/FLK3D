function love.load()
	love.filesystem.load("/flk3d/flk3d.lua")()
	CurTime = 0


	UnivTest = FLK3D.NewUniverse("test1")
	local rw, rh = 256, 192
	RTTest = FLK3D.NewRenderTarget("test2", rw, rh)

	FLK3D.BuildProjectionMatrix(rw / rh, 0.1, 1000)
	FLK3D.SetCamPos(Vector(0, 0, -4))


	FLK3D.PushUniverse(UnivTest)

		FLK3D.AddObjectToUniv("loka1", "lokachop_sqr")
		FLK3D.SetObjectMat("loka1", "loka_sheet")
		FLK3D.SetObjectPos("loka1", Vector(-2, 0, 0))

		FLK3D.AddObjectToUniv("cube1", "cube")
		FLK3D.SetObjectPos("cube1", Vector(0, 0, 2.2))
		FLK3D.SetObjectScl("cube1", Vector(1, 1, 1))
		FLK3D.SetObjectMat("cube1", "mandrill")
		FLK3D.SetObjectFlag("cube1", "SHADING", true)
		FLK3D.SetObjectFlag("cube1", "SHADING_SMOOTH", true)
		FLK3D.SetObjectAng("cube1", Angle(0, 60, 180))

		FLK3D.AddObjectToUniv("cube2", "cube")
		FLK3D.SetObjectPos("cube2", Vector(-6, 0, 0))
		FLK3D.SetObjectMat("cube2", "white")
		FLK3D.SetObjectCol("cube2", {255, 0, 0})

		FLK3D.AddObjectToUniv("cube3", "cube")
		FLK3D.SetObjectPos("cube3", Vector(-10, 0, 0))
		FLK3D.SetObjectMat("cube3", "white")
		FLK3D.SetObjectCol("cube3", {0, 255, 0})
		FLK3D.SetObjectFlag("cube3", "SHADING", true)
		FLK3D.SetObjectFlag("cube3", "SHADING_SMOOTH", false)

		for i = 1, 3 do
			local indSeries = i .. "s"
			local indTrain = "train" .. indSeries
			local xc = 2 + (i * 3)

			FLK3D.AddObjectToUniv(indTrain, "train")
			FLK3D.SetObjectMat(indTrain, "train_sheet")
			FLK3D.SetObjectPos(indTrain, Vector(xc, 0, 0))

			for j = 1, 1 do
				local indTrack = "track" .. indSeries .. j
				local zc = (j - 1) * 16

				FLK3D.AddObjectToUniv(indTrack, "traintrack")
				FLK3D.SetObjectMat(indTrack, "traintrack_sheet")
				FLK3D.SetObjectPos(indTrack, Vector(xc, -2, zc))
			end
		end


		-- cool apc!
		local apc_do_shading = false
		local apc_do_shading_smooth = false
		local apc_scale = Vector(3, 3, 3)
		local apc_pos = Vector(0, 0, 16)
		FLK3D.AddObjectToUniv("apcHull", "vehicle_apc_hull")
		FLK3D.SetObjectPos("apcHull", apc_pos)
		FLK3D.SetObjectScl("apcHull", apc_scale)
		FLK3D.SetObjectMat("apcHull", "vehicle_apc_hull")
		FLK3D.SetObjectFlag("apcHull", "SHADING", apc_do_shading)
		FLK3D.SetObjectFlag("apcHull", "SHADING_SMOOTH", apc_do_shading_smooth)

		FLK3D.AddObjectToUniv("apcTurret", "vehicle_apc_turret")
		FLK3D.SetObjectPos("apcTurret", apc_pos + Vector(-0.5, 1, 0) * apc_scale)
		FLK3D.SetObjectScl("apcTurret", apc_scale)
		FLK3D.SetObjectMat("apcTurret", "vehicle_apc_turret")
		FLK3D.SetObjectFlag("apcTurret", "SHADING", apc_do_shading)
		FLK3D.SetObjectFlag("apcTurret", "SHADING_SMOOTH", apc_do_shading_smooth)

		FLK3D.AddObjectToUniv("apcTurretCannon", "vehicle_apc_turret_cannon")
		FLK3D.SetObjectPos("apcTurretCannon", apc_pos + Vector(0.8, 1.25, 0) * apc_scale)
		FLK3D.SetObjectScl("apcTurretCannon", apc_scale)
		FLK3D.SetObjectMat("apcTurretCannon", "vehicle_apc_turret_cannon")
		FLK3D.SetObjectFlag("apcTurretCannon", "SHADING", apc_do_shading)
		FLK3D.SetObjectFlag("apcTurretCannon", "SHADING_SMOOTH", apc_do_shading_smooth)



		-- wheel L
		FLK3D.AddObjectToUniv("apcWheelFL", "vehicle_apc_wheel")
		FLK3D.SetObjectPos("apcWheelFL", apc_pos + Vector(1.5, 0, 0.85) * apc_scale)
		FLK3D.SetObjectScl("apcWheelFL", apc_scale)
		FLK3D.SetObjectMat("apcWheelFL", "vehicle_apc_wheel")
		FLK3D.SetObjectFlag("apcWheelFL", "SHADING", apc_do_shading)
		FLK3D.SetObjectFlag("apcWheelFL", "SHADING_SMOOTH", apc_do_shading_smooth)

		FLK3D.AddObjectToUniv("apcWheelML", "vehicle_apc_wheel")
		FLK3D.SetObjectPos("apcWheelML", apc_pos + Vector(0, 0, 0.85) * apc_scale)
		FLK3D.SetObjectScl("apcWheelML", apc_scale)
		FLK3D.SetObjectMat("apcWheelML", "vehicle_apc_wheel")
		FLK3D.SetObjectFlag("apcWheelML", "SHADING", apc_do_shading)
		FLK3D.SetObjectFlag("apcWheelML", "SHADING_SMOOTH", apc_do_shading_smooth)

		FLK3D.AddObjectToUniv("apcWheelBL", "vehicle_apc_wheel")
		FLK3D.SetObjectPos("apcWheelBL", apc_pos + Vector(-1.5, 0, 0.85) * apc_scale)
		FLK3D.SetObjectScl("apcWheelBL", apc_scale)
		FLK3D.SetObjectMat("apcWheelBL", "vehicle_apc_wheel")
		FLK3D.SetObjectFlag("apcWheelBL", "SHADING", apc_do_shading)
		FLK3D.SetObjectFlag("apcWheelBL", "SHADING_SMOOTH", apc_do_shading_smooth)


		-- wheel R
		FLK3D.AddObjectToUniv("apcWheelFR", "vehicle_apc_wheel")
		FLK3D.SetObjectPos("apcWheelFR", apc_pos + Vector(1.5, 0, -0.85) * apc_scale)
		FLK3D.SetObjectAng("apcWheelFR", Angle(0, 180, 0))
		FLK3D.SetObjectScl("apcWheelFR", apc_scale)
		FLK3D.SetObjectMat("apcWheelFR", "vehicle_apc_wheel")
		FLK3D.SetObjectFlag("apcWheelFR", "SHADING", apc_do_shading)
		FLK3D.SetObjectFlag("apcWheelFR", "SHADING_SMOOTH", apc_do_shading_smooth)

		FLK3D.AddObjectToUniv("apcWheelMR", "vehicle_apc_wheel")
		FLK3D.SetObjectPos("apcWheelMR", apc_pos + Vector(0, 0, -0.85) * apc_scale)
		FLK3D.SetObjectAng("apcWheelMR", Angle(0, 180, 0))
		FLK3D.SetObjectScl("apcWheelMR", apc_scale)
		FLK3D.SetObjectMat("apcWheelMR", "vehicle_apc_wheel")
		FLK3D.SetObjectFlag("apcWheelMR", "SHADING", apc_do_shading)
		FLK3D.SetObjectFlag("apcWheelMR", "SHADING_SMOOTH", apc_do_shading_smooth)

		FLK3D.AddObjectToUniv("apcWheelBR", "vehicle_apc_wheel")
		FLK3D.SetObjectPos("apcWheelBR", apc_pos + Vector(-1.5, 0, -0.85) * apc_scale)
		FLK3D.SetObjectAng("apcWheelBR", Angle(0, 180, 0))
		FLK3D.SetObjectScl("apcWheelBR", apc_scale)
		FLK3D.SetObjectMat("apcWheelBR", "vehicle_apc_wheel")
		FLK3D.SetObjectFlag("apcWheelBR", "SHADING", apc_do_shading)
		FLK3D.SetObjectFlag("apcWheelBR", "SHADING_SMOOTH", apc_do_shading_smooth)
	FLK3D.PopUniverse()
end

function love.keypressed(key)
	FLK3D.ToggleMouseLock(key)
end

function love.mousemoved(mx, my, dx, dy)
	FLK3D.MouseCamUpdate(dx, dy)
end

function love.update(dt)
	CurTime = CurTime + dt
	--FLK3D.NoclipCam(dt)
	FLK3D.MouseCamThink(dt)

	FLK3D.PushUniverse(UnivTest)
		FLK3D.SetObjectAng("cube2", Angle(CurTime * 64, CurTime * 48, 0))
	FLK3D.PopUniverse()
end

local cx, cy = 128, 128

function love.draw()
	love.graphics.clear(0, 0, 0)
	FLK3D.PushUniverse(UnivTest)
	FLK3D.PushRenderTarget(RTTest)
		FLK3D.ClearHalfed(32, 48, 64)

		--FLK3D.WIREFRAME = true
		FLK3D.RenderActiveUniverse()

		FLK3D.RenderRTToScreen()
	FLK3D.PopRenderTarget()
	FLK3D.PopUniverse()
end