FLK3D = FLK3D or {}
ULK3D = ULK3D or {}
--[[
    ULK3D Specification
    Universal LK3D

    What is this for?
    allows writing LK3D code that will run in multiple platforms (ex. love2d (software/hardware), starfall, glua)
]]--
--[[
    Basic Info

    ULK3D.EngineName // set by user; platform; engine name (render mode)
]]-- 
ULK3D.EngineName = "LÖVE2D; FLK3D (Software)"

--[[
    Print handling

    consts:
    ULK3D_SEVERITY_DEBUG = 1
    ULK3D_SEVERITY_INFO = 2
    ULK3D_SEVERITY_WARNING = 3
    ULK3D_SEVERITY_ERROR = 4

    ULK3D.PrintThreshold = ULK3D_SEVERITY_DEBUG // threshold needed to print

    function ULK3D.SetPrintThreshold(treshold)
        sets the print threshold to given number or debug if nil

    function ULK3D.PrintDebug(msg, mod)
        prints a debug message with mod prefix support
    
    function ULK3D.PrintInfo(msg, mod)
        prints a info message with mod prefix support

    function ULK3D.PrintWarning(msg, mod)
        prints a warning message with mod prefix support
    
    function ULK3D.PrintError(msg, mod)
        prints a error message with mod prefix support
]]-- 
ULK3D_SEVERITY_DEBUG = 1
ULK3D_SEVERITY_INFO = 2
ULK3D_SEVERITY_WARNING = 3
ULK3D_SEVERITY_ERROR = 4

ULK3D.PrintThreshold = ULK3D_SEVERITY_DEBUG
function ULK3D.SetPrintThreshold(treshold)
    ULK3D.PrintThreshold = (tonumber(treshold) == treshold) and treshold or ULK3D_SEVERITY_DEBUG
end

local _modColours = {
    ["base"] = {100, 100, 100},
    ["modelutils"] = {255, 100, 255},
    ["particles"] = {128, 196, 255},
    ["procmodel"] = {255, 100, 100},
    ["noise"] = {64, 196, 64},
    ["proctex"] = {100, 100, 255},
    ["physics"] = {64, 196, 128},
    ["benchmark"] = {16, 128, 96},
    ["textureutils"] = {128, 64, 255},
    ["tracesystem"] = {128, 255, 64},
}

local _sevFancyNames = {
    [ULK3D_SEVERITY_DEBUG] = "[DEBUG] ",
    [ULK3D_SEVERITY_INFO] = "[INFO] ",
    [ULK3D_SEVERITY_WARNING] = "[WARNING] ",
    [ULK3D_SEVERITY_ERROR] = "[ERROR] "
}

local function printGeneral(msg, mod, sev)
    mod = mod or "base"
    local cTresh = ULK3D.PrintThreshold
    if cTresh > sev then
        return
    end

    -- not needed on LÖVE2D
    --[[
    modCol = _modColours[string.lower(mod)] or _modColours["base"]
    local modColBrighter = {
        math.min(modCol[1] + 100, 255),
        math.min(modCol[2] + 100, 255),
        math.min(modCol[3] + 100, 255)
    }
    ]]--

    print(_sevFancyNames[sev] .. "[" .. string.upper(mod) .. "]: " .. msg)
end

function ULK3D.PrintDebug(msg, mod)
    printGeneral(msg, mod, ULK3D_SEVERITY_DEBUG)
end

function ULK3D.PrintInfo(msg, mod)
    printGeneral(msg, mod, ULK3D_SEVERITY_INFO)
end

function ULK3D.PrintWarning(msg, mod)
    printGeneral(msg, mod, ULK3D_SEVERITY_WARNING)
end

function ULK3D.PrintError(msg, mod)
    printGeneral(msg, mod, ULK3D_SEVERITY_ERROR)
    print(debug.traceback())
end


ULK3D.PrintDebug("ULK3D Loading on engine \"" .. ULK3D.EngineName .. "\"")

-- Shader Capabilities:
ULK3D_CAPAB_VERTSHADER_LUA = 1  -- lua vert shader funcs on objects
ULK3D_CAPAB_FRAGSHADER_LUA = 2  -- lua frag shader on objects (software only)
ULK3D_CAPAB_VERTSHADER_GLSL = 3 -- glsl vert shader funcs on objects (hwaccel only)
ULK3D_CAPAB_FRAGSHADER_GLSL = 4 -- glsl frag shader on objects (hwaccel only)

-- Lighting Capabilities:
ULK3D_CAPAB_VERTLIGHT = 20      -- vertex lighting (LK3D)
ULK3D_CAPAB_FRAGLIGHT = 21      -- fragment lighting (per-pixel)
ULK3D_CAPAB_SHADOWVOLUME = 22   -- shadow volumes
ULK3D_CAPAB_LIGHTMAP = 23       -- loading LLM lightmaps
ULK3D_CAPAB_LIGHTMAP_GEN = 24   -- generating LLM lightmaps

