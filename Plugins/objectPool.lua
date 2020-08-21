local M = {}

local globalObjectPool    = {}
local localObjectPool     = {}
local unobjectPooledCount = {}
local helperGroup     = display.newGroup()

local addObjectInfo
if _G.DEBUG.OBJECT_POOL_DATA then
  local showArea
  local objects = {}
  local textY   = 1

  showArea = display.newGroup()
  showArea.x = 3
  showArea.y = screen.originY+3
  local background = display.newRect(showArea,0,0,60,0);
  background:setFillColor(0)
  background.alpha   = 0.6
  background.anchorX = 0
  background.anchorY = 0
  addObjectInfo = function(objectName, used, total)
    local spaces = ""
    for i=1,17-#objectName < 0 and 0 or 17-#objectName do
      spaces = spaces.." "
    end

    if objects[objectName] then
      objects[objectName].text = string.format("%s"..spaces.."%d/%d", objectName, used, total)
    else
      local text = display.newText(showArea, "", 2,textY, "Courier", 7)
      text.text = string.format("%s"..spaces.."%d/%d", objectName, used, total)
      text.anchorX = 0
      text.anchorY = 0
      objects[objectName] = text
      textY = textY + 8
      background.height = textY+3
      background.width = math.max(background.width, text.width + 8)
    end
  end

  timer.performWithDelay( 1000, function() showArea:toFront() end)
end


local function dispose(self)
  if self.__used then
    self.__used = false
    self.__objectPool.used = self.__objectPool.used - 1
    if addObjectInfo then addObjectInfo(self.__objectPool.name, self.__objectPool.used, self.__objectPool.count) end
  end
  if self.setVisibility then self:setVisibility(0)
  else                       self.isVisible = false end
  if self.group then
    helperGroup:insert(self.group)
  elseif self.removeSelf then
    helperGroup:insert(self)
  end
end


function M.registerWithFactory(name, count, factory, isGlobal)
  local objectPool = localObjectPool
  if isGlobal then objectPool = globalObjectPool end
  if objectPool[name] then
    local objObjectPool = objectPool[name]
    local data = objObjectPool.data
    if objObjectPool.count <= count then
      for i=1, count-objObjectPool.count do
        local item = objObjectPool.factory()
        item.__objectPool = objObjectPool
        item.dispose = dispose
        item:dispose()
        data[objObjectPool.count+i] = item
      end
      objObjectPool.count = count
    else
      local i = objObjectPool.count
      local deleteCount = objObjectPool.count-math.max(objObjectPool.used, count)
      objObjectPool.count = objObjectPool.count-deleteCount
      while deleteCount > 0 do
        local item = data[i]
        if not item.__used then

          if     item.removeSelf                      then item:removeSelf()
          elseif item.group and item.group.removeSelf then item.group:removeSelf()
          else                         error( "Attempt to call remove self on objectPooled item: "..item )
          end
          item = nil
          data:remove(i)
          deleteCount = deleteCount-1
        end
        i = i-1
      end
    end
    if addObjectInfo then addObjectInfo(name, objObjectPool.used, objObjectPool.count) end
  else
    objectPool[name] = {
      count        = count,
      used         = 0,
      data         = List.new(),
      factory      = factory,
      name         = name
    }
    local data = objectPool[name].data
    for i=1, count do
      local item = factory()
      item.__objectPool = objectPool[name]
      item.dispose = dispose
      item:dispose()
      data[i] = item
    end
    objectPool[name].used = 0
    if addObjectInfo then addObjectInfo(name, 0, count) end
  end
end


function M.registerSprite(name, count, sheet, sequenceData, isGlobal)
  M.registerWithFactory(name, count, function()
      return display.newSprite(sheet, sequenceData)
  end, isGlobal)
end


function M.registerImage(name, count, path, isGlobal)
  M.registerWithFactory(name, count, function()
      return display.newImage(path)
  end, isGlobal)
end


function M.registerImageRect(name, count, path, width, height, isGlobal)
  M.registerWithFactory(name, count, function()
      return display.newImageRect(path, width, height)
  end, isGlobal)
