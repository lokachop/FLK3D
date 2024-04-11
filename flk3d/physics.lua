FLK3D = FLK3D or {}
--[[
	LK3D physics (External)
	This module translates LK3D physics calls into FPS (https://github.com/0x1ED1CE/FPS) calls
]]--

FLK3D.FPSPath = FLK3D.RelaPath .. "external.fps."
local fps = require(FLK3D.FPSPath  .. "init")

local function initPhysicsWorld(univ)
	if univ["physics_fps"] then
		return
	end

	local world = fps.world.new()
	local solver = fps.solvers.rigid
	world:add_solver(solver)

	univ["physics_fps"] = world

	univ["physics_objects"] = {}
	univ["physics_colliders"] = {}

	return univ["physics_fps"]
end

local function getPhysicsWorld(univ)
	return univ["physics_fps"]
end

local function addBodyToWorld(body)
	local pUniv = getPhysicsWorld(FLK3D.CurrUniv)
	if not pUniv then
		pUniv = initPhysicsWorld(FLK3D.CurrUniv)
	end

	pUniv:add_body(body)
end

local function removeBodyFromWorld(body)
	local pUniv = getPhysicsWorld(FLK3D.CurrUniv)
	if not pUniv then
		pUniv = initPhysicsWorld(FLK3D.CurrUniv)
	end

	pUniv:remove_body(body)
end


local BOX_VERTS = {
	 1,  1, -1,
	 1, -1, -1,
	 1,  1,  1,
	 1, -1,  1,
	-1,  1, -1,
	-1, -1, -1,
	-1,  1,  1,
	-1, -1,  1,
}

local BOX_FACES = {
	5, 3, 1,
	3, 8, 4,
	7, 6, 8,
	2, 8, 6,
	1, 4, 2,
	5, 2, 6,
	5, 7, 3,
	3, 7, 8,
	7, 5, 6,
	2, 4, 8,
	1, 3, 4,
	5, 1, 2,
}



local function getBoxShape(size)
	local recalculatedVertices = {}
	for i = 1, #BOX_VERTS, 3 do
		recalculatedVertices[i] = BOX_VERTS[i] * size[1]
		recalculatedVertices[i + 1] = BOX_VERTS[i + 1] * size[2]
		recalculatedVertices[i + 2] = BOX_VERTS[i + 2] * size[3]
	end


	local recalculatedFaces = {}
	for i = 1, #BOX_FACES, 3 do
		recalculatedFaces[i] = BOX_FACES[i]
		recalculatedFaces[i + 1] = BOX_FACES[i + 1]
		recalculatedFaces[i + 2] = BOX_FACES[i + 2]
	end

	--print("-verts-")
	--PrintTable(recalculatedVertices)

	--print("-faces-")
	--PrintTable(recalculatedFaces)

	return fps.shape.new(recalculatedVertices, BOX_FACES)
end

local function getBoxCollider(size)
	local coll = fps.collider.new()
	coll:set_shape(getBoxShape(size))
	coll:set_restitution(0.55)
	--coll:set_friction(0.5)

	return coll
end




function FLK3D.SetUnivGravity(grav)
	local pUniv = getPhysicsWorld(FLK3D.CurrUniv)
	if not pUniv then
		pUniv = initPhysicsWorld(FLK3D.CurrUniv)
	end


	pUniv:set_gravity(grav[1], grav[2], grav[3])
end

function FLK3D.GetUnivGravity(grav)
	local pUniv = getPhysicsWorld(FLK3D.CurrUniv)
	if not pUniv then
		pUniv = initPhysicsWorld(FLK3D.CurrUniv)
	end


	local gx, gy, gz = pUniv:get_gravity()
	return Vector(gx, gy, gz)
end


function FLK3D.GetPhysicsBodyFromName(name)
	if not FLK3D.CurrUniv["physics_objects"] then
		return
	end

	return FLK3D.CurrUniv["physics_objects"][name]
end

function FLK3D.GetPhysicsColliderFromName(name)
	if not FLK3D.CurrUniv["physics_colliders"] then
		return
	end

	return FLK3D.CurrUniv["physics_colliders"][name]
end



function FLK3D.AddPhysicsBodyToUniv(name)
	if not getPhysicsWorld(FLK3D.CurrUniv) then
		pUniv = initPhysicsWorld(FLK3D.CurrUniv)
	end

	local body = fps.body.new()
	body._lkScale = Vector(1, 1, 1)


	local coll = getBoxCollider(Vector(1, 1, 1))
	coll:set_density(1)
	body:add_collider(coll)
	body:set_responsive(true)

	FLK3D.CurrUniv["physics_objects"][name] = body
	FLK3D.CurrUniv["physics_colliders"][name] = coll

	addBodyToWorld(body)
end


function FLK3D.SetPhysicsBodyStatic(name, bool)
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end

	body:set_static(bool)
end

function FLK3D.GetPhysicsBodyStatic(name)
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end

	return body.static
end


function FLK3D.SetPhysicsBodyMass(name, mass)
	local coll = FLK3D.GetPhysicsColliderFromName(name)
	if not coll then
		return
	end

	coll:set_density(mass)
end

function FLK3D.GetPhysicsBodyMass(name)
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end

	return body:get_mass()
end

function FLK3D.SetPhysicsBodyPos(name, pos)
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end


	body:set_position(pos[1], pos[2], pos[3])
end

function FLK3D.GetPhysicsBodyPos(name)
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end

	return body:get_position()
end

function FLK3D.SetPhysicsBodyAng(name, ang)
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end

	local matAng = Matrix()
	matAng:SetAngles(ang)
	




	local m1x1, m2x1, m3x1, m4x1,
		  m1x2, m2x2, m3x2, m4x2,
		  m1x3, m2x3, m3x3, m4x3,
		  m1x4, m2x4, m3x4, m4x4 = matAng:Unpack() --fps.matrix4.from_euler(ang[1], ang[2], ang[3])

	local pX, pY, pZ = body:get_position()
	--mat[ 4] = pX
	--mat[ 8] = pY
	--mat[12] = pZ


	body:set_transform(
		m1x1, m2x1, m3x1, pX,
		m1x2, m2x2, m3x2, pY,
		m1x3, m2x3, m3x3, pZ,
		m1x4, m2x4, m3x4, m4x4
	)
end

function FLK3D.GetPhysicsBodyAng(name)
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end

	return
end


function FLK3D.SetPhysicsBodyMatrix(name, mat)
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end

	body:set_transform(
		mat[ 1], mat[ 2], mat[ 3], mat[ 4],
		mat[ 5], mat[ 6], mat[ 7], mat[ 8],
		mat[ 9], mat[10], mat[11], mat[12],
		mat[13], mat[14], mat[15], mat[16]
	)
end

function FLK3D.GetPhysicsBodyMatrix(name)
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end

	local m1x1, m2x1, m3x1, m4x1,
		  m1x2, m2x2, m3x2, m4x2,
		  m1x3, m2x3, m3x3, m4x3,
		  m1x4, m2x4, m3x4, m4x4 = body:get_transform()


	return Matrix(
		m1x1, m2x1, m3x1, m4x1,
		m1x2, m2x2, m3x2, m4x2,
		m1x3, m2x3, m3x3, m4x3,
		m1x4, m2x4, m3x4, m4x4
	)
end




function FLK3D.SetPhysicsBodyPosAng(name, pos, ang)
	FLK3D.SetPhysicsBodyPos(name, pos)
	FLK3D.SetPhysicsBodyAng(name, ang)
end

function FLK3D.SetPhysicsBodyScl(name, scl)
	local coll = FLK3D.GetPhysicsColliderFromName(name)
	if not coll then
		return
	end

	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end

	--local newShape = getBoxShape(scl)
	--coll:set_shape(newShape)
	coll:set_size(scl[1], scl[2], scl[3])


	--body:update_mass()
	--body:update_boundary()


	body._lkScale = scl
end

function FLK3D.GetPhysicsBodyScl(name)
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end

	return body._lkScale
end


function FLK3D.SetPhysicsBodyVel(name, vel)
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end


	body:set_velocity(vel[1], vel[2], vel[3])
end


function FLK3D.GetPhysicsBodyBoundary(name)
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end

	local bounds = body.boundary

	return {
		Vector(bounds[1], bounds[2], bounds[3]),
		Vector(bounds[4], bounds[5], bounds[6])
	}
end



function FLK3D.RemovePhysicsBodyFromUniv(name)
	if not getPhysicsWorld(FLK3D.CurrUniv) then
		initPhysicsWorld(FLK3D.CurrUniv)
	end
	local body = FLK3D.GetPhysicsBodyFromName(name)
	if not body then
		return
	end

	removeBodyFromWorld(body)
end

local function drawDebugAABB(aabb)
	FLK3D.DebugUtils.Cross(aabb[1], .15, .05, Color(255, 0, 0))
	FLK3D.DebugUtils.Cross(aabb[2], .15, .05, Color(0, 255, 0))

	FLK3D.DebugUtils.Line(aabb[1], Vector(aabb[1].x, aabb[1].y, aabb[2].z), .05, Color(255, 255, 0))
	FLK3D.DebugUtils.Line(aabb[1], Vector(aabb[1].x, aabb[2].y, aabb[1].z), .05, Color(255, 255, 0))
	FLK3D.DebugUtils.Line(aabb[1], Vector(aabb[2].x, aabb[1].y, aabb[1].z), .05, Color(255, 255, 0))

	FLK3D.DebugUtils.Line(aabb[2], Vector(aabb[2].x, aabb[2].y, aabb[1].z), .05, Color(255, 255, 0))
	FLK3D.DebugUtils.Line(aabb[2], Vector(aabb[2].x, aabb[1].y, aabb[2].z), .05, Color(255, 255, 0))
	FLK3D.DebugUtils.Line(aabb[2], Vector(aabb[1].x, aabb[2].y, aabb[2].z), .05, Color(255, 255, 0))

	FLK3D.DebugUtils.Line(Vector(aabb[2].x, aabb[1].y, aabb[1].z), Vector(aabb[2].x, aabb[2].y, aabb[1].z), .05, Color(255, 255, 0))
	FLK3D.DebugUtils.Line(Vector(aabb[2].x, aabb[1].y, aabb[1].z), Vector(aabb[2].x, aabb[1].y, aabb[2].z), .05, Color(255, 255, 0))

	FLK3D.DebugUtils.Line(Vector(aabb[1].x, aabb[2].y, aabb[1].z), Vector(aabb[1].x, aabb[2].y, aabb[2].z), .05, Color(255, 255, 0))
	FLK3D.DebugUtils.Line(Vector(aabb[1].x, aabb[2].y, aabb[1].z), Vector(aabb[2].x, aabb[2].y, aabb[1].z), .05, Color(255, 255, 0))

	FLK3D.DebugUtils.Line(Vector(aabb[1].x, aabb[2].y, aabb[2].z), Vector(aabb[1].x, aabb[1].y, aabb[2].z), .05, Color(255, 255, 0))
	FLK3D.DebugUtils.Line(Vector(aabb[1].x, aabb[1].y, aabb[2].z), Vector(aabb[2].x, aabb[1].y, aabb[2].z), .05, Color(255, 255, 0))
end




local debugObjects = {}
function FLK3D.DebugRenderPhysicsObjects()
	if not FLK3D.CurrUniv["physics_objects"] then
		return
	end


	for k, v in pairs(FLK3D.CurrUniv["physics_objects"]) do
		if FLK3D.GetPhysicsBodyStatic(k) then
			goto _cont
		end


		if not FLK3D.CurrUniv["objects"][k] then
			FLK3D.AddObjectToUniv(k, "cube")
			FLK3D.SetObjectMat(k, "mandrill")
			FLK3D.SetObjectPosAng(k, Vector(0, 0, 0), Angle(0, 0, 0))
			FLK3D.SetObjectScl(k, FLK3D.GetPhysicsBodyScl(k) * 0.5)
			FLK3D.SetObjectFlag(k, "SHADING", true)
			FLK3D.SetObjectFlag(k, "SHADING_SMOOTH", false)

			--FLK3D.PushObjectAnims(k, "acube")
			--FLK3D.SetObjectAnim(k, "wiggle")
			--FLK3D.SetObjectAnimRate(k, .15)


			debugObjects[k] = true
		end

		local mat = FLK3D.GetPhysicsBodyMatrix(k)
		FLK3D.SetObjectMatrixRot(k, mat)

		

		FLK3D.SetObjectPos(k, mat:GetTranslation())
		--FLK3D.SetObjectAng(k, mat:GetAngles())
		--local bounds = FLK3D.GetPhysicsBodyBoundary(k)
		--drawDebugAABB(bounds)

		::_cont::
	end

	for k, v in pairs(debugObjects) do
		if FLK3D.CurrUniv["physics_objects"][k] == nil then
			FLK3D.RemoveObjectFromUniverse(k)
			debugObjects[k] = nil
		end
	end
end





local physItr = 3
function FLK3D.PhysicsThink(dt)
	--local dt = dt * .25
	local dt = 1 / 200--FrameTime() * .25

	local pWorld = getPhysicsWorld(FLK3D.CurrUniv)
	if not pWorld then
		return
	end

	for i = 1, physItr do
		pWorld:step(dt / physItr)
	end
end