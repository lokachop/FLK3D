FLK3D = FLK3D or {}


local function scaleViewport(w, h, v)
	return (v[1] * w * .5) + (w * .5), (v[2] * h * .5) + (h * .5)
end

local function lerp(t, a, b)
	return a * (1 - t) + b * t
end

local function lerpVec(t, a, b)
	return LVEC.Vector(
		a[1] * (1 - t) + b[1] * t,
		a[2] * (1 - t) + b[2] * t,
		a[3] * (1 - t) + b[3] * t,
		a[4] * (1 - t) + b[4] * t
	)
end
local function lerpUV(t, a, b)
	return {
		a[1] * (1 - t) + b[1] * t,
		a[2] * (1 - t) + b[2] * t,
	}
end

local function lerpCol(t, a, b)
	return {
		a[1] * (1 - t) + b[1] * t,
		a[2] * (1 - t) + b[2] * t,
		a[3] * (1 - t) + b[3] * t,
	}
end

local function clip1(tbl, tbluv, tblCol, v1, v2, v3, uv1, uv2, uv3, c1, c2, c3)
	local alphaA = (-v1[3]) / (v2[3] - v1[3])
	local alphaB = (-v1[3]) / (v3[3] - v1[3])

	local v1o = lerpVec(alphaA, v1, v2)
	local v2o = lerpVec(alphaB, v1, v3)

	local uv1o = lerpUV(alphaA, uv1, uv2)
	local uv2o = lerpUV(alphaB, uv1, uv3)

	local c1o = lerpCol(alphaA, c1, c2)
	local c2o = lerpCol(alphaB, c1, c3)

	tbl[#tbl + 1] = {v1o, v2, v3}
	tbluv[#tbluv + 1] = {uv1o, uv2, uv3}
	tblCol[#tblCol + 1] = {c1o, c2, c3}

	tbl[#tbl + 1] = {v2o, v1o, v3}
	tbluv[#tbluv + 1] = {uv2o, uv1o, uv3}
	tblCol[#tblCol + 1] = {c2o, c1o, c3}
end

local function clip2(tbl, tbluv, tblCol, v1, v2, v3, uv1, uv2, uv3, c1, c2, c3)
	local alphaA = (-v1[3]) / ((v3[3] - v1[3]) + .00001) -- no div0
	local alphaB = (-v2[3]) / ((v3[3] - v2[3]) + .00001)

	local v1o = lerpVec(alphaA, v1, v3)
	local v2o = lerpVec(alphaB, v2, v3)

	local uv1o = lerpUV(alphaA, uv1, uv3)
	local uv2o = lerpUV(alphaB, uv2, uv3)

	local c1o = lerpCol(alphaA, c1, c3)
	local c2o = lerpCol(alphaB, c2, c3)

	tbl[#tbl + 1] = {v1o, v2o, v3}
	tbluv[#tbluv + 1] = {uv1o, uv2o, uv3}
	tblCol[#tblCol + 1] = {c1o, c2o, c3}
end

-- returns tbl of verts
local function clipTri(v1, v2, v3, uv1, uv2, uv3, c1, c2, c3)

	-- cull
	-- xGreater
	if  v1[1] < v1[4] and
		v2[1] < v2[4] and
		v3[1] < v3[4] then
		return
	end

	-- xLess
	if  v1[1] > -v1[4] and
		v2[1] > -v2[4] and
		v3[1] > -v3[4] then
		return
	end

	-- yGreater
	if  v1[2] < v1[4] and
		v2[2] < v2[4] and
		v3[2] < v3[4] then
		return
	end

	-- yLess
	if  v1[2] > -v1[4] and
		v2[2] > -v2[4] and
		v3[2] > -v3[4] then
		return
	end

	local v1z = -v1[3]
	local v2z = -v2[3]
	local v3z = -v3[3]

	if v1z < 0 and v2z < 0 and v3z < 0 then
		return
	end

	local tblOut = {}
	local tblUV = {}
	local tblCol = {}
	-- near plane
	if v1z < 0 then
		if v2z < 0 then
			clip2(tblOut, tblUV, tblCol, v1, v2, v3, uv1, uv2, uv3, c1, c2, c3)
		elseif v3z < 0 then
			clip2(tblOut, tblUV, tblCol, v1, v3, v2, uv1, uv3, uv2, c1, c3, c2)
		else
			clip1(tblOut, tblUV, tblCol, v1, v2, v3, uv1, uv2, uv3, c1, c2, c3)
		end
	elseif v2z < 0 then
		if v3z < 0 then
			clip2(tblOut, tblUV, tblCol, v2, v3, v1, uv2, uv3, uv1, c2, c3, c1)
		else
			clip1(tblOut, tblUV, tblCol, v2, v1, v3, uv2, uv1, uv3, c2, c1, c3)
		end
	elseif v3z < 0 then
		clip1(tblOut, tblUV, tblCol, v3, v1, v2, uv3, uv1, uv2, c3, c1, c2)
	else
		tblOut[#tblOut + 1] = {v1, v2, v3}
		tblUV[#tblUV + 1] = {uv1, uv2, uv3}
		tblCol[#tblCol + 1] = {c1, c2, c3}
	end

	return tblOut, tblUV, tblCol
end

local _dbgFrameTime = 0
local _dbgOBJCount = 0
local _dbgVertCount = 0
local _dbgTriCount = 0
FLK3D.DebugFragments = 0
FLK3D.DebugFragmentsAttempted = 0

local avgDtSamples = {}
local sID = 0
local sampleCount = 16
for i = 0, sampleCount - 1 do
	avgDtSamples[i] = 0
end

local _red = {255, 0, 0}
local _yellow = {255, 255, 0}
local _green = {0, 255, 0}
local _background = {0, 0, 0}
local function renderDebug()
	if not FLK3D.Debug then
		return
	end

	local rt = FLK3D.CurrRT
	local rtParams = rt._params
	local w, h = rtParams.w, rtParams.h

	local yVar = 1
	FLK3D.DrawText({0, 255, 0}, "FLK3D v" .. FLK3D.Version, 1, yVar, _background)
	yVar = yVar + 8

	FLK3D.DrawText({0, 255, 0}, tostring(w) .. "x" .. tostring(h), 1, yVar, _background)
	yVar = yVar + 8


	avgDtSamples[sID] = _dbgFrameTime
	sID = ((sID + 1) % sampleCount)

	if #avgDtSamples < (sampleCount - 1) then
		return
	end

	local avgDT = 0
	for i = 0, sampleCount - 1 do
		avgDT = avgDT + avgDtSamples[i]
	end
	avgDT = avgDT / sampleCount

	local fpsVar = 1 / avgDT
	local fpsCol = fpsVar < 20 and _red or (fpsVar < 60 and _yellow or _green)

	FLK3D.DrawText(fpsCol, "FPS : " .. string.format("%.2f", fpsVar), 1, yVar, _background)
	yVar = yVar + 8

	FLK3D.DrawText({0, 255, 0}, "DT  : " .. string.format("%.2f", avgDT * 1000) .. "ms", 1, yVar, _background)
	yVar = yVar + 8

	FLK3D.DrawText({0, 255, 0}, "OBJ : " .. _dbgOBJCount, 1, yVar, _background)
	yVar = yVar + 8

	FLK3D.DrawText({0, 255, 0}, "TRIS: " .. _dbgTriCount, 1, yVar, _background)
	yVar = yVar + 8

	FLK3D.DrawText({0, 255, 0}, "VERT: " .. _dbgVertCount, 1, yVar, _background)
	yVar = yVar + 8

	FLK3D.DrawText({0, 255, 0}, "FRAG: " .. FLK3D.DebugFragments .. " [" .. FLK3D.DebugFragmentsAttempted .. "]", 1, yVar, _background)
	yVar = yVar + 8

	_dbgOBJCount = 0
	_dbgVertCount = 0
	_dbgTriCount = 0
	FLK3D.DebugFragments = 0
	FLK3D.DebugFragmentsAttempted = 0
end


local perspCol = FLK3D.DO_PERSP_CORRECT_COLOUR
local perspTex = FLK3D.DO_PERSP_CORRECT_TEXTURE
local function renderObject(obj)
	local rt = FLK3D.CurrRT
	local rtParams = rt._params
	local w, h = rtParams.w, rtParams.h


	local mdlData = FLK3D.Models[obj.mdl]
	local verts = mdlData.verts
	local indices = mdlData.indices
	local normals = mdlData.normals
	local s_normals = mdlData.s_normals
	local uvs = mdlData.uvs


	local col = obj.col
	local objColR = col[1]
	local objColG = col[2]
	local objColB = col[3]

	local textureData = LKTEX.Textures[obj.mat]


	-- transform the verts
	local transf = {}
	if FLK3D.Debug then
		_dbgVertCount = _dbgVertCount + #verts
	end

	for i = 1, #verts do
		local vert = verts[i]

		local cpy = vert:Copy()
		-- local
		cpy = cpy * obj.mat_rot
		cpy = cpy * obj.mat_transscl

		-- TODO: implement cam matrix
		local transRot = FLK3D.CamMatrix_Rot * FLK3D.CamMatrix_Trans
		cpy = cpy * transRot

		transf[#transf + 1] = cpy
	end


	local zsort = {}
	for i = 1, #indices do
		local idx = indices[i]

		local v1 = transf[idx[1][1]]
		local v2 = transf[idx[2][1]]
		local v3 = transf[idx[3][1]]

		local avgZ = (v1[3] + v2[3] + v3[3]) * .33

		zsort[#zsort + 1] = {i, -avgZ}
	end

	table.sort(zsort, function(a, b)
		return a[2] < b[2]
	end)


	for b = 1, #zsort do
		local i = zsort[b][1]
		local idx = indices[i]

		local v1 = transf[idx[1][1]]
		local v2 = transf[idx[2][1]]
		local v3 = transf[idx[3][1]]

		local puv1 = uvs[idx[1][2]]
		local puv2 = uvs[idx[2][2]]
		local puv3 = uvs[idx[3][2]]


		local v1s = v1:Copy() * FLK3D.CamMatrix_Proj
		local v2s = v2:Copy() * FLK3D.CamMatrix_Proj
		local v3s = v3:Copy() * FLK3D.CamMatrix_Proj


		local pcol_s1 = {objColR, objColG, objColB}
		local pcol_s2 = {objColR, objColG, objColB}
		local pcol_s3 = {objColR, objColG, objColB}

		if obj["SHADING"] and obj["SHADING_SMOOTH"] then
			local norm1 = s_normals[idx[1][1]]:Copy()
			norm1 = norm1 * obj.mat_rot

			local norm2 = s_normals[idx[2][1]]:Copy()
			norm2 = norm2 * obj.mat_rot

			local norm3 = s_normals[idx[3][1]]:Copy()
			norm3 = norm3 * obj.mat_rot

			local dot1 = norm1:Dot(FLK3D.SunDir)
			local dot2 = norm2:Dot(FLK3D.SunDir)
			local dot3 = norm3:Dot(FLK3D.SunDir)

			dot1 = math.max((dot1 + 2) * .25, 0)
			dot2 = math.max((dot2 + 2) * .25, 0)
			dot3 = math.max((dot3 + 2) * .25, 0)

			pcol_s1[1] = pcol_s1[1] * dot1
			pcol_s1[2] = pcol_s1[2] * dot1
			pcol_s1[3] = pcol_s1[3] * dot1

			pcol_s2[1] = pcol_s2[1] * dot2
			pcol_s2[2] = pcol_s2[2] * dot2
			pcol_s2[3] = pcol_s2[3] * dot2

			pcol_s3[1] = pcol_s3[1] * dot3
			pcol_s3[2] = pcol_s3[2] * dot3
			pcol_s3[3] = pcol_s3[3] * dot3
		elseif obj["SHADING"] then
			local norm = normals[i]:Copy()
			norm = norm * obj.mat_rot

			local dot = norm:Dot(FLK3D.SunDir)
			dot = math.max((dot + 2) * .25, 0)

			pcol_s1[1] = pcol_s1[1] * dot
			pcol_s1[2] = pcol_s1[2] * dot
			pcol_s1[3] = pcol_s1[3] * dot

			pcol_s2[1] = pcol_s2[1] * dot
			pcol_s2[2] = pcol_s2[2] * dot
			pcol_s2[3] = pcol_s2[3] * dot

			pcol_s3[1] = pcol_s3[1] * dot
			pcol_s3[2] = pcol_s3[2] * dot
			pcol_s3[3] = pcol_s3[3] * dot
		end



		-- lets do clipping!
		local tris, uvs, cols = clipTri(v1s, v2s, v3s, puv1, puv2, puv3, pcol_s1, pcol_s2, pcol_s3)
		if not tris then
			goto _contRenderLast
		end

		for j = 1, #tris do
			local trisC = tris[j]
			local uvsC = uvs[j]
			local colsC = cols[j]
			--local cv1, cv2, cv3 = trisC[1], trisC[2], trisC[3]
			local cv1 = trisC[1]:Copy()
			local cv2 = trisC[2]:Copy()
			local cv3 = trisC[3]:Copy()

			cv1:Div(cv1[4]) -- div by w here
			cv2:Div(cv2[4])
			cv3:Div(cv3[4])

			local uv1 = uvsC[1]
			local uv2 = uvsC[2]
			local uv3 = uvsC[3]


			local d1s, d2s, d3s = cv1[3], cv2[3], cv3[3]
			if (d1s >= 1) or (d2s >= 1) or (d3s >= 1) then
				goto _contRender
			end

			local d1, d2, d3 = cv1[4], cv2[4], cv3[4]

			local v1_w = 1 / d1
			local v2_w = 1 / d2
			local v3_w = 1 / d3

			local px1, py1 = scaleViewport(w, h, cv1)
			local px2, py2 = scaleViewport(w, h, cv2)
			local px3, py3 = scaleViewport(w, h, cv3)

			local norm = normals[i]:Copy()
			norm = norm * obj.mat_rot

			local normCam = norm:Copy()
			normCam = normCam * FLK3D.CamMatrix_Rot

			local dotCam = normCam:Dot(v1)
			if dotCam > 0 then
				goto _contRender
			end


			local tu1, tv1 = uv1[1], uv1[2]
			local tu2, tv2 = uv2[1], uv2[2]
			local tu3, tv3 = uv3[1], uv3[2]
			if perspTex then
				tu1, tv1 = tu1 / d1, tv1 / d1
				tu2, tv2 = tu2 / d2, tv2 / d2
				tu3, tv3 = tu3 / d3, tv3 / d3
			end

			local col_s1, col_s2, col_s3

			if perspCol then
				col_s1 = {colsC[1][1], colsC[1][2], colsC[1][3]}
				col_s1[1] = col_s1[1] / d1
				col_s1[2] = col_s1[2] / d1
				col_s1[3] = col_s1[3] / d1

				col_s2 = {colsC[2][1], colsC[2][2], colsC[2][3]}
				col_s2[1] = col_s2[1] / d2
				col_s2[2] = col_s2[2] / d2
				col_s2[3] = col_s2[3] / d2

				col_s3 = {colsC[3][1], colsC[3][2], colsC[3][3]}
				col_s3[1] = col_s3[1] / d3
				col_s3[2] = col_s3[2] / d3
				col_s3[3] = col_s3[3] / d3
			else
				col_s1 = colsC[1]
				col_s2 = colsC[2]
				col_s3 = colsC[3]
			end

			FLK3D.RenderTriangleSimple(px1, py1, px2, py2, px3, py3,
			col_s1, col_s2, col_s3,
			v1_w, v2_w, v3_w,
			tu1, tv1, tu2, tv2, tu3, tv3, textureData
			)

			if FLK3D.Debug then
				_dbgTriCount = _dbgTriCount + 1
			end

			::_contRender::
		end



		::_contRenderLast::
	end

end



function FLK3D.RenderActiveUniverse()
	if FLK3D.Debug then
		_dbgFrameTime = os.clock()
	end
	local objects = FLK3D.CurrUniv["objects"]



	-- lets zsort objects
	local zsort = {}
	for k, v in pairs(objects) do
		local cpy = v.pos:Copy()
		-- local
		cpy = cpy * v.mat_rot
		cpy = cpy * v.mat_transscl

		local transRot = FLK3D.CamMatrix_Rot * FLK3D.CamMatrix_Trans
		cpy = cpy * transRot

		zsort[#zsort + 1] = {v, -cpy[3], k}
	end

	table.sort(zsort, function(a, b)
		return a[2] < b[2]
	end)

	for k, v in ipairs(zsort) do
		if FLK3D.Debug then
			_dbgOBJCount = _dbgOBJCount + 1
		end

		renderObject(v[1])
	end
	if FLK3D.Debug then
		local timef = os.clock() - _dbgFrameTime
		_dbgFrameTime = timef
	end

	renderDebug()
end