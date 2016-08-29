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
local ben

local benWalkingAhead, benWalkingBack, jumping = false, false, false

local screenLeft, screenWidth = display.screenOriginX, display.contentWidth
local screenRight = screenWidth - screenLeft

--collision names
local benName = "ben"
local groundName = "ground"

local function die()
	local options = {
		effect = "fade",
		time = 500,
		params = {}
	}
	composer.removeScene("tutorial")
	composer.gotoScene("gameover")
end

local function onBenCollision(self, event)
	if(event.other.name == groundName and event.phase == "began") then
		jumping = false
	elseif(event.other.name == "water") then
		die()
	end
end

local onNameProperty = function(event)
    event.target.name = event.propValue
end

function scene:create(event)
	print("opa")
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
	local blockScale = 33
	local locX = 18
	local locY = 30.6
	map = mte.setCamera({locX = locX, locY = locY, blockScale = blockScale})
	mte.constrainCamera() 

	local spriteSheet = graphics.newImageSheet("images/ben_sprite.png", {width = 50, height = 156, numFrames = 6})
	local sequenceData = {
			{name = "stoppedAhead", sheet = spriteSheet, frames = {1}, time = 200, loopCount = 0},
			{name = "stoppedBack", sheet = spriteSheet, frames = {4}, time = 200, loopCount = 0},
			{name = "walkAhead", sheet = spriteSheet, frames = {2, 3}, time = 300, loopCount = 0},
			{name = "walkBack", sheet = spriteSheet, frames = {5, 6}, time = 300, loopCount = 0}
	}

	ben = display.newSprite(spriteSheet, sequenceData)
	local setup = {layer = mte.getSpriteLayer(1), kind = "sprite", locX = 5, locY = locY}	
	ben.collision = onBenCollision
	ben:addEventListener("collision")

	mte.addSprite(ben, setup)
	mte.setCameraFocus(ben, 0, -80)
	mte.update()
	mte.physics.addBody(ben, "dynamic", {friction = 0.2, bounce = 0.0, density = 1, filter = { categoryBits = 1, maskBits = 1 } })
	ben.isFixedRotation = true

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
        benWalkingAhead = true
        ben:setSequence( "walkAhead" )
        ben:play()
    elseif (event.phase == "ended" or event.phase == "cancelled") then
        benWalkingAhead = false
        ben:setSequence( "stoppedAhead" )
        ben:play()
    end

    return true
end

function goBack(event)
	if (event.phase == "began") then
        benWalkingBack = true
        ben:setSequence( "walkBack" )
        ben:play()
    elseif (event.phase == "ended" or event.phase == "cancelled") then
        benWalkingBack = false
        ben:setSequence( "stoppedBack" )
        ben:play()
    end

    return true
end

function jump(event) 
	if (not jumping) then
		jumping = true
		ben:applyLinearImpulse(0, -200, ben.x, ben.y)
	end
end

function handleMove(event)	
	mte.update()
	if(benWalkingAhead) then 
		ben.x = ben.x + 5
	elseif (benWalkingBack == true) then
		ben.x = ben.x - 5
	end
end

function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
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
		scene:removeEventListener("create", scene)
		scene:removeEventListener("show", scene)
		scene:removeEventListener("hide", scene)
		scene:removeEventListener("destroy", scene)
		Runtime:removeEventListener("enterFrame", handleMove)
		backBtn:removeSelf()
		jumpBtn:removeSelf()
		aheadBtn:removeSelf()
		backBtn, jumpBtn, aheadBtn = nil, nil, nil
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
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
Runtime:addEventListener("enterFrame", handleMove)

return scene