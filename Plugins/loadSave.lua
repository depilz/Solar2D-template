local jsonParser = require("json")

local LoadSave = {}

------------------------------------------------------------------------------------------------------------------------
-- Save Data
------------------------------------------------------------------------------------------------------------------------

local savedData     = nil
local isSandboxMode = false

function LoadSave.load()
	local path = system.pathForFile( "savedData.json", system.DocumentsDirectory )
  local file = io.open( path, "r" )
	if file then
    local settingsImport
		settingsImport = file:read( "*a")
		io.close( file )
    savedData = jsonParser.decode(settingsImport)
    savedData.prevSession = savedData.currentSession
    savedData.currentSession = os.time()
	else
		LoadSave.nuke()
	end
end


function LoadSave._resetUsing(file)
	local settingsImport
	savedData = system.pathForFile( file, system.ResourceDirectory )
	local emptyFile = io.open( savedData, "r" )
	if emptyFile then
		settingsImport = emptyFile:read( "*a")
		io.close(emptyFile)
	end
	savedData = jsonParser.decode(settingsImport)

  local time = os.time()
  savedData.firstSession    = time
  savedData.prevSession     = time
  LoadSave.save()

	return savedData
end


function LoadSave.nuke()
  print("-- NUKING! --")
  LoadSave._resetUsing("savedData.json") 
end


function LoadSave.nukeFull()
  print("-- NUKING FULL! --")
  LoadSave._resetUsing("savedDataFull.json")
end


function LoadSave.startSandboxMode(file)
  LoadSave._savedData = savedData

  local settingsImport
	local emptyData = system.pathForFile( "savedData-"..file..".json", system.ResourceDirectory )
	local emptyFile = io.open( emptyData, "r" )
	if emptyFile then
		settingsImport = emptyFile:read( "*a")
		io.close(emptyFile)
	end
	emptyData = jsonParser.decode(settingsImport)

	savedData = emptyData

  isSandboxMode = true

  print("Sandbox mode is on")

  return savedData
end


function LoadSave.stopSandboxMode()
  savedData = LoadSave._savedData
  isSandboxMode = false

  print("Sandbox mode is off")

  return savedData
end


function LoadSave.getValue(path)
  local value = savedData
  for _, key in ipairs(path:split(".")) do
    value = value[key]
  end
  return value
end


function LoadSave.setValue(path, value, save)
  local t = savedData
  local pathTable = path:split(".")
  for i=1,#pathTable-1 do
    t = t[pathTable[i]]
  end
  t[pathTable[#pathTable]] = value
  if save then
    LoadSave.save()
  end
end


function LoadSave.save()
  if isSandboxMode then print("Data wasn't saved due to Sandbox mode is on") return end
	print("saving...")

	local path = system.pathForFile( "savedData.json", system.DocumentsDirectory )
	local file = io.open( path, "w+" )

	file:write( jsonParser.encode(savedData))
	io.close( file )

  print("Done")
end


function LoadSave.printAll()
  print("-------- SAVED DATA CONTENT --------")
  print(pl.pretty.write(savedData))
  print("------------------------------------")
end


return LoadSave