end


local function newItem(item, count, i)
  local messageHeight = 20
  local transitionTime = 0
  local showTime = 5000
  local message = display.newGroup()
  local background = display.newRect(message, 0,0,100,20)
  background:setFillColor(0, 0, 0, .4)

  local messageText = display.newText(message, "ObjectPooling - "..item.." - "..count, 0, 0,
      "adam warren 0.2", 6)
  messageText:setTextColor(1)

  background.width = messageText.width + 20

  message.x = screen.edgeX - 65
  message.y = screen.edgeY - 20 - i*22

  transition.from(message,{
    time  = transitionTime,
    alpha = 0
  })

  transition.to(message,{
    delay      = transitionTime+showTime,
    time       = transitionTime,
    alpha      = 0,
    onComplete = function()
      message:removeSelf()
    end
  })
end

if _G.DEBUG.OBJECT_POOL then
  local prevTime = system.getTimer()
  local count = 0

  function M.enterFrame()
    local time = system.getTimer()

    local total = 0
    for _,count in pairs(unobjectPooledCount) do
      total = total + count
    end

    if total == 0 then
      prevTime = time
    else
      if time - prevTime > 5000 then
        prevTime = time
        local i = 0
        for item,count in pairs(unobjectPooledCount) do
          if count > 0 then
            newItem(item, count, i)
            i = i+1
            unobjectPooledCount[item] = 0
          end
        end
      end
    end
  end

  Runtime:addEventListener("enterFrame", M)
end

function M.getObject(name)
  local objectPool
  if localObjectPool[name] then
    objectPool = localObjectPool[name]
  elseif globalObjectPool[name] then
    objectPool = globalObjectPool[name]
  else
    error("item "..name.." doesn't exist")
  end
  if objectPool then
    if objectPool.used < objectPool.count then
      local data = objectPool.data
      for i=1,objectPool.count do
        if not data[i].__used then
          local item = data[i]
          item.__used = true

          if   item.setVisibility then item:setVisibility(1)
          else                         item.isVisible = true
          end

          objectPool.used = objectPool.used + 1
          if addObjectInfo then addObjectInfo(name, objectPool.used, objectPool.count) end
          return item
        end
      end
    else
      if not unobjectPooledCount[name] then unobjectPooledCount[name] = 0 end
      unobjectPooledCount[name] = unobjectPooledCount[name]+1
      print("======================================")
      print("new item -"..name.."- required, Count: "..unobjectPooledCount[name])
      print("======================================")
      local data = objectPool.data
      local item = objectPool.factory()
      item.__objectPool = objectPool
      item.dispose = dispose
      item.__used = true

      if item.setVisibility then item:setVisibility(1)
      else                       item.isVisible = true
      end

      data[#data+1] = item
      objectPool.count = objectPool.count + 1
      objectPool.used = objectPool.count
      if addObjectInfo then addObjectInfo(name, objectPool.used, objectPool.count) end

      return item
    end
  end
end


function M.cleanLocal()
  for _,objectPool in pairs(localObjectPool) do
    local data = objectPool.data
    for i=objectPool.count, 1, -1 do
      if data[i] then
        if data[i].removeSelf then data[i]:removeSelf()
        elseif data[i].group and data[i].group.removeSelf then data[i].group:removeSelf() end
        data[i] = nil
      end
    end
  end
  localObjectPool = {}
end


function M.cleanGlobal()
  for _,objectPool in pairs(globalObjectPool) do
    local data = objectPool.data
    for i=objectPool.count, 1, -1 do
      if data[i] then
        if data[i].removeSelf then data[i]:removeSelf()
        elseif data[i].group and data[i].group.removeSelf then data[i].group:removeSelf() end
        data[i] = nil
      end
    end
  end
  localObjectPool = {}
end


function M.getObjectCount()
  print("--------- BUFFER COUNT ---------")
  for obj,data in pairs(globalObjectPool) do
    print(" - "..obj..": ", data.used)
  end
  print("--------------------------------")
end


return M
