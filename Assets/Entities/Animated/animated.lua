local Entity  = require("Assets.Entities.Animated.entity")

local time = _G.game.time

-- ---------------------------------------------------------------------------------------------------------------------
-- Animated object --
-- ---------------------------------------------------------------------------------------------------------------------
local Animated = Class("animated", Entity)

-- Initialization ------------------------------------------------------------------------------------------------------

function Animated:create(stateObject)
  Entity.create(self, stateObject)

  self._animation = self.__animationFile:new(self.group, self.__animationParams)
end


function Animated:setController(controller)
  if self._controller then
    self._controller:clear()
  end

  self._controller = controller and require(self.__controllers[controller]):new(self)
end


function Animated:_canGotoState(state)
  error("unknown state "..(state or "nil").." for "..self.class.name)
end


function Animated:gotoState(state, params)
  if not self:_canGotoState(state) then return false end

  local data = self._state
  local exitState = "_exit"..(data:getValue("state") or ""):capitalize().."State"
  if self[exitState] then
    self[exitState](self)
  end

  data:setValue("state", state)

  local enterState = "_entry"..(state or ""):capitalize().."State"
  if self[enterState] then
    self[enterState](self, params)
  end

  return true
end


function Animated:start()
  time.addPausable(self)
  time.subscribe(self)

  if self._animation.start        then self._animation:start() end
  if self._animation.setTimeScale then time.addScalable(self._animation) end
  if self._controller             then self._controller:start() end
end


function Animated:enterFrame(timeElapsed, total)
  Entity.enterFrame(self, timeElapsed, total)
  if self._controller then self._controller:enterFrame(timeElapsed, total) end
end


function Animated:resume()
  Entity.resume(self)
  self._animation:resume()
end


function Animated:pause()
  Entity.pause(self)
  self._animation:pause()
end


function Animated:stop()
  Entity.stop(self)
  time.unsubscribe(self)
  time.removePausable(self)
  self._animation:stop()
end


function Animated:reset()
  Entity.reset(self)

  self._animation:reset()
end


function Animated:hardReset()
  Entity.hardReset(self)

  self._animation:hardReset()
end


return Animated
