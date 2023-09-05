FLK3D = FLK3D or {}
FLK3D.Models = FLK3D.Models or {}


function FLK3D.GenerateNormals(name, invert, onlySmooth)
	local data = FLK3D.Models[name]

	if not data then
		return
	end

	local verts = data.verts
	local ind = data.indices

	if not onlySmooth then
		data.normals = {}
		for i = 1, #ind do
			local index = ind[i]

			local v1 = verts[index[1][1]] * 1
			local v2 = verts[index[2][1]] * 1
			local v3 = verts[index[3][1]] * 1

			local norm = (v2 - v1):Cross(v3 - v1)
			norm:Normalize()
			if invert then
				norm = -norm
			end
			data["normals"][i] = norm
		end
	end

	data.s_normals = {}
	for i = 1, #data["normals"] do
		local n = data["normals"][i]
		local index = ind[i]


		local id1 = index[1][1]
		data.s_normals[id1] = (data.s_normals[id1] or Vector(0, 0, 0)) + n
		local id2 = index[2][1]
		data.s_normals[id2] = (data.s_normals[id2] or Vector(0, 0, 0)) + n
		local id3 = index[3][1]

		data.s_normals[id3] = (data.s_normals[id3] or Vector(0, 0, 0)) + n
	end


	for i = 1, #data["s_normals"] do
		if data["s_normals"][i] then
			data["s_normals"][i]:Normalize()
		else
			data["s_normals"][i] = Vector(0, 1, 0)
		end
	end
end


function FLK3D.DeclareModel(name, data)
	FLK3D.Models[name] = data
	FLK3D.GenerateNormals(name)
	print("Declared model \"" .. name .. "\" with " .. #data.verts .. " verts! ^[TBL]")
end

-- glua
local function string_ToTable(str)
	local tbl = {}

	for i = 1, #str do
		tbl[i] = string.sub(str, i, i)
	end

	return tbl
end

local string_sub = string.sub
local string_find = string.find
local string_len = string.len
local function string_explode( separator, str, withpattern)
	if (separator == "") then
		return string_ToTable(str)
	end

	if withpattern == nil then
		withpattern = false
	end

	local ret = {}
	local current_pos = 1

	for i = 1, string_len(str) do
		local start_pos, end_pos = string_find(str, separator, current_pos, not withpattern)
		if not start_pos then
			break
		end
		ret[i] = string_sub(str, current_pos, start_pos - 1)
		current_pos = end_pos + 1
	end

	ret[#ret + 1] = string_sub(str, current_pos)

	return ret
end

local function string_trim( s, char )
	if ( char ) then char = string.PatternSafe( char ) else char = "%s" end
	return string.match( s, "^" .. char .. "*(.-)" .. char .. "*$" ) or s
end

function FLK3D.DeclareModelOBJ(name, objData)
	local data = {}
	data["verts"] = {}
	data["uvs"] = {}
	data["indices"] = {}
	data["normals"] = {}
	data["s_normals"] = {}

	local verts = data["verts"]
	local uvs = data["uvs"]
	local indices = data["indices"]
	local normals = data["normals"]
	local s_normals = data["s_normals"]

	local hadNormal = false

	local _tempNormals = {}

	-- its obj so parse each line
	for k, v in ipairs(string_explode("\n", objData, false)) do
		local ident = string.sub(v, 1, 2)
		ident = string_trim(ident)
		local cont = string.sub(v, #ident + 2) -- shit code
		if not cont then
			goto _cont
		end

		if ident == "#" then
			print("[Comment]: " .. cont)
		elseif ident == "v" then
			local expVars = string_explode(" ", cont, false)

			local x = tonumber(string_trim(expVars[1]))
			local y = tonumber(string_trim(expVars[2]))
			local z = tonumber(string_trim(expVars[3]))

			local vecBuild = Vector(x, y, z)
			verts[#verts + 1] = vecBuild
		elseif ident == "vt" then
			local expVars = string_explode(" ", cont, false)

			local uR = tonumber(string_trim(expVars[1]))
			local vR = tonumber(string_trim(expVars[2]))

			uvs[#uvs + 1] = {uR, vR}
		elseif ident == "vn" then
			hadNormal = true

			local expVars = string_explode(" ", cont, false)
			local x = tonumber(string_trim(expVars[1]))
			local y = tonumber(string_trim(expVars[2]))
			local z = tonumber(string_trim(expVars[3]))

			local vecBuild = Vector(x, y, z)
			_tempNormals[#_tempNormals + 1] = vecBuild
		elseif ident == "f" then
			local expVars = string_explode(" ", cont, false)

			local bInd = {}

			local normAvgBuild = {}
			local hadNorm = false
			for i = 1, 3 do
				local datExp2 = string_explode("/", expVars[i], false)
				local iP, iTN, iT = tonumber(datExp2[1]), tonumber(datExp2[2]), tonumber(datExp2[3])

				if iP and (not iTN) and (not iTN) then -- pos only
					bInd[#bInd + 1] = {iP, 1}
				end

				if iP and iTN and (not iT) then -- pos / tex
					bInd[#bInd + 1] = {iP, iTN}
				end

				if iP and iTN and iT then -- pos / norm / tex
					bInd[#bInd + 1] = {iP, iTN}

					s_normals[#s_normals + 1] = _tempNormals[iT] * 1
					normAvgBuild[i] = _tempNormals[iT] * 1
					hadNorm = true
				end

				if iP and (not iTN) and iT then -- pos // norm
					bInd[#bInd + 1] = {iP, 1}

					s_normals[#s_normals + 1] = _tempNormals[iT] * 1
					normAvgBuild[i] = _tempNormals[iT] * 1
					hadNorm = true
				end
			end

			indices[#indices + 1] = bInd

			if hadNorm then
				local norm = (normAvgBuild[1] + normAvgBuild[2] + normAvgBuild[3])
				norm:Normalize()
				normals[#normals + 1] = norm
			end
		end

		::_cont::
	end

	FLK3D.Models[name] = data
	FLK3D.GenerateNormals(name, false, hadNormal)
	print("Declared model \"" .. name .. "\" with " .. #data.verts .. " verts! ^[OBJ]")
end