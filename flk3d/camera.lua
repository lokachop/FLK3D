FLK3D = FLK3D or {}

FLK3D.CamPos = Vector(0, 0, 0)
FLK3D.CamAng = Angle(0, 0, 0)


FLK3D.FOV = 90


FLK3D.CamMatrix_Rot = LMAT.Matrix()
FLK3D.CamMatrix_Trans = LMAT.Matrix()
FLK3D.CamMatrix_Proj = LMAT.Matrix()


function FLK3D.BuildProjectionMatrix(aspect, near, far)
	FLK3D.CamMatrix_Proj:Identity()
	--[[
	local ind = { -- indices, helper for coding
		 1,  2,  3,  4,
		 5,  6,  7,  8,
		 9, 10, 11, 12,
		13, 14, 15, 16
	}
	]]--

	local scale = 1 / math.tan(math.rad(FLK3D.FOV * 0.5))
	FLK3D.CamMatrix_Proj[ 1] = scale / aspect
	FLK3D.CamMatrix_Proj[ 6] = scale
	FLK3D.CamMatrix_Proj[11] = far / (far - near)
	FLK3D.CamMatrix_Proj[12] = far * near / (far - near)
	FLK3D.CamMatrix_Proj[15] = 1
	FLK3D.CamMatrix_Proj[16] = 0
end


function FLK3D.SetCamPos(pos)
	FLK3D.CamPos = pos or FLK3D.CamPos

	FLK3D.CamMatrix_Trans:SetTranslation(FLK3D.CamPos)
end

function FLK3D.SetCamAng(ang)
	FLK3D.CamAng = ang or FLK3D.CamAng

	FLK3D.CamMatrix_Rot:SetAngles(FLK3D.CamAng)
end

function FLK3D.SetCamPosAng(pos, ang)
	FLK3D.CamPos = pos or FLK3D.CamPos
	FLK3D.CamAng = ang or FLK3D.CamAng

	FLK3D.CamMatrix_Rot:SetAngles(FLK3D.CamAng)
	FLK3D.CamMatrix_Trans:SetTranslation(FLK3D.CamPos)
end

function FLK3D.RotateCam(ang)
	local matRot = Matrix()
	matRot:SetAngles(ang)

	FLK3D.CamMatrix_Rot = matRot * FLK3D.CamMatrix_Rot

	FLK3D.CamAng = FLK3D.CamMatrix_Rot:GetAngles()
end

