FLK3D = FLK3D or {}

local function math_round(x)
	local dec = x - math.floor(x)
	if dec > .5 then
		return math.ceil(x)
	else
		return math.floor(x)
	end
end



function FLK3D.RenderPixel(x, y, cont)
	local rt = FLK3D.CurrRT
	local rtParams = rt._params
	local rtW, rtH = rtParams.w, rtParams.h

	rt[x + (y * rtW)] = cont

end


local function lineLow(x1, y1, x2, y2, cont, w, h, rt)
	local dx = x2 - x1
	local dy = y2 - y1
	local yi = 1
	if dy < 0 then
		yi = -1
		dy = -dy
	end

	local D = (2 * dy) - dx
	local y = y1

	for x = x1, x2 do
		rt[x + (y * w)] = cont

		if D > 0 then
			y = y + yi
			D = D + (2 * (dy - dx))
		else
			D = D + 2 * dy
		end
	end
end

local function lineHigh(x1, y1, x2, y2, cont, w, h, rt)
	local dx = x2 - x1
	local dy = y2 - y1
	local xi = 1
	if dx < 0 then
		xi = -1
		dx = -dx
	end
	local D = (2 * dx) - dy
	local x = x1

	for y = y1, y2 do
		rt[x + (y * w)] = cont

		if D > 0 then
			x = x + xi
			D = D + (2 * (dx - dy))
		else
			D = D + 2 * dx
		end
	end
end


-- https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
function FLK3D.RenderLine(x1, y1, x2, y2, cont)
	local rt = FLK3D.CurrRT
	local rtParams = rt._params
	local rtW, rtH = rtParams.w, rtParams.h


	if math.abs(y2 - y1) < math.abs(x2 - x1) then
		if x1 > x2 then
			lineLow(x2, y2, x1, y1, cont, rtW, rtH, rt)
		else
			lineLow(x1, y1, x2, y2, cont, rtW, rtH, rt)
		end
	else
		if y1 > y2 then
			lineHigh(x2, y2, x1, y1, cont, rtW, rtH, rt)
		else
			lineHigh(x1, y1, x2, y2, cont, rtW, rtH, rt)
		end
	end

	if love and _LKPXDEBUG then
		FLK3D.LOVE_DEBUG_BUFF[#FLK3D.LOVE_DEBUG_BUFF + 1] = {
			type = "line",
			start = {x1, y1},
			endpos = {x2, y2},
			col = cont
		}
	end
end


local function edgeFunction(x0, y0, x1, y1, x2, y2)
	return (x2 - x0) * (y1 - y0) - (y2 - y0) * (x1 - x0)
end




local function baryCentric(px, py, ax, ay, bx, by, cx, cy)
	local v0 = Vector(bx - ax, by - ay)
	local v1 = Vector(cx - ax, cy - ay)
	local v2 = Vector(px - ax, py - ay)

	local d00 = v0:Dot(v0)
	local d01 = v0:Dot(v1)
	local d11 = v1:Dot(v1)
	local d20 = v2:Dot(v0)
	local d21 = v2:Dot(v1)

	local denom = d00 * d11 - d01 * d01
	local v = (d11 * d20 - d01 * d21) / denom
	local w = (d00 * d21 - d01 * d20) / denom
	local u = 1 - v - w

	return v, w, u
end

local _tmpSwap = 0
local function fast_horzline(sx, ex, y, cont, rt, rtW, rtH, vx0, vy0, vx1, vy1, vx2, vy2, dbuff, d0, d1, d2)
	if sx > ex then
		_tmpSwap = sx
		sx = ex
		ex = _tmpSwap
	end

	if ex > rtW - 1 then
		ex = rtW - 1
	end

	if sx < 0 then
		sx = 0
	end

	if y >= rtH then
		return
	end

	if y < 0 then
		return
	end

	for x = sx, ex do
		--local area = edgeFunction(vx0, vy0, vx1, vy1, vx2, vy2)

		--local w0 = edgeFunction(vx1, vy1, vx2, vy2, x, y) / area
		--local w1 = edgeFunction(vx2, vy2, vx0, vy0, x, y) / area
		--local w2 = edgeFunction(vx0, vy0, vx1, vy1, x, y) / area

		local w1, w2, w0 = baryCentric(x, y, vx0, vy0, vx1, vy1, vx2, vy2)


		local col = {w0 * 255, w1 * 255, w2 * 255}
		local dCalc = -((w0 * d0) + (w1 * d1) + (w2 * d2))
		local prev = dbuff[x + (y * rtW)]

		if (dCalc < prev) then
			local dCol = dCalc * 32
			rt[x + (y * rtW)] = {dCol, dCol, dCol}
			dbuff[x + (y * rtW)] = dCalc
		elseif dCalc ~= dCalc then
			dbuff[x + (y * rtW)] = math.huge
			rt[x + (y * rtW)] = {255, 0, 0}
		end
	end
end


