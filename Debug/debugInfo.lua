-- Debug info ------------------------------------------------------------------
local functionCalls = 0
local ptime = 0
local frames = 0
local fpsMax = 0
local fpsMin = 10000
local profWidth = 140
local profGroup = display.newGroup()
profGroup.x = screen.edgeX - profWidth
profGroup.y = screen.originY
local profBack = display.newRect(profGroup,0,0,profWidth,50)
profBack.anchorX = 0
profBack.anchorY = 0
profBack.alpha = 0.5
profBack:setFillColor(0)
local memtext = display.newText(profGroup, "", 3, 10, native.systemFont, 10)
memtext.anchorX = 0
memtext:setTextColor(1)

local fcltext = display.newText(profGroup, "", 3, 20, native.systemFont, 10)
fcltext.anchorX = 0
fcltext:setTextColor(1)

local fpstext = display.newText(profGroup, "", 3, 30, native.systemFont, 10)
fpstext.anchorX = 0
fpstext:setTextColor(1)

local doctext = display.newText(profGroup, "", 3, 40, native.systemFont, 10)
doctext.anchorX = 0
doctext:setTextColor(1)

local function hook()
  functionCalls = functionCalls + 1
end

debug.sethook(hook, "c")

profBack:addEventListener("tap", function()
  collectgarbage()
  fpsMax = 0
  fpsMin = 100
end )

Runtime:addEventListener("enterFrame", function()
  local time = system.getTimer()
  local dTime = time - ptime
  frames = frames + 1
  if dTime > 1000 then
    local sysmem = collectgarbage("count")/1024
    local texmem = system.getInfo( "textureMemoryUsed" )/1024/1024
    local fps = frames/dTime*1000
    local cps = functionCalls/dTime
    if fps > fpsMax then fpsMax = fps end
    if fps < fpsMin then fpsMin = fps end
    fcltext.text = string.format("Calls/ms: %.00f", cps)
    memtext.text = string.format("Memory: %.00f (%.00f/%.00f) MB",sysmem+texmem,sysmem,texmem)
    fpstext.text = string.format("FPS: %.f %.f/%.f",fps, fpsMin, fpsMax)
    functionCalls = 0
    frames = 0
    ptime = time

    local count = 0
    local stack = {display.currentStage}
    local stackIndex = 1

    while stackIndex > 0 do
      local cur = stack[stackIndex]
      local curChilNum = cur.numChildren
      stackIndex = stackIndex - 1
      count = count + curChilNum
      if curChilNum > 0 then
        for i=1,curChilNum do
          local child = cur[i]
          if child.numChildren then
            stackIndex = stackIndex + 1
            stack[stackIndex] = child
          end
        end
      end
    end
		doctext.text = string.format("DO count: %d", count)
  end
end)
