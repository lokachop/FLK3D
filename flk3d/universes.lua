FLK3D = FLK3D or {}
FLK3D.UniverseRegistry = FLK3D.UniverseRegistry or {}

function FLK3D.NewUniverse(tag)
    if not tag then
        error("Attempt to make a universe without a tag!")
    end

    local univData = {
        ["objects"] = {},
        ["tag"] = tag
    }

    print("new universe, \"" .. tag .. "\"")
    FLK3D.UniverseRegistry[tag] = univData

    return FLK3D.UniverseRegistry[tag]
end

FLK3D.BaseUniv = FLK3D.NewUniverse("flk3d_base_univ")

FLK3D.CurrUniv = FLK3D.BaseUniv
FLK3D.UniverseStack = FLK3D.UniverseStack or {}

function FLK3D.PushUniverse(univ)
    FLK3D.UniverseStack[#FLK3D.UniverseStack + 1] = FLK3D.CurrUniv
    FLK3D.CurrUniv = univ
end

function FLK3D.PopUniverse(univ)
    FLK3D.CurrUniv = FLK3D.UniverseStack[#FLK3D.UniverseStack] or FLK3D.BaseUniv
    FLK3D.UniverseStack[#FLK3D.UniverseStack] = nil
end