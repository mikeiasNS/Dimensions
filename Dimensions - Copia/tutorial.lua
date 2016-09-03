local composer = require( "composer" )
local scene = composer.newScene()
local physics = require "physics"
local widget = require "widget"

-- MTE "PLATFORMER - ANGLED" -----------------------------------------------------------
--display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )
system.activate("multitouch")
local mte = require("MTE.mte").createMTE()
local ben, ren

local currentChar

local playerWalkingAhead, playerWalkingBack, jumping = false, false, false

local screenLeft, screenWidth = display.screenOriginX, display.contentWidth
local screenRight = screenWidth - screenLeft


-- Load two audio streams
local deBoa = audio.loadStream("sound/de_boa.wav")
local eita = audio.loadStream("sound/eita.wav")

local backGroundEitaChannel, backgroundMusicChannel

--collision names
local benName = "ben"
local groundName = "ground"

local function die()
	audio.stop()

	mte.physics.setGravity(0, 0)
	local options = {
		effect = "fade",
		time = 500,
		params = {}
	}
	composer.removeScene("tutorial")
	composer.gotoScene("gameover", options)
end

function swipeBG()
	audio.pause(backgroundMusicChannel)
	backGroundEitaChannel = audio.play(eita, {channel=audio.findFreeChannel(), loops=-1})
end

local function onCharCollision(self, event)
	if(event.other.name == groundName and event.phase == "began") then
		jumping = false
	elseif(event.other.name == "totem") then
		toUpSideWorld()
	end
end

local onNameProperty = function(event)
    event.target.name = event.propValue
end

local onEnemyProperty = function(event)
	swipeBG()
end

function toUpSideWorld() 
	mte.setCameraFocus(nil)
	currentChar = ren
	mte.moveCameraTo({levelPosY = ren.y + 80, levelPosX = mte.getCamera().levelPosX, time = 1000, transition = easing.inOutQuad})
	ben.gravityScale = 0
	mte.physics.setGravity(0, -50)
	timer.performWithDelay(1000, focusCameraInRen) 
end

function focusCameraInRen()
	mte.setCameraFocus(ren, 0, 80)
end

function scene:create(event)
	local sceneGroup = self.view

	--ENABLE PHYSICS -----------------------------------------------------------------------
	mte.enableBox2DPhysics()
	mte.physics.start()
	mte.physics.setGravity(0, 50)
	--mte.physics.setDrawMode("hybrid")

	--LOAD MAP -----------------------------------------------------------------------------
	mte.toggleWorldWrapX(true)
	mte.toggleWorldWrapY(true)
	mte.loadMap("maps/chapter1Test.tmx")
	mte.addPropertyListener("name", onNameProperty)
	mte.addPropertyListener("enemy", onEnemyProperty)
	local blockScale = 33
	map = mte.setCamera({blockScale = blockScale})
	mte.constrainCamera() 

	local benProperties = mte.getObject({name = "Ben"})
	local renProperties = mte.getObject({name = "Ren"})

	local spriteSheet = graphics.newImageSheet("images/ben_sprite.png", {width = 50, height = 156, numFrames = 6})
	local sequenceData = {
			{name = "stoppedAhead", sheet = spriteSheet, frames = {3}, time = 200, loopCount = 0},
			{name = "stoppedBack", sheet = spriteSheet, frames = {6}, time = 200, loopCount = 0},
			{name = "walkAhead", sheet = spriteSheet, frames = {2, 1}, time = 300, loopCount = 0},
			{name = "walkBack", sheet = spriteSheet, frames = {5, 4}, time = 300, loopCount = 0}
	}

	ben = display.newSprite(spriteSheet, sequenceData)
	local setup = {layer = 5, kind = "sprite", levelPosX = benProperties[1].x, levelPosY = benProperties[1].y}	
	mte.physics.addBody(ben, "dynamic", {friction = 0.2, bounce = 0.0, density = 1, filter = { categoryBits = 1, maskBits = 1 } })
	ben.isFixedRotation = true
	ben.collision = onCharCollision
	ben:addEventListener("collision")
	mte.addSprite(ben, setup)

	currentChar = ben

	local renSpriteSheet = graphics.newImageSheet("images/ren_sprite.png", {width = 50, height = 156, numFrames = 6})
	local renSequenceData = {
			{name = "stoppedAhead", sheet = renSpriteSheet, frames = {3}, time = 200, loopCount = 0},
			{name = "stoppedBack", sheet = renSpriteSheet, frames = {6}, time = 200, loopCount = 0},
			{name = "walkAhead", sheet = renSpriteSheet, frames = {2, 1}, time = 300, loopCount = 0},
			{name = "walkBack", sheet = renSpriteSheet, frames = {5, 4}, time = 300, loopCount = 0}
	}

	ren = display.newSprite(renSpriteSheet, renSequenceData)
	local renSetup = {layer = mte.getSpriteLayer(1), kind = "sprite", levelPosX = renProperties[1].x, levelPosY = renProperties[1].y}	
	mte.physics.addBody(ren, "dynamic", {friction = 0.2, bounce = 0.0, density = 1, filter = { categoryBits = 1, maskBits = 1 } })
	ren.isFixedRotation = true
	ren.collision = onCharCollision
	ren:addEventListener("collision")
	mte.addSprite(ren, renSetup)

	mte.setCameraFocus(ben, 0, -80)
	mte.update()

	--add buttons
	backBtn = widget.newButton{
		label="",
		defaultFile="images/back.png",
		width = display.contentHeight * 0.15, 
		height= display.contentHeight * 0.15, 
		onEvent = goBack
	}
	backBtn.x, backBtn.y = screenLeft + display.contentHeight * 0.1, display.contentHeight - display.contentHeight * 0.13
	backBtn.alpha = 0.5

	aheadBtn = widget.newButton{
		label="",
		defaultFile="images/ahead.png",
		width = display.contentHeight * 0.15, 
		height= display.contentHeight * 0.15, 
		onEvent = goAhead
	}
	aheadBtn.x, aheadBtn.y = backBtn.x + (backBtn.width / 2) + screenWidth * 0.06, display.contentHeight - display.contentHeight * 0.1
	aheadBtn.alpha = 0.5

	jumpBtn = widget.newButton{
		label="",
		defaultFile="images/up.png",
		width = display.contentHeight * 0.15, 
		height= display.contentHeight * 0.15, 
		onPress = jump
	}
	jumpBtn.x, jumpBtn.y = screenRight - display.contentHeight * 0.1, (aheadBtn.y + backBtn.y) / 2
	jumpBtn.alpha = 0.5

	sceneGroup:insert(map)
	sceneGroup:insert(aheadBtn)
	sceneGroup:insert(backBtn)
	sceneGroup:insert(jumpBtn)
