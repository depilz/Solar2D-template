local Entity = require("Assets.Entities.entity")

local ButtonPlayPause = require("Assets.Entities.GUI.Buttons.buttonPlayPause")

-- ---------------------------------------------------------------------------------------------------------------------
-- Game User Interface --
-- ---------------------------------------------------------------------------------------------------------------------

local GUI = Class("GUI", Entity)

function GUI:create(parent, environment)
  Entity.create(self, parent)

  self._lastActivePanels = List.new()

  self._panels = {}
  self._panels["btnPlayPause"]  = ButtonPlayPause:new(self.group, environment)
end


function GUI:get(panel)
  return self._panels[panel]
end


function GUI:showUp(panels, effect)
  if panels == true then
    panels = nil
    effect = true
  end

  if panels then
    for _,panel in ipairs(panels) do
      if not self._lastActivePanels:contains(panel) then
        self._lastActivePanels:append(panel)
      end
    end
  end

  for _,panel in ipairs(self._lastActivePanels) do
    self._panels[panel]:showUp(effect)
  end
end


function GUI:hide(panels, effect)
  if panels == true then
    panels = nil
    effect = true
  end
  if panels then
    for _,panel in ipairs(panels) do
      self._lastActivePanels:remove_value(panel)
    end
  end
  for _,panel in ipairs(panels or self._lastActivePanels) do
    self._panels[panel]:hide(effect)
  end
end


function GUI:organize(params)
  self._lastActivePanels = List.new(params.show)
  for key,panel in pairs(self._panels) do
    if self._lastActivePanels:contains(key) then
      panel:showUp(params.showEffect)
    else
      panel:hide(params.hideEffect)
    end
  end
end


return GUI
