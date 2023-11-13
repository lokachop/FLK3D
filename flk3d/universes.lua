FLK3D = FLK3D or {}
FLK3D.UniverseRegistry = FLK3D.UniverseRegistry or {}

function FLK3D.NewUniverse(tag)
    if not tag then
        error("Attempt to make a universe without a tag!")
    end

    local univData = {
        ["objects"] = {},
        ["tag"] = tag,
        ["worldParameteri"] = {
            ["SunDir"] = Vector(0, 0, -1)
        }
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

function FLK3D.PopUniverse()
    local _prev = FLK3D.CurrUniv
    FLK3D.CurrUniv = FLK3D.UniverseStack[#FLK3D.UniverseStack] or FLK3D.BaseUniv
    FLK3D.UniverseStack[#FLK3D.UniverseStack] = nil

    return _prev
end

function FLK3D.ClearUniverse(univ)
    univ = univ or FLK3D.CurrUniv

    for k, v in pairs(univ["objects"]) do
        univ[k] = nil
    end
end

function FLK3D.GetUniverseByTag(tag)
    return FLK3D.UniverseRegistry[tag]
end

function FLK3D.GetUniverseParams(univ)
    univ = univ or FLK3D.CurrUniv

    return univ.worldParameteri
end