function FLK3D.NoclipCam(dt)

	local dtMul = dt
	if love.keyboard.isDown("lshift") then
		dtMul = dt * 4
	end

	local fow = FLK3D.CamMatrix_Rot:Forward()
	fow:Mul(dtMul)

	local rig = FLK3D.CamMatrix_Rot:Right()
	rig:Mul(dtMul)

	local up = FLK3D.CamMatrix_Rot:Up()
	up:Mul(dtMul)

	if love.keyboard.isDown("w") then
		FLK3D.SetCamPos(FLK3D.CamPos + fow)
	end

	if love.keyboard.isDown("s") then
		FLK3D.SetCamPos(FLK3D.CamPos - fow)
	end

	if love.keyboard.isDown("a") then
		FLK3D.SetCamPos(FLK3D.CamPos - rig)
	end

	if love.keyboard.isDown("d") then
		FLK3D.SetCamPos(FLK3D.CamPos + rig)
	end

	if love.keyboard.isDown("space") then
		FLK3D.SetCamPos(FLK3D.CamPos + up)
	end

	if love.keyboard.isDown("lctrl") then
		FLK3D.SetCamPos(FLK3D.CamPos - up)
	end


	--print(FLK3D.CamMatrix_Rot:GetAngles(), FLK3D.CamAng)

	if love.keyboard.isDown("left") then
		FLK3D.RotateCam(Angle(0, -128 * dt, 0))
	end

	if love.keyboard.isDown("right") then
		FLK3D.RotateCam(Angle(0, 128 * dt, 0))
	end

	if love.keyboard.isDown("up") then
		FLK3D.RotateCam(Angle(128 * dt, 0, 0))
	end

	if love.keyboard.isDown("down") then
		FLK3D.RotateCam(Angle(-128 * dt, 0, 0))
	end

	if love.keyboard.isDown("q") then
		FLK3D.RotateCam(Angle(0, 0, -128 * dt))
	end

	if love.keyboard.isDown("e") then
		FLK3D.RotateCam(Angle(0, 0, 128 * dt))
	end

	--[[
	if love.keyboard.isDown("left") then
		FLK3D.SetCamAng(Vector(
			FLK3D.CamAng[1],
			(FLK3D.CamAng[2] - 128 * dt) % 360,
			FLK3D.CamAng[3]
		))
	end

	if love.keyboard.isDown("right") then
		FLK3D.SetCamAng(Vector(
			FLK3D.CamAng[1],
			(FLK3D.CamAng[2] + 128 * dt) % 360,
			FLK3D.CamAng[3]
		))
	end

	if love.keyboard.isDown("up") then
		FLK3D.SetCamAng(Vector(
			(FLK3D.CamAng[1] + 128 * dt) % 360,
			FLK3D.CamAng[2],
			FLK3D.CamAng[3]
		))
	end

	if love.keyboard.isDown("down") then
		FLK3D.SetCamAng(Vector(
			(FLK3D.CamAng[1] - 128 * dt) % 360,
			FLK3D.CamAng[2],
			FLK3D.CamAng[3]
		))
	end


	if love.keyboard.isDown("q") then
		FLK3D.SetCamAng(Vector(
			FLK3D.CamAng[1],
			FLK3D.CamAng[2],
			(FLK3D.CamAng[3] - 128 * dt) % 360
		))
	end

	if love.keyboard.isDown("e") then
		FLK3D.SetCamAng(Vector(
			FLK3D.CamAng[1],
			FLK3D.CamAng[2],
			(FLK3D.CamAng[3] + 128 * dt) % 360
		))
	end
	]]--
end

if not love then
	return
end

function FLK3D.ToggleMouseLock(key)
	if key == "tab" then
		FLK3D.CamInputLock = not love.mouse.isGrabbed()
		love.mouse.setGrabbed(FLK3D.CamInputLock)
		love.mouse.setRelativeMode(FLK3D.CamInputLock)
	end
end

FLK3D.CamInputLock = false
FLK3D.CamVel = Vector(0, 0, 0)
function FLK3D.MouseCamThink(dt)
	local vmul = 0.1
	if love.keyboard.isDown("lshift") then
		vmul = 1
	end

	local fow = FLK3D.CamMatrix_Rot:Forward()
	fow:Mul(vmul)

	local rig = FLK3D.CamMatrix_Rot:Right()
	rig:Mul(vmul)

	local up = FLK3D.CamMatrix_Rot:Up()
	up:Mul(vmul)

	if love.keyboard.isDown("w") then
		FLK3D.CamVel = FLK3D.CamVel + fow
	end

	if love.keyboard.isDown("s") then
		FLK3D.CamVel = FLK3D.CamVel - fow
	end

	if love.keyboard.isDown("a") then
		FLK3D.CamVel = FLK3D.CamVel - rig
	end

	if love.keyboard.isDown("d") then
		FLK3D.CamVel = FLK3D.CamVel + rig
	end

	if love.keyboard.isDown("space") then
		FLK3D.CamVel = FLK3D.CamVel + up
	end

	if love.keyboard.isDown("lctrl") then
		FLK3D.CamVel = FLK3D.CamVel - up
	end

	if love.keyboard.isDown("q") then
		FLK3D.RotateCam(Angle(0, 0, -128 * dt))
	end

	if love.keyboard.isDown("e") then
		FLK3D.RotateCam(Angle(0, 0, 128 * dt))
	end

	FLK3D.SetCamPos(FLK3D.CamPos + FLK3D.CamVel * dt)
	FLK3D.CamVel = FLK3D.CamVel / 1.1
end

function FLK3D.MouseCamUpdate(mx, my)
	if not FLK3D.CamInputLock then
		return
	end

	local mxReal = mx / 2
	local myReal = -my / 2

	FLK3D.RotateCam(Angle(myReal, mxReal, 0))
end