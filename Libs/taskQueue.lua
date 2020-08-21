local TaskQueue = {}

function TaskQueue.new()
  local tq = {}

  for k, v in pairs(TaskQueue) do
    tq[k] = v
  end

  tq._tasks = List.new()
  tq:hardReset()

  return tq
end


function TaskQueue:hardReset()
  self._tasks:clear()
  self.timeElapsed = 0
end


function TaskQueue:addTask(params)
  return self:_insert(self:_newTask(params))
end


function TaskQueue:_insert(task)
  local index = #self._tasks
  while index > 0 and self._tasks[index].time > task.time do
    index = index-1
  end

  self._tasks:insert(index+1, task)

  return task
end


function TaskQueue:performTasks(timeElapsed)
  self.timeElapsed = self.timeElapsed +timeElapsed
  while #self._tasks > 0 and self._tasks[1].time <= self.timeElapsed do
    self._tasks:pop(1).toDo()
  end
end


function TaskQueue:_newTask(params)
  return {
    time  = params.time + self.timeElapsed,
    toDo  = params.toDo,
    pause = function(task)
      if task.pauseTime then return end
      self._tasks:remove_value(task)
      task.pauseTime = self.timeElapsed
    end,
    resume = function(task)
      if not task.pauseTime then return end
      task.time = task.time + (self.timeElapsed - task.pauseTime)
      task.pauseTime = nil
      self:_insert(task)
    end,
    cancel = function(task)
      self._tasks:remove_value(task)
    end
  }
end


return TaskQueue
