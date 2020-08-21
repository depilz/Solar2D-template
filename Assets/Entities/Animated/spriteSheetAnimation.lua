local AnimationBase = require("Assets.Entities.Animated.animation")

-- ---------------------------------------------------------------------------------------------------------------------
-- SpriteSheetAnimation
-- ---------------------------------------------------------------------------------------------------------------------
local SpriteSheetAnimation = Class("spriteSheetAnimation", AnimationBase)
SpriteSheetAnimation._inGameElement = true

function SpriteSheetAnimation:create(parent)
  AnimationBase.create(self, parent)
  self._spriteSheet = display.newSprite(self.group, self.__imageSheet, self.__sequenceData)
  self._spriteSheet:addEventListener("sprite", self)
  self._spriteSheet.anchorX, self._spriteSheet.anchorY = self.__anchorX or .5, self.__anchorY or 1

  self.__busyTable = {}
  for _,data in pairs(self.__sequenceData) do
    self.__busyTable[data.name] = (data.loopCount or 0) > 0
  end

  if self.__flipX then self:faceLeft() end
end


function SpriteSheetAnimation:playAnimation(animation, params)
  params = params or {}

  if self._animationDelayTask then self._animationDelayTask:cancel() end

  if self._currentAnimation then
    self:onCancel{
      name   = "sprite",
      phase  = "cancel",
      target = self._spriteSheet
    }
  end

  self._currentAnimation = animation
  self._animationCallbacks = {
    name       = animation,
    onStart    = params.onStart,
    onBounce   = params.onBounce,
    onLoop     = params.onLoop,
    onCancel   = params.onCancel,
    onComplete = params.onComplete,
  }

  local frame  = params.frame or params.keepFrame and self._currentFrame or 1
  local filter = self._spriteSheet.fill.effect
  local exp    = self._spriteSheet.fill.exposure

  self._spriteSheet:setSequence(animation)
  self._spriteSheet:setFrame(frame)
  self._currentFrame = frame
  self._spriteSheet.fill.effect = filter
  self._spriteSheet.fill.exposure = exp
  self._nextAnimation = nil
  if self.__imageOffsets then
    assert(self.__imageOffsets[animation], "no image offset for: "..animation.." in "..tostring(self))
    self._spriteSheet.x, self._spriteSheet.y = self.__imageOffsets[animation].x*self.group.xScale, self.__imageOffsets[animation].y
  end

  if params.delay then
    self._isAnimationPlaying = false
    self._animationDelayTask = self:performWithDelay(params.delay, function()
      self._isAnimationPlaying = true
      self:resume()
    end)
  else
    self._isAnimationPlaying = true
    self:resume()
  end

  self:onStart{
    name   = "sprite",
    phase  = "began",
    target = self._spriteSheet
  }

  return true
end


function SpriteSheetAnimation:playNextAnimation(animation, params)
  if self.isBusy then
    self._nextAnimation = {animation, params}
    return false
  else
    self:playAnimation(animation, params)
    return true
  end
end


function SpriteSheetAnimation:move(x, y)
  self:dispatchEvent{ name = "animationMoved", target = self, dx = x, dy = y }
end


-- Flow --------------------------------------------------------------------------------------------------------------

function SpriteSheetAnimation:resume()
  self._paused = false
  if self._currentAnimation and self._isAnimationPlaying and not self._isFreezed and not self._timeScaleFreezed then
    self._spriteSheet:play()
  end
end


function SpriteSheetAnimation:pause()
  self._paused = true
  self._spriteSheet:pause()
end


function SpriteSheetAnimation:setTimeScale(scale)
  if scale < .05 then
    self._timeScaleFreezed = true
    self:pause()
  else
    local play = self._timeScaleFreezed
    self._timeScaleFreezed = false
    self._spriteSheet.timeScale = scale

    if play then
      self:resume()
    end
  end
end


-- Events --------------------------------------------------------------------------------------------------------------

function SpriteSheetAnimation:sprite(e)
  if e.phase == "began" then
  elseif e.phase == "next" then
  elseif e.phase == "bounce" then
    self:onBounce(e)
  elseif e.phase == "loop" then
    self:onLoop(e)
  elseif e.phase == "ended" then
    self:onComplete(e)
  end

  self:onEvent(e)
end


function SpriteSheetAnimation:onStart(e)
  self._currentAnimation = e.target.sequence

  self.isBusy = self.__busyTable[self._currentAnimation]

  if self._animationCallbacks.onStart then
    self._animationCallbacks.onStart(e)
  end
end


function SpriteSheetAnimation:onCancel(e)
  self.isBusy = self._currentAnimation ~= e.target.sequence and self.isBusy
  if self._animationCallbacks.onCancel then
    self._animationCallbacks.onCancel(e)
  end

  return true
end


function SpriteSheetAnimation:onBounce(e)
  if self._animationCallbacks.onBounce then
    self._animationCallbacks.onBounce(e)
  end
end


function SpriteSheetAnimation:onLoop(e)
  if self._animationCallbacks.onLoop then
    self._animationCallbacks.onLoop(e)
  end
end


function SpriteSheetAnimation:onComplete(e)
  self._lastEndedAnimation = self._currentAnimation
  self._currentAnimation = nil
  self.isBusy = false
  self._isAnimationPlaying = false

  if self._animationCallbacks.onComplete then
    self._animationCallbacks.onComplete(e)
  end

  if self._nextAnimation then
    self:playAnimation(self._nextAnimation[1], self._nextAnimation[2])
  end
end


function SpriteSheetAnimation:onEvent(e)

end


function SpriteSheetAnimation:stop()
  AnimationBase.stop(self)
  if self._animationDelayTask then self._animationDelayTask:cancel() end
  self._spriteSheet:pause()
end


function SpriteSheetAnimation:hardReset()
  AnimationBase.hardReset(self)

  self._currentFrame          = nil
  self.isBusy                 = false
  self._spriteSheet.isVisible = true
end


return SpriteSheetAnimation
