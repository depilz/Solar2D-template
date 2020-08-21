local TaskQueue = require("Libs.taskQueue")
local SoundPlayer = require("Plugins.soundPlayer")

------------------------------------------------------------------------------------------------------------------------
-- Time Controller --
------------------------------------------------------------------------------------------------------------------------
local Time = {
  scale = 1
}

local _prevTime       = 0
local _timeElapsed    = 0
local _startPauseTime = nil

local newSubscribers   = {}
local newUnsubscribers = {}

local _enterFrameObjects = List.new()
local _pausableObjects   = List.new()
local _scalableObjects   = List.new()
local prevScale = 1
local _taskQueue         = TaskQueue.new()
local min = math.min
local getTimer = system.getTimer

function Time.getTimer()
  return _timeElapsed-- + min(getTimer() - _prevTime, 20)*Time.scale
end


function Time.subscribe(v)
  if newUnsubscribers[v] then
    newUnsubscribers[v] = nil
  else
    assert(not _enterFrameObjects:contains(v) and not newSubscribers[v], tostring(v).. " does")
    newSubscribers[v] = v
  end
end


function Time.unsubscribe(v)
  if newSubscribers[v] then
    newSubscribers[v] = nil
  elseif _enterFrameObjects:contains(v) then
    newUnsubscribers[v] = v
  end
end


function Time.addPausable(subscriber)
  _pausableObjects:remove_value(subscriber)
  _pausableObjects:append(subscriber)
end


function Time.removePausable(subscriber)
  _pausableObjects:remove_value(subscriber)
end


function Time.addScalable(subscriber)
  _scalableObjects:remove_value(subscriber)
  _scalableObjects:append(subscriber)
  if subscriber.setTimeScale then subscriber:setTimeScale(Time.scale)
  else                            subscriber.timeScale = Time.scale
  end
end


function Time.removeScalable(subscriber)
  _scalableObjects:remove_value(subscriber)
end


function Time.performWithDelay(delay, task)
  return _taskQueue:addTask{ time = delay, toDo = task }
end


function Time.setTimeScale(scale, params)
  if params then
    transition.to(Time, {
      tag        = params.tag or "time",
      delay      = params.delay,
      onStart    = params.onStart,
      time       = params.time or 50,
      transition = params.transition,
      scale      = scale,
      onComplete = params.onComplete,
    })

  else
    Time.scale = scale
  end
end


------------------------------------------------------------------------------------------------------------------------
-- Event Listeners --
------------------------------------------------------------------------------------------------------------------------

local avrgArray = {}
local average = 0
local worst  = 0
local better = 9999999
function Time.enterFrame()
  if Time.isPaused then return false end

  if _prevTime == 0 then
    _prevTime    = getTimer()
    return false
  end


  local currentTime = getTimer()
  local timeElapsed = min(currentTime - _prevTime, 20) * Time.scale
  _timeElapsed = _timeElapsed + timeElapsed
  _prevTime    = currentTime


  _taskQueue:performTasks(timeElapsed)

  for i=1, #_enterFrameObjects do
    _enterFrameObjects[i]:enterFrame(timeElapsed, _timeElapsed)
  end

  if prevScale ~= Time.scale  then
    prevScale = Time.scale
    for i=1, #_scalableObjects do
      local o = _scalableObjects[i]
      if o.setTimeScale then o:setTimeScale(Time.scale)
      else                   o.timeScale = Time.scale
      end
    end
  end

  for _, v in pairs(newSubscribers) do
    _enterFrameObjects:append(v)
  end
  for _, v in pairs(newUnsubscribers) do
    _enterFrameObjects:remove_value(v)
  end
  newSubscribers   = {}
  newUnsubscribers = {}

  return true
end

------------------------------------------------------------------------------------------------------------------------
-- Effects --
------------------------------------------------------------------------------------------------------------------------

function Time.hitLag(strenght)
  transition.cancel("time")
  local timeScale = Time.scale

  transition.to(Time, {
    tag        = "time",
    time       = 40*strenght,
    scale      = .05,
    transition = easing.outQuad,
    onCancel = function()
      Time.scale = timeScale
    end,
    onComplete = function()
      transition.to(Time, {
        tag        = "time",
        time       = 80*strenght,
        scale      = timeScale,
        transition = easing.outQuad,
        onCancel = function()
          Time.scale = timeScale
        end
      })
    end
  })
end

------------------------------------------------------------------------------------------------------------------------
-- Flow methods --
------------------------------------------------------------------------------------------------------------------------

function Time.start()
  Runtime:addEventListener("enterFrame", Time)
end


function Time.resume(avoidPause)
  if not Time.isPaused then return end
  if avoidPause then
    local pauseTime = getTimer() - _startPauseTime
    _prevTime = _prevTime + pauseTime
  end
  Time.isPaused = false

  SoundPlayer.resume()

  for _,o in pairs(_pausableObjects) do
    o:resume()
  end

  transition.resume("time")
end


function Time.pause()
  if Time.isPaused then return end
  Time.isPaused = true
  _startPauseTime = getTimer()

  SoundPlayer.pause()

  for _,o in pairs(_pausableObjects) do
    o:pause()
  end

  transition.pause("time")
end


function Time.stop()
  Time.isPaused = true
  Runtime:removeEventListener("enterFrame", Time)
end

------------------------------------------------------------------------------------------------------------------------
-- Clear --
------------------------------------------------------------------------------------------------------------------------

function Time.hardReset()
  _taskQueue:hardReset()
  _enterFrameObjects = {}
end


function Time.clear()
  _taskQueue = nil
  _enterFrameObjects = nil
end


return Time
