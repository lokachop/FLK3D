--[[
    lktex.lua
    
    lokachop's texture library
    licensed under the MIT license (refer to LICENSE)
]]--

LKTEX = LKTEX or {}
LKTEX.Textures = LKTEX.Textures or {}

-- for cc
local _COMPUTERCRAFT = false

local function readByte(fileObject)
    if _COMPUTERCRAFT then
        -- todo: support computercraft on this
    else
        return string.byte(fileObject:read(1))
    end
end

local string_byte = string.byte
local bit_band = bit.band
local function readTripleBytes(fileObject)
    if _COMPUTERCRAFT then
        -- todo: support computercraft on this
    else
        local rv = fileObject:read(3)
        local v1 = bit_band(string_byte(rv, 1), 0xFF)
        local v2 = bit_band(string_byte(rv, 2), 0xFF)
        local v3 = bit_band(string_byte(rv, 3), 0xFF)

        return v1, v2, v3
    end
end

local function closeFile(fileObject)
    if _COMPUTERCRAFT then
        fileObject.close()
    else
        fileObject:close()
    end
end

local function readAndGetFileObject(path)
    if _COMPUTERCRAFT then
        local f = fs.open(path, "rb")
        return f
    else
        local f = love.filesystem.newFile(path)
        f:open("r")
        return f
    end
end

local function readString(fileObject)
    -- read the 0A (10)
    local readCont = readByte(fileObject)
    if readCont ~= 10 then
        return "nostring :("
    end

    local buff = {}
    for i = 1, 4096 do -- read long strings
        readCont = readByte(fileObject)
        if readCont == 10 then
            break
        end

        buff[#buff + 1] = string.char(readCont)
    end

    return table.concat(buff, "")
end

local function readUntil(fileObject, stopNum)
    local readCont
    local buff = {}
    for i = 1, 2048 do -- read big nums
        readCont = readByte(fileObject)
        if readCont == stopNum then
            break
        end

        buff[#buff + 1] = string.char(readCont)
    end
    return table.concat(buff, "")
end

-- ppm files are header + raw data which is EZ
function LKTEX.LoadPPM(name, path)
    local data = {}

    print("---LKTEX-PPMLoad---")
    print("Loading texture at \"" .. path .. "\"")


    local fObj = readAndGetFileObject(path)
    local readCont = readByte(fObj)
    if readCont ~= 80 then
        closeFile(fObj)
        error("PPM Decode error! (header no match!) [" .. readCont .. "]")
        return
    end

    readCont = readByte(fObj)
    if readCont ~= 54 then
        closeFile(fObj)
        error("PPM Decode error! (header no match!) [" .. readCont .. "]")
        return
    end
    readCont = readByte(fObj)
    -- string, read until next 10
    if readCont == 10 then
        local fComm = readUntil(fObj, 10)
        print("Comment; \"" .. fComm .. "\"")
    end

    -- read the width and height
    local w = tonumber(readUntil(fObj, 32))
    local h = tonumber(readUntil(fObj, 10))

    local cDepth = tonumber(readUntil(fObj, 10))
    print("Texture is " .. w .. "x" .. h .. " with a coldepth of " .. cDepth)

    local pixToRead = w * h
    for i = 0, (pixToRead - 1) do
        --local r = readByte(fObj)
        --local g = readByte(fObj)
        --local b = readByte(fObj)

        local r, g, b = readTripleBytes(fObj)

        data[i] = {r, g, b}
    end

    data.data = {w, h}

    closeFile(fObj)
    LKTEX.Textures[name] = data
end


LKTEX.LoadPPM("loka",       "textures/loka.ppm")
LKTEX.LoadPPM("jelly",      "textures/jelly.ppm")
LKTEX.LoadPPM("jet",        "textures/jet.ppm")
LKTEX.LoadPPM("mandrill",   "textures/mandrill.ppm")
LKTEX.LoadPPM("none",       "textures/loka.ppm")

LKTEX.LoadPPM("loka_sheet",         "textures/loka_sheet.ppm")
LKTEX.LoadPPM("train_sheet",        "textures/train_sheet.ppm")
LKTEX.LoadPPM("traintrack_sheet",   "textures/traintrack_sheet.ppm")
LKTEX.LoadPPM("cubemap",            "textures/cubemap_lq.ppm")

LKTEX.LoadPPM("vehicle_apc_hull",            "textures/vehicle_apc/vehicleHull.ppm")
LKTEX.LoadPPM("vehicle_apc_turret",            "textures/vehicle_apc/vehicleTurret.ppm")
LKTEX.LoadPPM("vehicle_apc_turret_cannon",            "textures/vehicle_apc/vehicleTurretCannon.ppm")
LKTEX.LoadPPM("vehicle_apc_wheel",            "textures/vehicle_apc/vehicleWheel.ppm")


function LKTEX.GetTexture(name)
    local tex = LKTEX.Textures[name]
    if not tex then
        return LKTEX.Textures["none"]
    end

    return tex
end

function LKTEX.GenerateEmpty(name, w, h, col)
    local data = {}
    data.data = {w, h}

    for i = 0, ((w * h) - 1) do
        data[i] = col or {255, 255, 255}
    end
    LKTEX.Textures[name] = data
end

function LKTEX.GenerateFunc(name, w, h, func)
    local data = {}
    data.data = {w, h}

    for i = 0, ((w * h) - 1) do
        local xc = i % w
        local yc = math.floor(i / w)
        local fine, dataFunc = pcall(func, xc, yc)
        if not fine then
            print("TextureInit error!;" .. dataFunc)
            dataFunc = {255, 255, 0}
        end

        data[i] = dataFunc
    end
    LKTEX.Textures[name] = data
end

function LKTEX.Generate(name, w, h, func)
    if func then
        LKTEX.GenerateFunc(name, w, h, func)
    else
        LKTEX.GenerateEmpty(name, w, h, {51, 0, 153})
    end
end


function LKTEX.ClearTexture(name, data)
    for i = 0, ((w * h) - 1) do
        LKTEX.Textures[name][i] = data
    end
end

LKTEX.GenerateEmpty("white", 16, 16, {255, 255, 255})
LKTEX.GenerateEmpty("indigo", 2, 2, {51, 0, 153})


LKTEX.GenerateEmpty("red1", 2, 2, {196, 96, 96})
LKTEX.GenerateEmpty("red2", 2, 2, {128, 64, 64})