-- Rendering Capabilities:
ULK3D_CAPAB_WIREFRAME = 40          -- can draw wireframe triangles
ULK3D_CAPAB_FLAT = 41               -- can draw filled triangles (solid colour with no colour)
ULK3D_CAPAB_FLAT_1_COL = 42         -- can draw filled triangles (with non interpolated colour)
ULK3D_CAPAB_FLAT_3_COL = 43         -- can draw filled triangles (with colour interpolation)
ULK3D_CAPAB_TEXTURED = 44           -- can draw textured triangles (with no colour)
ULK3D_CAPAB_TEXTURED_1COL = 45      -- can draw textured triangles (with non interpolated colour)
ULK3D_CAPAB_TEXTURED_3COL = 46      -- can draw textured triangles (with interpolated colour)
ULK3D_CAPAB_LM_TEXTURED_3COL = 47   -- can draw lightmapped textured triangles (with interpolated colour)
ULK3D_CAPAB_TEXTURE_AFFINE = 48     -- can draw affine triangles
ULK3D_CAPAB_TEXTURE_PERSP = 49      -- can draw perspective-correct triangles


-- Texture Capabilities:
ULK3D_CAPAB_TEXTURE = 60            -- can do texturing
ULK3D_CAPAB_TEXFILTER_NONE = 61     -- can do nearest texture filterin
ULK3D_CAPAB_TEXFILTER_BAYER = 62    -- can do bayer filtering
ULK3D_CAPAB_TEXFILTER_LINEAR = 63   -- can do linear

-- Format Capabilities:
ULK3D_CAPAB_LOAD_LKPACK = 80    -- can load LKPack files
ULK3D_CAPAB_LOAD_LLM = 81       -- lightmap loading from .llm
ULK3D_CAPAB_LOAD_OBJ = 82       -- can load obj models
ULK3D_CAPAB_LOAD_LKC = 83       -- can load LKComp models
ULK3D_CAPAB_LOAD_PPM = 84       -- can load PPM textures
ULK3D_CAPAB_LOAD_PNG = 85       -- can load PNG textures
ULK3D_CAPAB_LOAD_LKF = 86       -- can load LKF files (keyframes)


-- HW Capabilities:
ULK3D_CAPAB_GPUACCEL = 100      -- if the engine has hardware support (ex. hardware rendered LK3D)
ULK3D_CAPAB_LIGHTMAP_GEN = 101  -- lightmap generation (slow) output .llm


-- ObjectFlag Capabilities:
ULK3D_CAPAB_OBJECT_SHADE_FLAT = 120     -- flat shading
ULK3D_CAPAB_OBJECT_SHADE_SMOOTH = 121   -- gouraud shading
ULK3D_CAPAB_OBJECT_TRANSLATE = 122      -- translation
ULK3D_CAPAB_OBJECT_ROTATE = 123         -- rotation
ULK3D_CAPAB_OBJECT_SCALE = 124          -- scaling
ULK3D_CAPAB_OBJECT_CACHE = 125          -- mesh caching (LK3D-style)
ULK3D_CAPAB_OBJECT_COLOUR = 126         -- set object colour
ULK3D_CAPAB_OBJECT_ANIMATE = 127        -- can object be animated



-- Module Capabilities:
ULK3D_CAPAB_MODELUTILS = 140     -- if the engine has the modelUtils module
ULK3D_CAPAB_PARTICLES = 141      -- if the engine has the particles module
ULK3D_CAPAB_PROCMODEL = 142      -- if the engine has the procModel module
ULK3D_CAPAB_NOISE = 143          -- if the engine has the noise module
ULK3D_CAPAB_PROCTEX = 144        -- if the engine has the procTex module
ULK3D_CAPAB_PHYSICS = 145        -- if the engine has the physics modul
ULK3D_CAPAB_BENCHMARK = 146      -- if the engine has the benchmakr module
ULK3D_CAPAB_TEXTUREUTILS = 147   -- if the engine has the textureutils module
ULK3D_CAPAB_TRACESYSTEM = 148    -- if the engine has the tracesystem module



--[[
        function ULK3D.GetCapabilities()
            returns a table pointer with the capabilities of the platforms

        function ULK3D.GetCapability(number capab)
            returns if the current engine can do that capability, nil if invalid / non existent capability
]]--

local _capabilities = {
}

function ULK3D.GetCapabilities()
    return _capabilities
end

function ULK3D.GetCapability(capab)
    return _capabilities[capab]
end


