local widget = require "widget"

local loader = {}

local screenLeft, screenWidth = display.screenOriginX, display.contentWidth
local centerX, centerY = display.contentCenterX, display.contentCenterY
local screenRight = screenWidth - screenLeft

loader.loadBen = function (mte)
	local benProperties = mte.getObject({name = "Ben"})

	local spriteSheet = graphics.newImageSheet("images/ben_sprite.png", {width = 50, height = 156, numFrames = 6})
	local sequenceData = {
			{name = "stoppedAhead", sheet = spriteSheet, frames = {3}, time = 200, loopCount = 0},
			{name = "stoppedBack", sheet = spriteSheet, frames = {6}, time = 200, loopCount = 0},
			{name = "walkAhead", sheet = spriteSheet, frames = {2, 1}, time = 300, loopCount = 0},
			{name = "walkBack", sheet = spriteSheet, frames = {5, 4}, time = 300, loopCount = 0}
	}

	local ben = display.newSprite(spriteSheet, sequenceData)
	local setup = {layer = 7, kind = "sprite", levelPosX = benProperties[1].x, levelPosY = benProperties[1].y}	
	mte.physics.addBody(ben, "dynamic", {friction = 0.2, bounce = 0.0, density = 1 })
	ben.isFixedRotation = true
	mte.addSprite(ben, setup)

	ben.jumping = false
	ben.jumpForce = -200

	return ben
end

loader.loadRen = function (mte)
	local renProperties = mte.getObject({name = "Ren"})

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

	ren.jumping = false
	ren.jumpForce = 200

	return ren
end

--TODO: load all enemies
loader.loadEnemies = function (mte)
	local raptorShapeHead = {-153, 101.5 , -166, 43.5 , -126, 10.5 , -89, 39.5 , -98, 101.5}
	local raptorShapeFootsBody = {55, -9.5 , 52, 46.5 , -89, 39.5 , -126, 10.5 , -103, -74.5 , -34, -102.5 , 34, -102.5}
	local raptorShapeTail = {113, 84.5 , 52, 46.5 , 55, -9.5 , 167, 81.5}

	local enemies = {}
	local enemiesProperties = mte.getObject({name = "Raptor1"})

	local spriteSheet = graphics.newImageSheet("images/raptor_sprite.png", {width = 333, height = 205, numFrames = 6})
	local sequenceData = {
			{name = "stoppedAhead", sheet = spriteSheet, frames = {1}, time = 200, loopCount = 0},
			{name = "stoppedBack", sheet = spriteSheet, frames = {4}, time = 200, loopCount = 0},
			{name = "walkAhead", sheet = spriteSheet, frames = {2, 3}, time = 300, loopCount = 0},
			{name = "walkBack", sheet = spriteSheet, frames = {5, 6}, time = 800, loopCount = 0}
	}

	local raptor = display.newSprite(spriteSheet, sequenceData)
	local setup = {layer = 3, kind = "sprite", levelPosX = enemiesProperties[1].x, levelPosY = enemiesProperties[1].y}

	local opt1 = {friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeHead}
	local opt2 = {friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeFootsBody}
	local opt3 = {friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeTail}

	mte.physics.addBody(raptor, "dynamic", opt1, opt2, opt3)
	raptor.isFixedRotation = true
	mte.addSprite(raptor, setup)

	raptor.initialX = raptor.x
	raptor:setSequence("walkBack")
	raptor:play()

	table.insert(enemies, raptor)

	return enemies
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

	return backBtn, aheadBtn, jumpBtn
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