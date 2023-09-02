FLK3D = FLK3D or {}
FLK3D.Version = "0.1"
FLK3D.Debug = true

local relaPath = "flk3d/"
function FLK3D.LoadFile(path)
    require(relaPath .. path)
end

FLK3D.LoadFile("libs/lmat") -- make sure to load lmat first
FLK3D.LoadFile("libs/lvec")
FLK3D.LoadFile("libs/lang")
FLK3D.LoadFile("libs/lknoise")
FLK3D.LoadFile("libs/lktex")

if love then
    FLK3D.LoadFile("renderlove")
end


FLK3D.LoadFile("universes")
FLK3D.LoadFile("rendertargets")
FLK3D.LoadFile("models")
FLK3D.LoadFile("basemodels")
FLK3D.LoadFile("objects")

FLK3D.LoadFile("camera")
FLK3D.LoadFile("raster")
FLK3D.LoadFile("pipeline")