local composer = require( "composer" )
local scene = composer.newScene()
local physics = require "physics"

-- MTE "PLATFORMER - ANGLED" -----------------------------------------------------------
--display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )
system.activate("multitouch")
local mte = require("MTE.mte").createMTE()
local loader = require("loader")
local util = require("utils")
local ben, ren

local currentChar

local playerWalkingAhead, playerWalkingBack = false, false, false

-- Load two audio streams
local deBoa = audio.loadStream("sound/de_boa.wav")
local eita = audio.loadStream("sound/eita.wav")

local backGroundEitaChannel, backgroundMusicChannel

--collision names
local benName = "ben"
local renName = "ren"
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

local function onCharCollision(self, event)
	if(event.other.name == groundName and event.phase == "began") then
		currentChar.jumping = false
	elseif(event.other.name == "totem" and event.target.name == benName and event.phase == "began") then
		currentChar = util.toUpSideWorld(mte, ren, ben)
	elseif(event.other.name == "totem" and event.target.name == renName and event.phase == "began") then
		currentChar = util.toCommonWorld(mte, ren, ben)
	end
end

local onNameProperty = function(event)
    event.target.name = event.propValue
end

function toUpSideWorld() 
	local transitionTime = 2000

	mte.setCameraFocus(nil)
	currentChar = ren
	mte.moveCameraTo({levelPosY = ren.y + 80, levelPosX = ren.x + 2, time = transitionTime})
	ben.gravityScale = 0
	ren.gravityScale = 1
	mte.physics.setGravity(0, -200)
	timer.performWithDelay(transitionTime, focusCameraInRen) 
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

	--LOAD MAP -----------------------------------------------------------------------------
	loader.loadMap("maps/chapter1Test.tmx", mte) 
	mte.addPropertyListener("name", onNameProperty)

	--LOAD CHARS ---------------------------------------------------------------------------
	ben = loader.loadBen(mte)
	ben.collision = onCharCollision
	ben:addEventListener("collision")
	ben.name = benName

	ren = loader.loadRen(mte)
	ren.collision = onCharCollision
	ren:addEventListener("collision")
	ren.name = renName

	currentChar = ben

	mte.setCameraFocus(ben, 0, -80)
	mte.update()

	--load buttons
	backBtn, aheadBtn, jumpBtn = loader.loadButtons()

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
	if(not currentChar.jumping) then
		currentChar.jumping = true
		currentChar:applyLinearImpulse(0, currentChar.jumpForce, currentChar.x, currentChar.y)
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
		--backgroundMusicChannel = audio.play(deBoa, {channel=audio.findFreeChannel(), loops=-1})
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