end

function goAhead(event)
	if ( event.phase == "began" ) then
        playerWalkingAhead = true
        currentChar:setSequence( "walkAhead" )
        currentChar:play()
    elseif (event.phase == "ended" or event.phase == "cancelled") then
        playerWalkingAhead = false
        currentChar:setSequence( "stoppedAhead" )
        currentChar:play()
    end
    return true
end

function goBack(event)
	if (event.phase == "began") then
        playerWalkingBack = true
        currentChar:setSequence( "walkBack" )
        currentChar:play()
    elseif (event.phase == "ended" or event.phase == "cancelled") then
        playerWalkingBack = false
        currentChar:setSequence( "stoppedBack" )
        currentChar:play()
    end

    return true
end

function jump(event) 
	if (not jumping) then
		if(cameraFocusInBen) then
			jumping = true
			currentChar:applyLinearImpulse(0, -200, currentChar.x, currentChar.y)
		else 
			currentChar:applyLinearImpulse(0, 200, currentChar.x, currentChar.y)
		end
	end
end

function handleMove(event)	
	mte.update()
	if(playerWalkingAhead) then 
		currentChar.x = currentChar.x + 5
	elseif (playerWalkingBack) then
		currentChar.x = currentChar.x - 5
	end
end

function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		backgroundMusicChannel = audio.play(deBoa, {channel=audio.findFreeChannel(), loops=-1})
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- e.g. start timers, begin animation, play audio, etc.
		--physics.start()
	end
end

function scene:hide(event)
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy(event)
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.	
	--package.loaded[physics] = nil		
	scene:removeEventListener("create", scene)
	scene:removeEventListener("show", scene)
	scene:removeEventListener("hide", scene)
	scene:removeEventListener("destroy", scene)
	Runtime:removeEventListener("enterFrame", handleMove)
	backBtn:removeSelf()
	jumpBtn:removeSelf()
	aheadBtn:removeSelf()
	backBtn, jumpBtn, aheadBtn = nil, nil, nil
	audio.pause(backGroundEitaChannel)
	audio.pause(backgroundMusicChannel)
	timer.performWithDelay(500, mte.cleanup)
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
Runtime:addEventListener("enterFrame", handleMove)

return scene