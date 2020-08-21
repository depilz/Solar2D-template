local Subject = require("Libs.State.subject")

local type     = type
local deepcopy = pl.tablex.deepcopy

local SH = Class("state")

function SH:initialize(data, inGameObject, root, subjects)
  self.root         = root or ""
  self._subjects    = subjects or {}
  self.inGameObject = inGameObject
  self:setState(data, root and subjects)
end


function SH:getSubState(path, inGameObject)
  local data     = self:getValue(path)
  local root     = self.root..path.."."

  return SH:new(data, inGameObject, root, self._subjects)
end


function SH:setValue(path, value)
  local tablePath = path:split(".")
  local table     = self._data
  local root      = self.root
  local changes   = {}
  -- print("------------- "..tostring(self.inGameObject).." -------------")
  
  local newPath = tablePath[1]
  for i=1, #tablePath-1 do
    local key = tablePath[i]
    table[key] = table[key] or {}
    
    changes[root..newPath] = table[key]
    table = table[key]
    
    newPath = newPath.."."..tablePath[i+1]
  end
  

  local changed = false
  local f; f = function(o, d, dk, p)
    if type(o) == "table" then
      d[dk] = d[dk] or {}
      -- print(p  , d[dk])
      changes[p] = d[dk]
      for k,v in pairs(o) do
        f(v, d[dk], k, p.."."..dk)
      end
    elseif d[dk] ~= o then
      -- print(p, o)
      d[dk] = o
      changes[p] = o
      changed = true
    end
  end

  local key = tablePath[#tablePath]
  f(value, table, key, root..newPath)

  -- print("----------------------------------------\n\n")

  -- for k, v in pairs(changes) do
    -- print("changed: ", k, v)
  -- end
  if changed then
    for k,v in pairs(changes) do
      local subject = self._subjects[k]
      if subject then
        -- print("observing... ", k, v)
        subject:setValue(v)
      end
    end
  end
  
  -- print("----------------------------------------\n\n")
end


function SH:add(path, increment)
  if increment == 0 then return false end

  self:setValue(path, self:getValue(path)+increment)
end


function SH:use(path, value)
  if value <= 0 then return 0 end
  local currentValue = self:getValue(path)
  value = value > currentValue and currentValue or value

  self:setValue(path, currentValue-value)

  return value
end


function SH:substract(path, value)
  if value == 0 then return false end

  self:setValue(path, self:getValue(path)-value)
end


function SH:getValue(path)
  local value = self._data
  for _,key in ipairs(path:split(".")) do
    assert( value, "Invalid request: Get "..path.." -  at "..key)
    value = value[key]
  end
  return value
end


function SH:observe(path, key, observer, initCall)
  assert(path and key and observer, "here")
  if not self._subjects[self.root..path] then
    self._subjects[self.root..path] = Subject:new(self, self.root..path, self:getValue(path))
  end
  return self._subjects[self.root..path]:subscribe(key, observer, initCall)
end


function SH:unobserve(path, key)
  local subject = self._subjects[self.root..path]
  subject:unsubscribe(key)
  if subject.count == 0 then
    self._subjects[self.root..path] = nil
  end
end


function SH:setState(state, doNotCopy)
  self._data = doNotCopy and state or deepcopy(state)

  for path,subject in pairs(self._subjects) do
    local sub, count = path:gsub(self.root, "")
    if self.root == "" or count == 1 then
      subject:setValue(self:getValue(sub))
    end
  end
end


function SH:getData()
  return deepcopy(self._data)
end


function SH:merge(data, secondWins)
  local changes = {}

  -- print("------------- "..tostring(self.inGameObject).." -------------")

  local f; f = function(t1, t2, p)
    for k,v in pairs(t2) do
      local isATable = type(v) == "table"

      if isATable and t1[k] then
        changes[p..k] = v
        f(t1[k], v, p..k..".")
      else
        local f2; f2 = function(t, p)
          for k2,v2 in pairs(t) do
            if type(v2) == 'table' then
              changes[p..k2] = {}
              f2(v2[k2], p..k2..".")
            else
              changes[p..k2] = v2
            end
          end
          f2(v, p)
        end

        if t1[k] ~= v then
          t1[k] = v
          changes[p..k] = v
          -- print("New Change!", p..k, v)

        end
      end
    end
  end

  if secondWins then
    f(self._data, data, self.root)
  else
    f(data, self._data, self.root)
    self._data = data
  end

  -- print("------------------")
  for path,subject in pairs(self._subjects) do
    local value = changes[path]
    -- print(path, value)
    if value then
      subject:setValue(value)
    end
  end
  -- print("----------------------------------------")

end


function SH:__tostring()
  local s = "-------- ".. (tostring(self.inGameObject) or self.id) .." - state --------\n"
  s = s .. pl.pretty.write(self._data) .. "\n"
  s = s .. "---------------------------------------------------"
  return s
end


return SH
