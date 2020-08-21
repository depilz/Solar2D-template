local Entity = require("Assets.Entities.entity")

local Background = require("Assets.Entities.Environments.MainGame.background")

------------------------------------------------------------------------------------------------------------------------
-- Scene loader --
------------------------------------------------------------------------------------------------------------------------

local Environment = Class("mainGame-environment", Entity)

function Environment:create(parent)
  Entity.create(self, parent)
  
  self.background = Background:new(self.group)
  self._text = display.newText{
    text      = "Welcome!",
    parent    = self.group,
    x         = screen.centerX,
    y         = screen.centerY,
    fontSize  = 100
  }
end




return Environment
