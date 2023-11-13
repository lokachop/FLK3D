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

loadModelFromOBJ("traintrack_hq", "models/traintrack.obj")
loadModelFromOBJ("traintrack", "models/traintrack_lod.obj")

loadModelFromOBJ("train", "models/train/train.obj")
loadModelFromOBJ("train_lod1", "models/train/train_lod1.obj")
loadModelFromOBJ("train_lod2", "models/train/train_lod2.obj")



loadModelFromOBJ("vehicle_apc_hull", "models/vehicle_apc/vehicleHull.obj")
loadModelFromOBJ("vehicle_apc_turret", "models/vehicle_apc/vehicleTurret.obj")
loadModelFromOBJ("vehicle_apc_turret_cannon", "models/vehicle_apc/vehicleTurretCannon.obj")
loadModelFromOBJ("vehicle_apc_wheel", "models/vehicle_apc/vehicleWheel.obj")