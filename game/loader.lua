local widget = require "widget"
local util = require ("utils")

local loader = {}

local screenLeft, screenWidth = display.screenOriginX, display.contentWidth
local centerX, centerY = display.contentCenterX, display.contentCenterY
local screenRight = screenWidth - screenLeft

loader.loadBen = function (mte, objName)
	local benProperties = mte.getObject({name = objName})

	local spriteSheet = graphics.newImageSheet("images/ben_sprite.png", {width = 50, height = 156, numFrames = 6})
	local sequenceData = {
			{name = "stoppedAhead", sheet = spriteSheet, frames = {3}, time = 200, loopCount = 0},
			{name = "stoppedBack", sheet = spriteSheet, frames = {6}, time = 200, loopCount = 0},
			{name = "walkAhead", sheet = spriteSheet, frames = {2, 1}, time = 300, loopCount = 0},
			{name = "walkBack", sheet = spriteSheet, frames = {5, 4}, time = 300, loopCount = 0}
	}

	local ben = display.newSprite(spriteSheet, sequenceData)
	local setup = {layer = 8, kind = "sprite", levelPosX = benProperties[1].x, levelPosY = benProperties[1].y}	
	mte.physics.addBody(ben, "dynamic", {friction = 0.2, bounce = 0.0, density = 1})
	ben.isFixedRotation = true
	mte.addSprite(ben, setup)

	ben.jump = 0
	ben.jumpForce = -200

	return ben
end

loader.loadRen = function (mte, objName)
	local renProperties = mte.getObject({name = objName})

	local renSpriteSheet = graphics.newImageSheet("images/ren_sprite.png", {width = 50, height = 156, numFrames = 6})
	local renSequenceData = {
			{name = "stoppedAhead", sheet = renSpriteSheet, frames = {3}, time = 200, loopCount = 0},
			{name = "stoppedBack", sheet = renSpriteSheet, frames = {6}, time = 200, loopCount = 0},
			{name = "walkAhead", sheet = renSpriteSheet, frames = {2, 1}, time = 300, loopCount = 0},
			{name = "walkBack", sheet = renSpriteSheet, frames = {5, 4}, time = 300, loopCount = 0}
	}

	local ren = display.newSprite(renSpriteSheet, renSequenceData)
	local renSetup = {layer = 3, kind = "sprite", levelPosX = renProperties[1].x, levelPosY = renProperties[1].y}	
	mte.physics.addBody(ren, "dynamic", {friction = 0.2, bounce = 0.0, density = 2 })
	ren.gravityScale = 0
	ren.isFixedRotation = true
	mte.addSprite(ren, renSetup)

	ren.jump = 0
	ren.jumpForce = 0

	return ren
end

