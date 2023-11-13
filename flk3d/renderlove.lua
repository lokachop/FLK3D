FLK3D = FLK3D or {}
FLK3D.LOVE_DEBUG_BUFF = {}


local _scl = 3
local scrW, scrH = love.graphics.getDimensions()
function FLK3D.RenderRTToScreen()
    -- renders magnified
    local rt = FLK3D.CurrRT
    local rtParams = rt._params
    local rtW, rtH = rtParams.w, rtParams.h

    if not rt.lv_imgdat then
        rt.lv_imgdat = love.image.newImageData(rtW, rtH)
        rt.lv_img = love.graphics.newImage(rt.lv_imgdat)
        rt.lv_img:setFilter("nearest", "nearest", 0)

    end


    for i = 0, (rtW * rtH) - 1 do
        local xc = (i % rtW)
        local yc = math.floor(i / rtW)

        local cont = rt[i]
        rt.lv_imgdat:setPixel(xc, yc, cont[1] / 255, cont[2] / 255, cont[3] / 255)

        --love.graphics.setColor(cont[1] / 255, cont[2] / 255, cont[3] / 255)
        --love.graphics.rectangle("fill", realX, realY, _scl, _scl)
    end


    rt.lv_img:replacePixels(rt.lv_imgdat)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setColor(1, 1, 1, 1)

    local cX = (scrW * .5) - ((rtW * .5) * _scl)
    local cY = (scrH * .5) - ((rtH * .5) * _scl)

    love.graphics.draw(rt.lv_img, cX, cY, 0, _scl, _scl)

    love.graphics.setBlendMode("alpha")
end


local renderDebugMag = 1
local padDebug = 2

local _scaleVar = renderDebugMag + padDebug
local _scaleVarH = (renderDebugMag + padDebug) * .5
local typeHandlersDebug = {
    ["line"] = function(dat, rtW, rtH)
        local startPos = dat.start
        startPos[1] = startPos[1] + .5
        startPos[2] = startPos[2] + .5

        local endPos = dat.endpos
        endPos[1] = endPos[1] + .5
        endPos[2] = endPos[2] + .5

        local scaledStart = {startPos[1] * _scaleVar + padDebug, startPos[2] * _scaleVar + padDebug}
        local scaledEnd = {endPos[1] * _scaleVar + padDebug, endPos[2] * _scaleVar + padDebug}

        local colDat = dat.col
        local loveCol = {colDat[1] / 255, colDat[2] / 255, colDat[3] / 255}

        love.graphics.setColor(loveCol[1], loveCol[2], loveCol[3])
        love.graphics.setLineWidth(1)
        love.graphics.line(scaledStart[1], scaledStart[2], scaledEnd[1], scaledEnd[2])


        love.graphics.setColor(loveCol[1] * .75, loveCol[2] * .75, loveCol[3] * .75)

        love.graphics.circle("fill", scaledStart[1], scaledStart[2], 4)
        love.graphics.circle("fill", scaledEnd[1], scaledEnd[2], 4)
    end,

    ["triangle"] = function(dat, rtW, rtH)

    end
}

local mulSee = .75
local pRad = 2
function FLK3D.RenderRTToScreenDebug()
    -- renders magnified
    local rtParams = FLK3D.CurrRT._params
    local rtW, rtH = rtParams.w, rtParams.h


    for i = 0, (rtW * rtH) - 1 do
        local realX = (i % rtW) * _scaleVar + padDebug
        local realY = math.floor(i / rtW) * _scaleVar + padDebug

        local cont = FLK3D.CurrRT[i]

        local contLove = {cont[1] / 255, cont[2] / 255, cont[3] / 255}
        local contLoveSat = {math.min(cont[1] * mulSee, 255) / 255, math.min(cont[2] * mulSee, 255) / 255, math.min(cont[3] * mulSee, 255) / 255}


        love.graphics.setColor(contLove[1], contLove[2], contLove[3])
        love.graphics.rectangle("fill", realX, realY, renderDebugMag, renderDebugMag)

        love.graphics.setColor(contLoveSat[1], contLoveSat[2], contLoveSat[3])
        love.graphics.circle("fill", realX + _scaleVarH, realY + _scaleVarH, pRad)
    end


    for k, v in ipairs(FLK3D.LOVE_DEBUG_BUFF) do
        if not typeHandlersDebug[v.type] then
            error("no debug handler for \"" .. v.type .. "\"")
        end

        typeHandlersDebug[v.type](v, rtW, rtH)

    end

    FLK3D.LOVE_DEBUG_BUFF = {}
end