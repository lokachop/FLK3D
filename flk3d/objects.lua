FLK3D = FLK3D or {}

function FLK3D.AddObjectToUniv(name, mdl)
	local mat_rot = Matrix()
	local mat_transscl = Matrix()
	mat_transscl:SetScale(Vector(1, 1, 1))

	FLK3D.CurrUniv["objects"][name] = {
		mdl = mdl,
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0),
		scl = Vector(1, 1, 1),
		col = {1, 1, 1},
		mat = "none",
		mat_rot = mat_rot,
		mat_transscl = mat_transscl
	}
end

function FLK3D.SetObjectPos(name, pos)
	FLK3D.CurrUniv["objects"][name].pos = pos or Vector(0, 0, 0)

	FLK3D.CurrUniv["objects"][name].mat_transscl:SetTranslation(pos)
end

function FLK3D.SetObjectAng(name, ang)
	FLK3D.CurrUniv["objects"][name].ang = ang or Angle(0, 0, 0)

	FLK3D.CurrUniv["objects"][name].mat_rot:SetAngles(ang)
end

function FLK3D.SetObjectPosAng(name, pos, ang)
	FLK3D.CurrUniv["objects"][name].pos = pos or Vector(0, 0, 0)
	FLK3D.CurrUniv["objects"][name].ang = ang or Angle(0, 0, 0)

	FLK3D.CurrUniv["objects"][name].mat_transscl:SetTranslation(pos)
	FLK3D.CurrUniv["objects"][name].mat_rot:SetAngles(ang)
end

function FLK3D.SetObjectScale(name, scl)
	FLK3D.CurrUniv["objects"][name].scl = scl or Vector(0, 0, 0)
	FLK3D.CurrUniv["objects"][name].mat_transscl:SetScale(scl)
end
function FLK3D.SetObjectScl(name, scl)
	FLK3D.CurrUniv["objects"][name].scl = scl or Vector(0, 0, 0)
	FLK3D.CurrUniv["objects"][name].mat_transscl:SetScale(scl)
end

function FLK3D.SetObjectCol(name, col)
	FLK3D.CurrUniv["objects"][name].col = col and {col[1], col[2], col[3]} or {1, 1, 1}
end

function FLK3D.SetObjectMat(name, mat)
	FLK3D.CurrUniv["objects"][name].mat = mat or "none"
end

function FLK3D.SetObjectFlag(name, flag, value)
	FLK3D.CurrUniv["objects"][name][flag] = value
end