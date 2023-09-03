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

		FLK3D.AddObjectToUniv("cube1", "train")
		FLK3D.SetObjectPos("cube1", Vector(-2, 0, 0))
		FLK3D.SetObjectScl("cube1", Vector(.1, .1, .1))
		FLK3D.SetObjectMat("cube1", "white")
		FLK3D.SetObjectFlag("cube1", "SHADING", true)
		FLK3D.SetObjectFlag("cube1", "SHADING_SMOOTH", true)

		FLK3D.AddObjectToUniv("cube2", "cube")
		FLK3D.SetObjectPos("cube2", Vector(-4, 0, 0))
		FLK3D.SetObjectMat("cube2", "white")
		FLK3D.SetObjectCol("cube2", {255, 0, 0})

		FLK3D.AddObjectToUniv("cube3", "cube")
		FLK3D.SetObjectPos("cube3", Vector(-5, 0, 0))
		FLK3D.SetObjectMat("cube3", "white")
		FLK3D.SetObjectCol("cube3", {0, 255, 0})


		for i = 1, 3 do
			local indSeries = i .. "s"
			local indTrain = "train" .. indSeries
			local xc = 2 + (i * 3)

			FLK3D.AddObjectToUniv(indTrain, "train")
			FLK3D.SetObjectMat(indTrain, "train_sheet")
			FLK3D.SetObjectPos(indTrain, Vector(xc, 0, 0))

			for j = 1, 4 do
				local indTrack = "track" .. indSeries .. j
				local zc = (j - 1) * 16

				FLK3D.AddObjectToUniv(indTrack, "traintrack")
				FLK3D.SetObjectMat(indTrack, "traintrack_sheet")
				FLK3D.SetObjectPos(indTrack, Vector(xc, -2, zc))
			end
		end

		--[[
		for i = 1, 16 do
			FLK3D.AddObjectToUniv("train" .. i, "train")
		end
		]]--
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
		FLK3D.SetObjectAng("cube1", Angle(CurTime * 64, CurTime * 48, 0))
	FLK3D.PopUniverse()
end

local cx, cy = 128, 128

function love.draw()
	love.graphics.clear(0, 0, 0)
	FLK3D.PushUniverse(UnivTest)
	FLK3D.PushRenderTarget(RTTest)
		FLK3D.Clear(32, 48, 64)

		FLK3D.RenderActiveUniverse()

		FLK3D.RenderRTToScreen()
	FLK3D.PopRenderTarget()
	FLK3D.PopUniverse()
end