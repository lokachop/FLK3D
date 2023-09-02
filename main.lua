function love.load()
	_LKPXDEBUG = false
	love.filesystem.load("/flk3d/flk3d.lua")()
	CurTime = 0


	UnivTest = FLK3D.NewUniverse("test1")
	local rw, rh = 256, 256
	RTTest = FLK3D.NewRenderTarget("test2", rw, rh)

	FLK3D.BuildProjectionMatrix(rw / rh, 0.1, 1000)
	FLK3D.SetCamPos(Vector(0, 0, -4))


	FLK3D.PushUniverse(UnivTest)
		FLK3D.AddObjectToUniv("loka1", "lokachop_sqr")
		FLK3D.SetObjectMat("loka1", "loka_sheet")

		FLK3D.AddObjectToUniv("cube1", "cube")
		FLK3D.SetObjectPos("cube1", Vector(-2, 0, 0))
		FLK3D.SetObjectMat("cube1", "none")
		FLK3D.SetObjectFlag("cube1", "SHADING", true)
		FLK3D.SetObjectFlag("cube1", "SHADING_SMOOTH", true)

		FLK3D.AddObjectToUniv("train1", "train")
		FLK3D.SetObjectMat("train1", "train_sheet")
		FLK3D.SetObjectPos("train1", Vector(4, 0, 0))

		FLK3D.AddObjectToUniv("track1", "traintrack_hq")
		FLK3D.SetObjectMat("track1", "traintrack_sheet")
		FLK3D.SetObjectPos("track1", Vector(4, -2, 0))

		--[[
		for i = 1, 16 do
			FLK3D.AddObjectToUniv("train" .. i, "train")
		end
		]]--
	FLK3D.PopUniverse()
end

function love.update(dt)
	CurTime = CurTime + dt
	FLK3D.NoclipCam(dt)

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