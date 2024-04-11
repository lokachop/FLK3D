--[[                                                    
Fast Physics Solver

MIT License

Copyright (c) 2024 Dice

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local fps={
	version="0.0.7"
}

-------------------------------------------------------------------------------

fps.vector3  = require(FLK3D.FPSPath .. "modules.vector3")(fps)
fps.matrix3  = require(FLK3D.FPSPath .. "modules.matrix3")(fps)
fps.matrix4  = require(FLK3D.FPSPath .. "modules.matrix4")(fps)
fps.raycast  = require(FLK3D.FPSPath .. "modules.raycast")(fps)
fps.ngc      = require(FLK3D.FPSPath .. "modules.ngc")(fps)
fps.shape    = require(FLK3D.FPSPath .. "modules.shape")(fps)
fps.collider = require(FLK3D.FPSPath .. "modules.collider")(fps)
fps.body     = require(FLK3D.FPSPath .. "modules.body")(fps)
fps.world    = require(FLK3D.FPSPath .. "modules.world")(fps)

fps.solvers={
	rigid = require(FLK3D.FPSPath .. "solvers.rigid")(fps)
}

-------------------------------------------------------------------------------

return fps