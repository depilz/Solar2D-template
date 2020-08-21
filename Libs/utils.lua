------------------------------------------------------------------------------------------------------------------------
-- Constants and variables --
------------------------------------------------------------------------------------------------------------------------

_G.device = require "Libs.device"

------------------------------------------------------------------------------------------------------------------------
-- Libraries --
------------------------------------------------------------------------------------------------------------------------

require "pl.init"
_G.List = pl.List

_G.Class    = require("Libs.middleclass")
_G.screen   = require("Libs.screen")
_G.Stateful = require("Libs.stateful")

-- Check if not Nan nor infinite
local math = math
math.isANumber = function(n)
  return not (n ~= n or n*n == math.huge)
end

math.decimalRandom = function(a, b)
  return math.random()*(b-a)+a
end

math.sign = function(a)
  return a > 0 and 1 or a < 0 and -1 or 0
end

math.randomSign = function(a, b)
  return math.random(0, 1)*2-1
end

-- Bi-directional random: Gives a random number between the range: -b, -a and a, b
math.bidirRandom = function(a, b)
  local r = b*(math.random()*2-1)
  return r >= 0 and r+a or r-a
end

math.legs = function(angle, hypotenuse)
  return  math.cos(angle/180*math.pi)*hypotenuse,
          math.sin(angle/180*math.pi)*hypotenuse
end

math.hypotenuse = function(dx, dy, dz)
  dz = dz or 0
  return math.sqrt(dx*dx + dy*dy + dz*dz)
end

math.getAngle = function(dx, dy)
  return math.atan(dy/dx)*180/math.pi + (dx<0 and 180 or 0)
end


math.pair = function(number)
  number = number or math.random(1, 2)
  return (number%2)*2-1
end

_G.textFormat = {}
_G.textFormat.time = function(remainingTime)
  local time = math.ceil(remainingTime)%60
  local t
  if remainingTime >= 59 then
    if time < 10 then time = "0"..time end
    t = math.floor(((remainingTime+1)/60)%60)
    time = t..":"..time
  end
  if remainingTime >= 3599 then
    if t < 10 then time = "0"..time end
    t = math.floor(((remainingTime+1)/3600)%24)
    time = t..":"..time
  end
  if remainingTime >= 86399 then
    if t < 10 then time = "0"..time end
    time = math.floor((remainingTime+1)/86400)..":"..time
  end

  return time
end

local equals; equals = function(o1, o2)
  if o1 == o2 then return true end
  local o1Type = type(o1)
  local o2Type = type(o2)
  if o1Type ~= o2Type then return false end
  if o1Type ~= 'table' then return false end

  local keySet = {}

  for key1, value1 in pairs(o1) do
    local value2 = o2[key1]
    if value2 == nil or equals(value1, value2) == false then
      return false
    end
    keySet[key1] = true
  end

  for key2, _ in pairs(o2) do
    if not keySet[key2] then return false end
  end

  return true
end
_G.equals = equals

------------------------------------------------------------------------------------------------------------------------
-- Functions --
------------------------------------------------------------------------------------------------------------------------

local function shuffle(table)
  for i = 1, #table do
    local ndx0 = math.random( 1, #table )
    table[ ndx0 ], table[ i ] = table[ i ], table[ ndx0 ]
  end
  return table
end
_G.shuffle = shuffle

local getDepth; getDepth = function(group, c)
  local depth = c
  if group.numChildren then
    for i = 1,group.numChildren do
      local d = getDepth(group[i], c+1)
      depth = depth < d and d or depth
    end
  end
  return depth
end
_G.getDepth = getDepth


function string:capitalize()
  if type(self) ~= "string" then error("String expected, got "..type(self)) end
  return (self:gsub("^%l", string.upper))
end


function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end


local fcomp_default = function( a,b ) return a < b end
function table.bininsert(t, value, fcomp)
   -- Initialize compare function
   local fcomp = fcomp or fcomp_default
   --  Initialize numbers
   local iStart,iEnd,iMid,iState = 1,#t,1,0
   -- Get insert position
   while iStart <= iEnd do
      -- calculate middle
      iMid = math.floor( (iStart+iEnd)/2 )
      -- compare
      if fcomp( value,t[iMid] ) then
         iEnd,iState = iMid - 1,0
      else
         iStart,iState = iMid + 1,1
      end
   end
   table.insert( t,(iMid+iState),value )
   return (iMid+iState)
end