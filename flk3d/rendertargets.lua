FLK3D = FLK3D or {}
FLK3D.RTRegistry = FLK3D.RTRegistry or {}

function FLK3D.NewRenderTarget(tag, w, h)
    if not tag then
        error("Attempt to make a renderTarget without a tag!")
    end

    if not w or not h then
        error("Dimensions for rendertarget \"" .. tag .. "\" not specified!")
    end



    FLK3D.RTRegistry[tag] = {}
    FLK3D.RTRegistry[tag]._params = {
        w = w,
        h = h,
    }

    FLK3D.RTRegistry[tag]._depth = {}


    for i = 0, (w * h) - 1 do
        FLK3D.RTRegistry[tag]._depth[i] = math.huge
        FLK3D.RTRegistry[tag][i] = {0, 0, 0}
    end

    return FLK3D.RTRegistry[tag]
end

FLK3D.BaseRT = FLK3D.NewRenderTarget("flk3d_base_rt", 512, 512)

FLK3D.CurrRT = FLK3D.BaseRT
FLK3D.RTStack = FLK3D.RTStack or {}


function FLK3D.PushRenderTarget(rt)
    FLK3D.RTStack[#FLK3D.RTStack + 1] = FLK3D.CurrRT
    FLK3D.CurrRT = rt
end

function FLK3D.PopRenderTarget()
    FLK3D.CurrRT = FLK3D.RTStack[#FLK3D.RTStack] or FLK3D.BaseRT
    FLK3D.RTStack[#FLK3D.RTStack] = nil
end

function FLK3D.Clear(r, g, b, depth)
    depth = depth or true
    local rt = FLK3D.CurrRT
    local rtParams = rt._params
    local rtW, rtH = rtParams.w, rtParams.h

    local dbuff = rt._depth

    for i = 0, (rtW * rtH) - 1 do
        rt[i] = {r or 0, g or 0, b or 0}
        dbuff[i] = math.huge
    end
end

function FLK3D.ClearDepth()
    local rt = FLK3D.CurrRT
    local rtParams = rt._params
    local rtW, rtH = rtParams.w, rtParams.h

    local dbuff = rt._depth

    for i = 0, (rtW * rtH) - 1 do
        dbuff[i] = math.huge
    end
end

function FLK3D.GetPixel(x, y)
    
end