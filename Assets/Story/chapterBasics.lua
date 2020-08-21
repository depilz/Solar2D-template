local game      = _G.game
local shortcuts = game.shortcuts

local Chapter = Class("chapterBasics")

------------------------------------------------------------------------------------------------------------------------
-- Scene Creation
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- Scene control
------------------------------------------------------------------------------------------------------------------------

function Chapter:fadeOut(params)
  if self._darkLayer then return false end

  self._darkLayer = display.newRect(screen.centerX, screen.centerY, screen.edgeX-screen.originX, screen.edgeY-screen.originY)
  self._darkLayer.alpha = 0
  self._darkLayer:setFillColor(0)
  self._darkLayer.isHitTestable = true
  self._darkLayer:addEventListener( "touch", function() return true end )
  self._darkLayer:addEventListener( "tap", function() return true end )

  transition.to(self._darkLayer, {
    time       = params.time or 150,
    alpha      = 1,
    transition = params.transition or transition.inQuad,
    onComplete = params.onComplete
  })
end


function Chapter:fadeIn(params)
  if not self._darkLayer then return false end

  transition.to(self._darkLayer, {
    time       = params.time or 150,
    alpha      = 0,
    transition = transition.outQuad,
    onComplete = function()
      self._darkLayer:removeSelf()
      self._darkLayer = nil
      if params.onComplete then params.onComplete() end
    end
  })
end


function Chapter:fadeOutIn(params)
  if self._darkLayer then return false end

  self._darkLayer = display.newRect(screen.centerX, screen.centerY, screen.edgeX-screen.originX, screen.edgeY-screen.originY)
  self._darkLayer.alpha = 0
  self._darkLayer:setFillColor(0)
  self._darkLayer.isHitTestable = true
  self._darkLayer:addEventListener( "touch", function() return true end )
  self._darkLayer:addEventListener( "tap", function() return true end )

  transition.to(self._darkLayer, {
    time       = params.fadeOut or 150,
    alpha      = 1,
    transition = params.fadeOutTransition or transition.inQuad,
    onComplete = function()
      if params.onLoading then params.onLoading() end
      transition.to(self._darkLayer, {
        time       = params.fadeIn or 300,
        alpha      = 0,
        transition = params.fadeInTransition or transition.outQuad,
        onComplete = function()
          self._darkLayer:removeSelf()
          self._darkLayer = nil
          if params.onComplete then params.onComplete() end
        end
      })
    end
  })
end


function Chapter:setGUIClass(gui)
  if self.gui then
    self.gui:clear()
  end

  self.gui = nil
  if gui then
    self.gui = require("Assets.Entities.GUI."..gui):new(game.currentScene.view, shortcuts.environment)
    shortcuts.gui = self.gui
  end
end


function Chapter:setGUI(style)

end


function Chapter:clear()

end


return Chapter
