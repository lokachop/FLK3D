FLK3D = FLK3D or {}
FLK3D.Version = "0.2"
FLK3D.Debug = true

FLK3D.DO_PERSP_CORRECT_COLOUR   = false
FLK3D.DO_PERSP_CORRECT_TEXTURE  = true

FLK3D.TEXINTERP_MODE = 0 -- 0 = nearest, 1 = bayer, 2 = linear
FLK3D.WIREFRAME = false
FLK3D.RENDER_HALF = false

FLK3D.RelaPath = "flk3d."
function FLK3D.LoadFile(path)
    require(FLK3D.RelaPath .. path)
end

FLK3D.LoadFile("libs.lmat") -- make sure to load lmat first
FLK3D.LoadFile("libs.lvec")
FLK3D.LoadFile("libs.lang")
FLK3D.LoadFile("libs.lknoise")
FLK3D.LoadFile("libs.lktex")

FLK3D.SunDir = Vector(1, 2, 4):GetNormalized()

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

FLK3D.LoadFile("physics")

FLK3D.LoadFile("ulk3d_support")