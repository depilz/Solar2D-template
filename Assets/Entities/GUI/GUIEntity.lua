-- Libs
local Entity = require("Assets.Entities.entity")

-- ---------------------------------------------------------------------------------------------------------------------
-- GUI Entity --
-- ---------------------------------------------------------------------------------------------------------------------
local GUIEntity = Class("GUIEntity", Entity)
GUIEntity.__defaultEffect   = nil
GUIEntity.__visiblePosition = nil
GUIEntity.__hiddenPosition  = nil

function GUIEntity:create(parent)
  Entity.create(self, parent, self.__hiddenPosition[1], self.__hiddenPosition[2])
  self:setVisibility(0)
  self._hidden = true
end


function GUIEntity:showUp(effect)
  self._hidden = false

  transition.cancel(self.id.."gui")

  if effect == true or effect == "default" then
    effect = self.__defaultEffect
  end

  if not effect then
    self:setPosition(self.__visiblePosition[1], self.__visiblePosition[2])
    self:setVisibility(1)

  elseif effect == "displacement" then
    self:transitionTo{
      x          = self.__visiblePosition[1],
      y          = self.__visiblePosition[2],
      tag        = self.id.."gui",
      time       = 300,
      transition = easing.inQuad,
      alpha      = 1,
    }

  elseif effect == "transparency" then
    self:setPosition(self.__visiblePosition[1], self.__visiblePosition[2])
    self:setVisibility(1, {
      tag = self.id.."gui",
      time = 300
    })

  end
end


function GUIEntity:hide(effect)
  self._hidden = true

  transition.cancel(self.id.."gui")

  if effect == true or effect == "default" then
    effect = self.__defaultEffect
  end

  if not effect then
    self:setPosition(self.__hiddenPosition[1], self.__hiddenPosition[2])
    self:setVisibility(0)

  elseif effect == "displacement" then
    self:transitionTo{
      x          = self.__hiddenPosition[1],
      y          = self.__hiddenPosition[2],
      tag        = self.id.."gui",
      time       = 300,
      transition = easing.inQuad,
      alpha      = 0,
    }

  elseif effect == "transparency" then
    self:setPosition(self.__hiddenPosition[1], self.__hiddenPosition[2])
    self:setVisibility(0, {
      tag        = self.id.."gui",
      time       = 300
    })
  end
end


return GUIEntity
