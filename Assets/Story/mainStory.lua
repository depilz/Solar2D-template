local ChapterBasics = require('Assets.Story.chapterBasics')

local game        = _G.game
local shortcuts   = _G.game.shortcuts

local Chapter = Class("mainStory", ChapterBasics)

function Chapter:initialize()
  game.load(function()
    ObjectPool.load("basic")
    self.scene = game.goTo("mainGame")
  end)
end


return Chapter
