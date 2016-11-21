local constants = require ("core.misc.constants")
local objNames = constants.objNames
local loader = require ("core.loaders.loader")
local moves = require ("core.misc.moves")
local composer = require( "composer" )

local util = {}

util.goAhead = moves.goAhead

util.goBack = moves.goBack

util.jump = moves.jump

util.fire = moves.fire

util.switchRain = function(rain, on) 
	if on then
		rain:start("rain1", "rain2")
	else 
		rain:stop("rain1", "rain2")
	end
end

util.setInitialWorld = function(destinyId, ben, ren)
	local currentChar = ben
	local newWorld = "Odihna"
	if(destinyId > 0) then
		--Odihna
		ren.gravityScale = 0
		ben.gravityScale = 1
		mte.physics.setGravity(0, 50)
		focusCameraInBen()
	else 
		--Golgota
		ren.gravityScale = 1
		ben.gravityScale = 0
		mte.physics.setGravity(0, -50)
		focusCameraInRen()
		currentChar = ren
		newWorld = "Golgota"
	end

	local event = {
		name = constants.eventNames.worldChanged,
		world = newWorld
	}

	Runtime:dispatchEvent(event)	

	return currentChar
end

util.swapWorld = function(currentChar, otherChar, destinationObjCharName)
	local transitionTime = 2000
	local cameraOffsetY, cameraOffsetX = 0, 0
	local cameraFocusFunction, newWorld
	local ben, ren
	mte.setCameraFocus(nil)
	otherChar = util.repositionChar(destinationObjCharName, otherChar)

	if currentChar.name == objNames.ren then
		cameraOffsetY = -80
		mte.physics.setGravity(0, 50)
		cameraFocusFunction = focusCameraInBen
		newWorld = "Odihna"
		ben, ren = otherChar, currentChar
	else
		cameraOffsetY = 80
		mte.physics.setGravity(0, -200)
		cameraFocusFunction = focusCameraInRen
		newWorld = "Golgota"
		ben, ren = currentChar, otherChar
	end

	mte.moveCameraTo({levelPosY = otherChar.y + cameraOffsetY, 
		levelPosX = otherChar.x + cameraOffsetX, 
		time = transitionTime})

	currentChar.gravityScale = 0
	otherChar.gravityScale = 1
	timer.performWithDelay(transitionTime, cameraFocusFunction) 

	local event = {
		name = constants.eventNames.worldChanged,
		world = newWorld
	}

	Runtime:dispatchEvent(event)

	return otherChar, ben, ren
end

util.repositionChar = function(destinationObjName, char)
	local newProperties = mte.getObject({name = destinationObjName})
	local newChar, name

	if char.name == objNames.ren then
		newChar = loader.loadRen(destinationObjName)
	else 
		newChar = loader.loadBen(destinationObjName)
	end
	newChar.collision = char.collision
	newChar.name = char.name
	newChar:addEventListener("collision")

	mte.removeSprite(char, true)

	return newChar
end

util.die = function (rain)
	audio.stop()
	util.switchRain(rain, false)

	mte.physics.setGravity(0, 0)
	local options = {
		effect = "fade",
		time = 500,
		params = {}
	}
	composer.removeScene("chapters.chapter1")
	composer.gotoScene("gameover", options)
end

util.restart = function (rain)
	audio.stop()
	util.switchRain(rain, false)

	mte.physics.setGravity(0, 0)
	local options = {
		effect = "fade",
		time = 500,
		params = {}
	}
	composer.removeScene("chapters.chapter1")
	composer.gotoScene("menu", options)
end

util.tableContains = function(table, val) 
	for k, v in ipairs(table) do
		if(v == val) then
			return true
		end
	end
	return false
end

return util