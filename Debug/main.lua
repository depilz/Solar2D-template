local settings = require("Debug.settings")

_G.DEBUG = settings

local composer = require("composer")
composer.isDebug = _G.DEBUG.COMPOSER

if settings.GAME_SCALE then
  local view = display.getCurrentStage()
  local s = settings.GAME_SCALE
  view.xScale, view.yScale = s, s
  view.x, view.y = screen.width*(1-s)/2, screen.edgeY*(1-s)*.5
end


if _G.DEBUG.PLAY_IN_SLOWMO then
  timer.performWithDelay(17000, function() _G.game.time.setTimeScale(0.1) end)
end


if _G.DEBUG.PROFILER then
  local profiler = require "Debug.profiler"
  profiler.startProfiler(_G.DEBUG.PROFILER)
end


if _G.DEBUG.SHOW_PERFORMANCE then
  timer.performWithDelay(1000, function()
    require("Debug.debugInfo")
  end)
end


if _G.DEBUG.SKIP_ERRORS then 
  local function myUnhandledErrorListener( event )
     local errorMessage = "ERROR:  " ..
         event.errorMessage .. "\n" ..
         event.stackTrace .. "\n\n\n\n"..
         "**IMPORTANT**!!: Pressing continue may trigger more unexpected issues"
  
     native.showAlert( "Handling the unhandled error", errorMessage, {"CONTINUE", "QUIT GAME"}, function(event)
       if ( event.action == "clicked" ) then
         local i = event.index
         if i == 1 then
         -- DO NOTHING
  
         elseif i == 2 then
         os.exit(1)
  
         end
       end
     end)
  
     print("ERROR:  "..errorMessage)
  
     if _G.game then _G.game.suspend() end
  
     return true
   end

  Runtime:addEventListener( "unhandledError", myUnhandledErrorListener ) 
end
