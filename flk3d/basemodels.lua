FLK3D = FLK3D or {}

-- path is relative to root
local function readFile(path)
    return love.filesystem.read(path)
end

local function loadModelFromOBJ(name, path)
    local objData = readFile(path)
    if not objData then
        error("Could not read model \"" .. path .. "\"")
        return
    end

    FLK3D.DeclareModelOBJ(name, objData)
end

loadModelFromOBJ("cube", "models/cubenuv.obj")
loadModelFromOBJ("lokachop_sqr", "models/lokachopsqr.obj")
loadModelFromOBJ("train", "models/train2.obj")

loadModelFromOBJ("traintrack_hq", "models/traintrack.obj")
loadModelFromOBJ("traintrack", "models/traintrack_lod.obj")