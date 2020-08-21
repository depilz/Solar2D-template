local deepcopy = pl.tablex.deepcopy

local Subject = Class("subject")

function Subject:initialize(state, path, value)
  self._state       = state
  self.path         = path
  self._value       = value
  self.inGameObject = state.inGameObject

  self.observers = {}
  self.count = 0
end


function Subject:notify(event)
  for key,obs in pairs(pl.tablex.copy(self.observers)) do
    if obs(key, event) then
      self.observers[key] = nil
      self.count = self.count -1
    end
  end
end


function Subject:setValue(value)
  if value == self._value and type(value) ~= "table" then return false end

  if type(value) == "table" then
    value = deepcopy(value)
  end

  local prev = self._value
  self._value = value
  self:notify{
    target = self.inGameObject,
    path   = self.path,
    prev   = prev,
    value  = value
  }

  return true
end


function Subject:getValue(value)
  self._state:getValue(value, self.path)
end


function Subject:subscribe(key, observer, initCall)
  if self.observers[key] then return false end
  self.observers[key] = observer

  if initCall then
    observer(key, {
      target = self.inGameObject,
      path   = self.path,
      prev   = self._value,
      value  = self._value
    })
  end

  self.count = self.count +1
  
  return true
end


function Subject:unsubscribe(observer)
  if not self.observers[observer] then return false end
  self.observers[observer] = nil
  self.count = self.count -1
end


return Subject