local _whileCount = 32
local function flatside_simple(x0, y0, x1, y1, x2, y2, cont, rx0, ry0, rx1, ry1, rx2, ry2, d0, d1, d2)
	local rt = FLK3D.CurrRT
	local rtParams = rt._params
	local rtW, rtH = rtParams.w, rtParams.h

	local dbuff = rt._depth

	local vTmp1x, vTmp1y = x0, y0
	local vTmp2x, vTmp2y = x0, y0


	local changed1 = false
	local changed2 = false

	local dx1 = math.abs(x1 - x0)
	local dy1 = math.abs(y1 - y0)

	local dx2 = math.abs(x2 - x0)
	local dy2 = math.abs(y2 - y0)


	local sx1 = (x1 - x0) > 0 and 1 or -1
	local sy1 = (y1 - y0) > 0 and 1 or -1

	local sx2 = (x2 - x0) > 0 and 1 or -1
	local sy2 = (y2 - y0) > 0 and 1 or -1


	if (dy1 > dx1) then
		_tmpSwap = dx1
		dx1 = dy1
		dy1 = _tmpSwap
		changed1 = true
	end

	if (dy2 > dx2) then
		_tmpSwap = dx2
		dx2 = dy2
		dy2 = _tmpSwap
		changed2 = true
	end

	local e1 = 2 * dy1 - dx1
	local e2 = 2 * dy2 - dx2


	for i = 0, dx1 do
		fast_horzline(vTmp1x, vTmp2x, vTmp1y, cont, rt, rtW, rtH, rx0, ry0, rx1, ry1, rx2, ry2, dbuff, d0, d1, d2)

		for _ = 1, _whileCount do
			if e1 < 0 then
				break
			end
			if changed1 then
				vTmp1x = vTmp1x + sx1
			else
				vTmp1y = vTmp1y + sy1
			end

			e1 = e1 - 2 * dx1
		end

		if (changed1) then
			vTmp1y = vTmp1y + sy1
		else
			vTmp1x = vTmp1x + sx1
		end

		e1 = e1 + 2 * dy1

		for _ = 1, _whileCount do
			if vTmp2y == vTmp1y then
				break
			end


			for _ = 1, _whileCount do
				if e2 < 0 then
					break
				end

				if changed2 then
					vTmp2x = vTmp2x + sx2
				else
					vTmp2y = vTmp2y + sy2
				end

				e2 = e2 - 2 * dx2
			end


			if changed2 then
				vTmp2y = vTmp2y + sy2
			else
				vTmp2x = vTmp2x + sx2
			end

			e2 = e2 + 2 * dy2
		end
	end
end



local temp_xsort = 0
local temp_ysort = 0
function FLK3D.RenderTriangleSimple(x0, y0, x1, y1, x2, y2, cont, d0, d1, d2)
	local ox0, oy0 = x0, y0
	local ox1, oy1 = x1, y1
	local ox2, oy2 = x2, y2

	x0 = math_round(x0)
	y0 = math_round(y0)
	x1 = math_round(x1)
	y1 = math_round(y1)
	x2 = math_round(x2)
	y2 = math_round(y2)

	-- sort by y, x0, y0 should be top
	if y0 > y1 then
		temp_xsort = x0
		temp_ysort = y0
		x0 = x1
		y0 = y1

		x1 = temp_xsort
		y1 = temp_ysort
	end

	if y0 > y2 then
		temp_xsort = x0
		temp_ysort = y0
		x0 = x2
		y0 = y2

		x2 = temp_xsort
		y2 = temp_ysort
	end

	if y1 > y2 then
		temp_xsort = x1
		temp_ysort = y1
		x1 = x2
		y1 = y2

		x2 = temp_xsort
		y2 = temp_ysort
	end


	if y1 == y2 then
		flatside_simple(x0, y0, x1, y1, x2, y2, cont, ox0, oy0, ox1, oy1, ox2, oy2, d0, d1, d2)
	elseif y0 == y1 then
		flatside_simple(x2, y2, x1, y1, x0, y0, cont, ox0, oy0, ox1, oy1, ox2, oy2, d0, d1, d2)
	else

		local x3 = math_round(x0 + ((y1 - y0) / (y2 - y0)) * (x2 - x0))
		local y3 = math_round(y1)

		flatside_simple(x0, y0, x1, y1, x3, y3, cont, ox0, oy0, ox1, oy1, ox2, oy2, d0, d1, d2)
		flatside_simple(x2, y2, x1, y1, x3, y3, cont, ox0, oy0, ox1, oy1, ox2, oy2, d0, d1, d2)
	end


	if love and _LKPXDEBUG then
		FLK3D.LOVE_DEBUG_BUFF[#FLK3D.LOVE_DEBUG_BUFF + 1] = {
			type = "triangle",
			v1 = {x1, y1},
			v2 = {x2, y2},
			v3 = {x3, y3},
			col = cont
		}
	end
end