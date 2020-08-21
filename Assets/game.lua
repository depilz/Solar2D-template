local composer = require("composer")

local LoadingScreen = require("Plugins.loadingScreen")
local State         = require("Libs.State.state")

local stories = {
  mainStory = "Assets.Story.mainStory",
}

-- ---------------------------------------------------------------------------------------------------------------------
-- ------  -----  ---- -- --               - -- ---   My Game   --- -- -                  -- -- ---  ----  -------------
-- ---------------------------------------------------------------------------------------------------------------------

local Game = {}
_G.game = Game

Game.shortcuts = {}

Game.time       = require("Plugins.time")
Game.music      = require("Assets.Audio.music")

_G.transition2    = require("Libs.transition2")
_G.ObjectPool     = require("Libs.objectPoolManager")

function Game.start()
  Game.time.start()

  Game.state = State:new(_G.savedData.getValue("state"), Game)

  require("Plugins.soundPlayer").setState(Game.state)
  
  display.setDefault("background", 0)
  
  Game.layers = {}
  ObjectPool.load("basic")
  if _G.DEBUG.MAIN_SCENE then
    Game.play(_G.DEBUG.MAIN_SCENE)
  else
    Game.play("mainStory")
  end
end


function Game.play(story, params)
  Game.story = require(stories[story]):new(params)
  return Game.story
end


function Game.getScene(scene)
  return composer.getScene("Assets.Scenes."..(scene or Game._currentScene))
end


function Game.load(loader, onComplete)
  LoadingScreen.show()
  timer.performWithDelay(1, function()
    loader()
    LoadingScreen.hide(1200, onComplete)
  end)
end

 
function Game.goTo(scene, params)
  local shortcuts = Game.shortcuts
  for k, _ in pairs(shortcuts) do
    shortcuts[k] = nil
  end
  Game._currentScene = scene
  composer.gotoScene("Assets.Scenes."..scene, {params = params})
  Game.currentScene = composer.getScene("Assets.Scenes."..scene)

  return shortcuts
end


function Game.save()
  _G.savedData.setValue("state", Game.state:getData())
  _G.savedData.save()
end


-- System events -------------------------------------------------------------------------------------------------------

function Game.onSystemEvent(e)
  if e.type == "applicationSuspend" then
    Game.suspend()
  end
end
Runtime:addEventListener( "system", Game.onSystemEvent )


function Game.suspend()
  if Game.pauseOnSuspend then
    Game.time.pause()
  end
end


-- Button back/return --------------------------------------------------------------------------------------------------

local function onKeyEvent( event )
  if ( event.keyName == "back" ) then
    native.showAlert(
      "Game",
      "Do you want to exit game?",
      {"yes","no"}, function(promptEvent)
        if promptEvent.action == "clicked" and promptEvent.index == 1 then
          os.exit()
        end
    end )
    return true
  end
  return false
end
Runtime:addEventListener( "key", onKeyEvent )

return Game