--TODO: load all enemies
loader.loadEnemies = function (mte)
	local raptorShapeHeadB = {-153, 101.5 , -166, 43.5 , -126, 10.5 , -89, 39.5 , -98, 101.5}
	local raptorShapeFootsBodyB = {55, -9.5 , 52, 46.5 , -89, 39.5 , -126, 10.5 , -103, -74.5 , -34, -102.5 , 34, -102.5}
	local raptorShapeTailB = {113, 84.5 , 52, 46.5 , 55, -9.5 , 167, 81.5}
	local raptorShapeHeadA = {153, 101.5 , 166, 43.5 , 126, 10.5 , 89, 39.5 , 98, 101.5}
	local raptorShapeFootsBodyA = {-55, -9.5 , -52, 46.5 , 89, 39.5 , 126, 10.5 , 103, -74.5 , 34, -102.5 , -34, -102.5}
	local raptorShapeTailA = {-113, 84.5 , -52, 46.5 , -55, -9.5 , -167, 81.5}


	local enemies = {}
	local enemiesProperties = mte.getObject({name = "Raptor1"})

	local spriteSheet = graphics.newImageSheet("images/raptor_sprite.png", {width = 333, height = 205, numFrames = 6})
	local sequenceData = {
			{name = "stoppedAhead", sheet = spriteSheet, frames = {1}, time = 200, loopCount = 0},
			{name = "stoppedBack", sheet = spriteSheet, frames = {4}, time = 200, loopCount = 0},
			{name = "walkAhead", sheet = spriteSheet, frames = {2, 3}, time = 300, loopCount = 0},
			{name = "walkBack", sheet = spriteSheet, frames = {5, 6}, time = 800, loopCount = 0}
	}

	walkAheadTable = {{1, 2, 3}, {1, 2, 3}}
	walkBackTable = {{4, 5, 6}, {4, 5, 6}}

	local raptor = display.newSprite(spriteSheet, sequenceData)
	local setup = {layer = 3, kind = "sprite", levelPosX = enemiesProperties[1].x, levelPosY = enemiesProperties[1].y}

	local opt1A = {friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeHeadA}
	local opt2A = {friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeFootsBodyA}
	local opt3A = {friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeTailA}
	local opt1B = {friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeHeadB}
	local opt2B = {friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeFootsBodyB}
	local opt3B = {friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeTailB}

	mte.physics.addBody(raptor, "dynamic", opt1A, opt2A, opt3A, opt1B, opt2B, opt3B)
	raptor.isFixedRotation = true
	mte.addSprite(raptor, setup)

	raptor.initialX = raptor.x
	raptor.preCollision = loader.enemiesPreCollision
	raptor.shapesBySequenceAndFrame = {}
	raptor.shapesBySequenceAndFrame["stoppedAhead"] = walkAheadTable
	raptor.shapesBySequenceAndFrame["stoppedBack"] = walkBackTable
	raptor.shapesBySequenceAndFrame["walkAhead"] = walkAheadTable
	raptor.shapesBySequenceAndFrame["walkBack"] = walkBackTable
	raptor:addEventListener("preCollision")
	raptor:setSequence("walkBack")
	raptor:play()

	table.insert(enemies, raptor)

	return enemies
end

loader.enemiesPreCollision = function(self, event)
	for seq, frameShapes in pairs(self.shapesBySequenceAndFrame) do
		--print(seq)
		if(seq == self.sequence) then
			if(not util.tableContains(frameShapes[self.frame], event.selfElement)) then
				event.contact.isEnabled = false
			end
		end
	end
end

loader.loadButtons = function ()
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

	attackBtn = widget.newButton{
		label="",
		defaultFile="images/attack.png",
		width = display.contentHeight * 0.15, 
		height= display.contentHeight * 0.15, 
		onPress = fire
	}
	attackBtn.x, attackBtn.y = jumpBtn.x, jumpBtn.y
	attackBtn.alpha = 0.5

	gateBtn = widget.newButton{
		label="",
		defaultFile="images/portal.png",
		width = display.contentHeight * 0.15, 
		height= display.contentHeight * 0.15, 
		onPress = swapWorld
	}
	gateBtn.x, gateBtn.y = display.contentCenterX, jumpBtn.y
	gateBtn.alpha = 0.5

	return backBtn, aheadBtn, jumpBtn, attackBtn, gateBtn
end

loader.loadMenuButtons = function ()
	playBen = widget.newButton{
		label="Play Ben",
		onEvent = playWithBen
	}
	playBen.x, playBen.y = centerX, centerY - playBen.contentHeight

	playRen = widget.newButton{
		label="Play Ren",
		onEvent = playWithRen
	}
	playRen.x, playRen.y = centerX, centerY + playRen.contentHeight

	return playBen, playRen
end

loader.loadMap = function (mapPath, mte)
	mte.toggleWorldWrapX(false)
	mte.toggleWorldWrapY(false)
	mte.loadMap(mapPath)
	local blockScale = 33
	map = mte.setCamera({blockScale = blockScale})
	mte.constrainCamera()
end


return loader