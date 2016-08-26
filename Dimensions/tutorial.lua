local composer = require( "composer" )
local scene = composer.newScene()
local physics = require "physics"
local widget = require "widget"
local dusk = require("Dusk.Dusk")
local screen = require("Dusk.dusk_core.misc.screen")

local ben
local map

local benWalkingAhead, benWalkingBack, jumping = false, false, false

--collision names
local benName = "ben"
local groundName = "ground"

local function onBenCollision(self, event)
	if(event.other.name == groundName and event.phase == "began") then
		jumping = false
	end
end

function scene:create(event)

	physics.start()
	physics.pause()

	ben = display.newImage("images/ben.png")
	ben.anchorX, ben.anchorY = 0.5, 0.5
	ben.x = ben.width / 2
	ben.y = ben.height
	ben.name = "ben"
	ben.collision = onBenCollision
	ben:addEventListener("collision")
	physics.addBody(ben, {density = 1, friction = 0, bounce = 0})

	map = dusk.buildMap("maps/chapter1.json")
	map.layer["main"]:insert(ben)
	map.y = screen.height - map.height / 2
	map.rotation = 0
	initialMapX = map.x


	-- add buttons
	backBtn = widget.newButton{
		label="",
		defaultFile="images/back.png",
		width = display.contentHeight * 0.1, 
		height= display.contentHeight * 0.1, 
		onEvent = goBack
	}
	backBtn.x, backBtn.y = screen.left + display.contentHeight * 0.075, display.contentHeight - display.contentHeight * 0.1
	backBtn.alpha = 0.5

	aheadBtn = widget.newButton{
		label="",
		defaultFile="images/ahead.png",
		width = display.contentHeight * 0.1, 
		height= display.contentHeight * 0.1, 
		onEvent = goAhead
	}
	aheadBtn.x, aheadBtn.y = backBtn.x + (backBtn.width / 2) + display.contentWidth * 0.06, display.contentHeight - display.contentHeight * 0.07
	aheadBtn.alpha = 0.5

	jumpBtn = widget.newButton{
		label="",
		defaultFile="images/up.png",
		width = display.contentHeight * 0.1, 
		height= display.contentHeight * 0.1, 
		onPress = jump
	}
	jumpBtn.x, jumpBtn.y = screen.right - display.contentWidth * 0.08, (aheadBtn.y + backBtn.y) / 2
	jumpBtn.alpha = 0.5
end

function goAhead(event)
	if ( event.phase == "began" ) then
        benWalkingAhead = true
    elseif ( event.phase == "ended" and benWalkingAhead == true ) then
        benWalkingAhead = false
    end

    return true
end

function goBack(event)
	if ( event.phase == "began" ) then
        benWalkingBack = true
    elseif ( event.phase == "ended" and benWalkingBack == true ) then
        benWalkingBack = false
    end

    return true
end

function jump(event) 
	if (jumping == false) then
		jumping = true
		ben:applyLinearImpulse(0, -80, ben.x, ben.y)
	end
end

function handleMove(event)
	map.updateView()
	if(benWalkingAhead == true) then
		ben.x = ben.x + 5
	elseif (benWalkingBack == true) then
		if(map.x >= initialMapX and ben.x >= (ben.width / 2)) then
			ben.x = ben.x - 5
		end
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
		physics.start()
	end
end

function scene:hide(event)
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy(event)
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.	
	package.loaded[physics] = nil
	physics = nil		
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
Runtime:addEventListener("enterFrame", handleMove)

return scene