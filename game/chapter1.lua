local composer = require( "composer" )
local scene = composer.newScene()
local widget = require "widget"

--display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )
system.activate("multitouch")
local mte = require("MTE.mte").createMTE()
local loader = require("loader")
local util = require("utils")
local ben, ren, enemies

local currentChar

local playerWalkingAhead, playerWalkingBack = false, false
local backBtn, aheadBtn, jumpBtn, attackBtn, gateBtn

local deBoa = audio.loadStream("sound/de_boa.wav")
local eita = audio.loadStream("sound/eita.wav")
local laser = audio.loadSound("sound/laser1.wav")

local backGroundEitaChannel, backgroundMusicChannel

local destinationObjName

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
	composer.removeScene("chapter1")
	composer.gotoScene("gameover", options)
end

local function restart()
	audio.stop()

	mte.physics.setGravity(0, 0)
	local options = {
		effect = "fade",
		time = 500,
		params = {}
	}
	composer.removeScene("chapter1")
	composer.gotoScene("menu", options)
end

local function onCharCollision(self, event)
	if(event.other.name == groundName and event.phase == "began") then
		currentChar.jump = 0
	elseif(string.find(event.other.name, "totem") and event.target.name == benName and event.phase == "began") then
		destinationObjName = string.match(event.other.name, "R..%d")
		gateBtn.isVisible = true
	elseif(string.find(event.other.name, "totem") and event.target.name == renName and event.phase == "began") then
		destinationObjName = string.match(event.other.name, "B..%d")
		gateBtn.isVisible = true
	elseif event.other.name == "death" then
		die()
	elseif string.find(event.other.name, "end") then
		restart()
	end
end

local function onLaserCollision(self, event)
	if event.other.name ~= currentChar.name then
		self:removeSelf()
		if event.other.x <= mte.getCamera().levelPosX + display.contentHeight then
			if event.other.name == "crate1" then
				event.other:removeSelf()
				objects[4]:removeSelf()
			elseif event.other.name == "chain1" then
				event.other:removeSelf()
				--subir[1, 6] e descer[2] as parada
				objects[7]:setLinearVelocity(0, 300)
				objects[1]:removeSelf()

				objects[2]:setLinearVelocity(0, -300)
				objects[2].isFixedRotation = true
			end
		end
	end
end

local function macgyver(self, event)
	if(event.other.name == objects[1].name or event.other.name == objects[6].name) then
		if event.contact then
			event.contact.isEnabled = false
		end
	end
end

local onNameProperty = function(event)
    event.target.name = event.propValue
end

function focusCameraInRen()
	mte.setCameraFocus(ren, 0, 80)
end

function focusCameraInBen()
	mte.setCameraFocus(ben, 0, -80)
end

function scene:create(event)
	local sceneGroup = self.view

	--ENABLE PHYSICS -----------------------------------------------------------------------
	mte.enableBox2DPhysics()
	mte.physics.start()
	mte.enableTileFlipAndRotation()
--	mte.physics.setDrawMode("hybrid")

	--LOAD MAP -----------------------------------------------------------------------------
	loader.loadMap("maps/chapter1.tmx", mte) 
	mte.addPropertyListener("name", onNameProperty)
	objects = mte.drawObjects()

	--LOAD CHARS ---------------------------------------------------------------------------
	ren = loader.loadRen(mte, "Ren")
	ren.collision = onCharCollision
	ren:addEventListener("collision")
	ren.name = renName

	ben = loader.loadBen(mte, "Ben")
	ben.collision = onCharCollision
	ben:addEventListener("collision")
	ben.name = benName

	backBtn, aheadBtn, jumpBtn, attackBtn, gateBtn = loader.loadButtons()
	gateBtn.isVisible = false

	currentChar = util.setInitialWorld(event.params.destinyId, mte, ben, ren, jumpBtn, attackBtn)
	mte.update()

	for k,v in pairs(objects) do
		objects[k].gravityScale = 0
		print(k, objects[k].name)
	end
	objects[1].preCollision = macgyver
	objects[1]:addEventListener("preCollision")
	objects[7].preCollision = macgyver
	objects[7]:addEventListener("preCollision")

	sceneGroup:insert(map)
	sceneGroup:insert(aheadBtn)
	sceneGroup:insert(backBtn)
	sceneGroup:insert(jumpBtn)
	sceneGroup:insert(attackBtn)
	sceneGroup:insert(gateBtn)
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
	if(currentChar.jump < 2) then
		currentChar.jump = currentChar.jump + 1
		currentChar:applyLinearImpulse(0, currentChar.jumpForce, currentChar.x, currentChar.y)
	end
end

function fire(event)
	audio.play(laser)
	local spriteSheet = graphics.newImageSheet("images/laser.png", {width = 35, height = 10, numFrames = 1})

	local laser = display.newSprite(spriteSheet, {name="default", frames={1}})
	mte.physics.addBody(laser, "dynamic", {friction = 0.2, bounce = 0.0, density = 1})
	local setup = {layer = 3, kind = "sprite", 
					levelPosX = currentChar.x + currentChar.width/2 + 6, 
					levelPosY = currentChar.y,
					offscreenPhysics = true }

	mte.addSprite(laser, setup)
	laser.gravityScale = 0
	--laser.isBullet = true
	laser:setLinearVelocity( 500, 0 )
	laser.collision = onLaserCollision
	laser:addEventListener("collision")

end

function swapWorld(event)
	print(destinationObjName)
	if event.phase == "began" then
		if currentChar == ben then
			mte.removeSprite(ren, true)
			ren = loader.loadRen(mte, destinationObjName)
			ren.collision = onCharCollision
			ren:addEventListener("collision")
			ren.name = renName

			currentChar = util.toUpSideWorld(mte, ren, ben, jumpBtn, attackBtn)
		else
			mte.removeSprite(ben, true)
			ben = loader.loadBen(mte, destinationObjName)
			ben.collision = onCharCollision
			ben:addEventListener("collision")
			ben.name = benName

			currentChar = util.toCommonWorld(mte, ren, ben, jumpBtn, attackBtn)
		end
	end
	gateBtn.isVisible = false
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
		--backgroundMusicChannel = audio.play(deBoa, {channel=audio.findFreeChannel(), loops=-1})
	elseif phase == "did" then
	end
end

function scene:hide(event)
	local phase = event.phase
	
	if phase == "will" then
	elseif phase == "did" then
	end	
end

function scene:destroy(event)
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