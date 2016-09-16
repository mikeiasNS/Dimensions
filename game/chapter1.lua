local composer = require( "composer" )
local scene = composer.newScene()
local physics = require "physics"

--display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )
system.activate("multitouch")
local mte = require("MTE.mte").createMTE()
local loader = require("loader")
local util = require("utils")
local ben, ren, enemies

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

function focusCameraInRen()
	mte.setCameraFocus(ren, 0, 80)
end

function focusCameraInBen()
	mte.setCameraFocus(ben, 0, -80)
end

function updateEnemy(event)
	--if(enemies[1].x >= enemies[1].initialX + 60) then
		-- go back
		enemies[1].x = enemies[1].x - 10
		if(not enemies[1].isPlaying) then
			enemies[1]:setSequence("walkBack")
			enemies[1]:play()
		end
	--elseif(enemies[1].x <= enemies[1].initialX - 60) then
		-- go ahead
	--	enemies[1]:setSequence("walkAhead")
	--	enemies[1].x = enemies[1].x + 15
	--end
end

function scene:create(event)
	local sceneGroup = self.view

	--ENABLE PHYSICS -----------------------------------------------------------------------
	mte.enableBox2DPhysics()
	mte.physics.start()
	mte.physics.setDrawMode("hybrid")

	--LOAD MAP -----------------------------------------------------------------------------
	loader.loadMap("maps/chapter1.tmx", mte) 
	mte.addPropertyListener("name", onNameProperty)
	mte.drawObjects()

	--LOAD CHARS ---------------------------------------------------------------------------
	ren = loader.loadRen(mte)
	ren.collision = onCharCollision
	ren:addEventListener("collision")
	ren.name = renName

	ben = loader.loadBen(mte)
	ben.collision = onCharCollision
	ben:addEventListener("collision")
	ben.name = benName

	currentChar = util.setInitialWorld(event.params.destinyId, mte, ben, ren)
	mte.update()

	--LOAD ENEMIES -------------------------------------------------------------------------
	enemies = loader.loadEnemies(mte)
	--enemies[1].preCollision = enemiesPreCollision
	--enemies[1]:addEventListener("preCollision")
	timer.performWithDelay(200, updateEnemy, -1)

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