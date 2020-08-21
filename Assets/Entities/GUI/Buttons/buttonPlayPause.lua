local GUIEntity = require("Assets.Entities.GUI.GUIEntity")

local time = _G.game.time

-- ---------------------------------------------------------------------------------------------------------------------
-- Button
-- ---------------------------------------------------------------------------------------------------------------------

local Button = Class("playPause-button", GUIEntity)

Button.__defaultEffect   = "displacement"
Button.__visiblePosition = {screen.edgeX - 22, screen.originY + 19}
Button.__hiddenPosition  = {screen.edgeX - 22, screen.originY + 19-95}

function Button:create(parent)
  GUIEntity.create(self, parent)

  -- self._levelObservers = List.new()
  self._paused = false

  self._btnPause = display.newCircle( self.group, 0, 0, 15)
  self._btnPause:setFillColor(0,1,0)
  self._btnPlay = display.newCircle( self.group, 0, 0, 15)
  self._btnPlay:setFillColor(1,0,0)
  self:addEventListener("touch", self)

  self:resume()
  time.addPausable(self)
end


function Button:touch(e)
  if     e.phase == "began" then
    self:getFocus()
    self._started = true
    if not self._paused then
      self._pausing = true
      time:pause()
    end
  elseif e.phase == "ended" then
    if self._paused and not self._pausing and self._started and
      e.x >= self._btnPlay.contentBounds.xMin and
      e.x <= self._btnPlay.contentBounds.xMax and
      e.y >= self._btnPlay.contentBounds.yMin and
      e.y <= self._btnPlay.contentBounds.yMax then
      
      time:resume()
    end

    self:releaseFocus()
    self._pausing = false
    self._started = false
  end

  return e.phase == "began"
end


function Button:tryToPause()
  time:pause()
end


function Button:pause()
  self._paused = true

  self._btnPlay.isVisible  = true
  self._btnPause.isVisible = false
end


function Button:resume()
  self._paused = false

  self._btnPlay.isVisible  = false
  self._btnPause.isVisible = true
end


function Button:reset()
  self:resume()
end


return Button