--[[
    Universes:
            table univ = {
                ["tag"] = "Universe Tag",
                ["objects"] = {},
                ["lights"] =  {},
                ["particles"] = {},
                ["worldParameteri"] = {
                    ["SunDir"] = Vector(0, 0, -1),
                }
            }

        function ULK3D.NewUniverse(tag)
            creates a new universe with tag tag
        
        function  ULK3D.PushUniverse(table univ)
            pushes a universe into the stack
        
        function ULK3D.PopUniverse()
            pops a universe from the stack, returns the popped universe

        function ULK3D.GetCurrentUniverse()
            returns the current universe from the stack

        function  ULK3D.ClearUniverse(univ?)
            clears a universe, making it brand new while preserving table pointer, defaults to current pushed one if not given

        function ULK3D.GetUniverseByTag(tag)
            returns a universe by tag or nil if not existant

        function ULK3D.GetUniverseParams(univ)
            returns the parameters of the universe by a given universe or the currently pushed one if not given
]]--

function ULK3D.NewUniverse(tag)
    return FLK3D.NewUniverse(tag)
end

function ULK3D.PushUniverse(univ)
    FLK3D.PushUniverse(univ)
end

function ULK3D.PopUniverse()
    return FLK3D.PopUniverse()
end

function ULK3D.GetCurrentUniverse()
    return FLK3D.CurrUniv
end

function ULK3D.ClearUniverse(univ)
    return FLK3D.ClearUniverse(univ)
end

function ULK3D.GetUniverseByTag(tag)
    return FLK3D.GetUniverseByTag(tag)
end

function ULK3D.GetUniverseParams(univ)
    return FLK3D.GetUniverseParams(univ)
end


--[[
    Objects:
        table object = {
            mdl = "model",
            pos = Vector(0, 0, 0),
            ang = Angle(0, 0, 0),
            scl = Vector(1, 1, 1),
            col = {1, 1, 1},
            tex = "none",
            -- matrices are optional and only necessary if the renderer needs them
        }

        function ULK3D.NewObject(tag, mdl)
            creates a new object with name tag and model mdl on current universe

        function ULK3D.SetObjectPos(tag, pos)
            sets the pos for the object tag

        function ULK3D.SetObjectAng(tag, ang)
            sets the ang for the object tag

        function ULK3D.SetObjectPosAng(tag, pos, ang)
            sets the pos and the ang for the object tag

        function ULK3D.SetObjectScl(tag, scl)
            sets the scale for the object tag

        function ULK3D.SetObjectCol(tag, col)
            sets the colour for the object tag

        function ULK3D.SetObjectTex(tag, tex)
            sets the texture for the object tag
        
        function ULK3D.SetObjectFlag(tag, flag, val)
            sets the flag flag to the value val on the object tag
]]--

function ULK3D.NewObject(tag, mdl)
    FLK3D.AddObjectToUniv(tag, mdl)
end

function ULK3D.SetObjectPos(tag, pos)
    FLK3D.SetObjectPos(tag, pos)
end

function ULK3D.SetObjectAng(tag, ang)
    FLK3D.SetObjectAng(tag, ang)
end

function ULK3D.SetObjectPosAng(tag, pos, ang)
    FLK3D.SetObjectPosAng(tag, pos, ang)
end

function ULK3D.SetObjectScl(tag, scl)
    FLK3D.SetObjectScl(tag, scl)
end

function ULK3D.SetObjectCol(tag, col)
    FLK3D.SetObjectCol(tag, col)
end

function ULK3D.SetObjectTex(tag, tex)
    FLK3D.SetObjectMat(tag, tex)
end

function ULK3D.SetObjectFlag(tag, flag, val)
    FLK3D.SetObjectFlag(tag, flag, val)
end


--[[
    RenderTargets

    function ULK3D.NewRenderTarget(tag, w, h)
        creates a rendertarget with name tag of size w, h and returns it
    
    function ULK3D.PushRenderTarget(rt)
        pushes a rendertarget onto the rendertarget stack

    function ULK3D.PopRenderTarget()
        pops a rendertarget from the rendertarget stack

    function ULK3D.GetCurrentRenderTarget()
        returns the current rendertarget from the stack

    function ULK3D.Clear(r, g, b, depth)
        clears the rendertarget with the colour r, g, b and depth, defaults to 0, 0, 0, true

]]--


function ULK3D.NewRenderTarget(tag, w, h)
    return FLK3D.NewRenderTarget(tag, w, h)
end

function ULK3D.PushRenderTarget(rt)
    FLK3D.PushRenderTarget(rt)
end

function ULK3D.PopRenderTarget()
    FLK3D.PopRenderTarget()
end

function ULK3D.GetCurrentRenderTarget()
    return FLK3D.CurrRT
end

function ULK3D.Clear(r, g, b, depth)
    FLK3D.Clear(r or 0, g or 0, b or 0, depth or true)
end

--[[
    Basic TextureUtils

    function ULK3D.NewTexture(tag, w, h, func?)
        creates a new texture with name tag of size w, h with optional drawing func, otherwise it should clear to black
]]--

function ULK3D.NewTexture(tag, w, h, func)
    LKTEX.Generate(tag, w, h, func)
end