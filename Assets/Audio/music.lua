local SoundPlayer = require("Plugins.soundPlayer")
require("Assets.Audio.loader")

local Music = {}

local function playSequence(sequence)
  SoundPlayer.playMusic(sequence:pop(1), nil, true, function()
    if #sequence > 1 then
      playSequence(sequence)
    else
      SoundPlayer.playMusic(sequence:pop(1))
    end
  end)
end


function Music.play(music, onComplete)
  SoundPlayer.playMusic(music, nil, nil, onComplete, nil)
end


function Music.pause()

end


function Music.resume()

end


function Music.stop()

end


return Music
