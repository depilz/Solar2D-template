local Entity = require("Assets.Entities.entity")

------------------------------------------------------------------------------------------------------------------------
-- Hangar background
------------------------------------------------------------------------------------------------------------------------

local Background = Class("background", Entity)

function Background:create(parent)
  Entity.create(self, parent)

  self._img = display.newRect(self.group, screen.centerX, screen.centerY, screen.width, screen.height)
  self._img:setFillColor(.2,.05,.3)
end

------------------------------------------------------------------------------------------------------------------------
-- Creation --
------------------------------------------------------------------------------------------------------------------------

return Background
