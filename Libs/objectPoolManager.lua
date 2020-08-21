local setups = {
  basic      = require("Assets.Story.ObjectPool.basic"),
}


local ObjectPool = require("Plugins.objectPool")

local M = {}

local factory = {

  -- myObject      = "Assets.Entities.Animated.myObject",
  -- myOtherObject = = function() return display.newImageRect("Assets/Entities/Effects/Particles/small_chunk.png", 3, 3) end,

}

-- Implementation ------------------------------------------------------------------------------------------------------

local registeredObjects = {}
local type    = type
local require = require

local function getFactory(obj)
  local f = factory[obj]
  if type(f) == "string" then
    f = require(f)
  end

  return f
end


function M.load(setup)
  local time = system.getTimer()
  print("----------------- LOADING SETUP -----------------")
  M.objectPool(setups[setup])
  print("-------------- BUFFER SETUP LOADED --------------")
  print("setup: "..setup)
  print("time: "..system.getTimer()-time)
  print("-------------------------------------------------")
end


function M.objectPool(objects)
  for obj,count in pairs(objects) do
    ObjectPool.registerWithFactory(obj, count, getFactory(obj), true)
    registeredObjects[obj] = true
  end
end


function M.getObject(object)
  if not registeredObjects[object] then
    -- print("obj", object)
    ObjectPool.registerWithFactory(object, 1, getFactory(object), true)
    registeredObjects[object] = true
  end
  return ObjectPool.getObject(object)
end


return M
