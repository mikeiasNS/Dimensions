local composer = require( "composer" )
local scene = composer.newScene()
local widget = require "widget"
mte = require("MTE.mte").createMTE()
local loader = require("core.loaders.loader")
local util = require("core.misc.utils")
local constants = require("core.misc.constants")

display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )
system.activate("multitouch")
local ben, ren, enemies
local rain
local currentChar
local backBtn, aheadBtn, jumpBtn, attackBtn, gateBtn
local OdihnaBG = audio.loadStream("sound/de_boa.mp3")
local rainSound = audio.loadStream("sound/rain.mp3")
local laserSound = audio.loadSound("sound/laser1.wav")
local destinationObjName
local hpRect
local headStatusRect

--collision names
local benName = "ben"
local renName = "ren"
local groundName = "ground"

function focusCameraInRen()
	mte.setCameraFocus(ren, 0, 80)
end

function focusCameraInBen()
	mte.setCameraFocus(ben, 0, -80)
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
		print(event.phase)
		if event.phase == "began" then
			currentChar.hpBonus = -1
		else
			currentChar.hpBonus = 0
		end
	elseif string.find(event.other.name, "end") then
		util.restart(rain)
	end
end

local function setupStatus()
	if hpRect ~= nil then
		hpRect:removeSelf()
		headStatusRect:removeSelf()
	end
	currentChar.hp = currentChar.hp + currentChar.hpBonus

	hpRect = display.newRoundedRect(backBtn.x + 100, display.contentHeight - display.contentHeight * 0.87, currentChar.hp * 3, 30, 0)
	hpRect.anchorX = 0
	hpRect:setFillColor(1, 0, 0)

	local imgName = "images/headA.png"

	if string.find(currentChar.sequence, "Back") then
		imgName = "images/headB.png"
	end

	headStatusRect = display.newImageRect(imgName, 100, 100)
	headStatusRect.x , headStatusRect.y = backBtn.x + 20, hpRect.y
	headStatusRect:setFillColor(1, 1, 1)
	
	if currentChar.hp <= 0 then
		util.die(rain)
	end
end

function scene:create(event)
	local sceneGroup = self.view

	--ENABLE PHYSICS -----------------------------------------------------------------------
	mte.enableBox2DPhysics()
	mte.physics.start()
	--mte.physics.setDrawMode("hybrid")

	--LOAD SCENE -----------------------------------------------------------------------------
	loader.loadMap("maps/chapter1")
	mte.drawObjects()
	rain = loader.loadUpSideRain()
	objects = loader.loadObjects()

	--LOAD CHARS ---------------------------------------------------------------------------
	ren = loader.loadRen("Ren")
	ren.collision = onCharCollision
	ren:addEventListener("collision")
	ren.name = renName

	ben = loader.loadBen("Ben")
	ben.collision = onCharCollision
	ben:addEventListener("collision")
	ben.name = benName

	backBtn, aheadBtn, jumpBtn, attackBtn, gateBtn = loader.loadButtons()
	gateBtn.isVisible = false

	currentChar = util.setInitialWorld(event.params.destinyId, ben, ren)
	mte.update()
	setupStatus()

	loader.loadEnemies()

	for k,v in pairs(objects) do
		objects[k].gravityScale = 0
	end

	sceneGroup:insert(map)
	sceneGroup:insert(hpRect)
	sceneGroup:insert(aheadBtn)
	sceneGroup:insert(backBtn)
	sceneGroup:insert(jumpBtn)
	sceneGroup:insert(attackBtn)
	sceneGroup:insert(gateBtn)
end

function goAhead(event)
	util.goAhead(currentChar, event)
end

function goBack(event)
	util.goBack(currentChar, event)
end

function jump(event)
	util.jump(currentChar, event)
end

function fire(event)
	util.fire(currentChar, event)
end

function swapWorld(event)
	if event.phase == "began" then
		local otherChar = ben
		if currentChar.name == benName then
			otherChar = ren
		end

		currentChar, ben, ren = util.swapWorld(currentChar, otherChar, destinationObjName)
	end
end

function onWorldChanged(event) 
	audio.stop()
	gateBtn.isVisible = false
	if event.world == "Golgota" then
		audio.play(rainSound, {channel=audio.findFreeChannel(), loops=-1})
		attackBtn.isVisible = true
		jumpBtn.isVisible = false
		util.switchRain(rain, true)
	else
		audio.play(OdihnaBG, {channel=audio.findFreeChannel(), loops=-1})
		attackBtn.isVisible = false
		jumpBtn.isVisible = true
		util.switchRain(rain, false)
	end
end

function handleMove(event)	
	mte.update()
	setupStatus()
	if string.find(currentChar.sequence, "walk") then
		if(string.find(currentChar.sequence, "Ahead")) then 
			currentChar.x = currentChar.x + 5
		elseif (string.find(currentChar.sequence, "Back")) then
			currentChar.x = currentChar.x - 5
		end
	end
end

function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
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
	Runtime:removeEventListener(constants.eventNames.worldChanged, onWorldChanged)
	backBtn:removeSelf()
	jumpBtn:removeSelf()
	aheadBtn:removeSelf()
	headStatusRect:removeSelf()
	hpRect:removeSelf()
	backBtn, jumpBtn, aheadBtn = nil, nil, nil
	timer.performWithDelay(500, mte.cleanup)
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
Runtime:addEventListener("enterFrame", handleMove)
Runtime:addEventListener(constants.eventNames.worldChanged, onWorldChanged)

return scene