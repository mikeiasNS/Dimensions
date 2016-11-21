local chars = {}

chars.loadBen = function (objName)
	local benProperties = mte.getObject({name = objName})

	local spriteSheet = graphics.newImageSheet("images/ben_sprite.png", {width = 50, height = 156, numFrames = 6})
	local sequenceData = {
			{name = "stoppedAhead", sheet = spriteSheet, frames = {3}, time = 200, loopCount = 0, teste={0, 1}},
			{name = "stoppedBack", sheet = spriteSheet, frames = {6}, time = 200, loopCount = 0},
			{name = "walkAhead", sheet = spriteSheet, frames = {2, 1}, time = 300, loopCount = 0},
			{name = "walkBack", sheet = spriteSheet, frames = {5, 4}, time = 300, loopCount = 0}
	}

	local ben = display.newSprite(spriteSheet, sequenceData)
	local setup = {layer = mte.getSpriteLayer(1), kind = "sprite", levelPosX = benProperties[1].x, levelPosY = benProperties[1].y}	
	mte.physics.addBody(ben, "dynamic", {friction = 0.2, bounce = 0.0, density = 1})
	ben.isFixedRotation = true
	mte.addSprite(ben, setup)

	ben.jump = 0
	ben.jumpForce = -150
	ben.hp = 100
	ben.hpBonus = 0

	return ben
end

chars.loadRen = function (objName)
	local renProperties = mte.getObject({name = objName})

	local renSpriteSheet = graphics.newImageSheet("images/ren_sprite.png", {width = 50, height = 156, numFrames = 6})
	local renSequenceData = {
			{name = "stoppedAhead", sheet = renSpriteSheet, frames = {3}, time = 200, loopCount = 0},
			{name = "stoppedBack", sheet = renSpriteSheet, frames = {6}, time = 200, loopCount = 0},
			{name = "walkAhead", sheet = renSpriteSheet, frames = {2, 1}, time = 300, loopCount = 0},
			{name = "walkBack", sheet = renSpriteSheet, frames = {5, 4}, time = 300, loopCount = 0}
	}

	local ren = display.newSprite(renSpriteSheet, renSequenceData)
	local renSetup = {layer = mte.getSpriteLayer(1), kind = "sprite", levelPosX = renProperties[1].x, levelPosY = renProperties[1].y}	
	mte.physics.addBody(ren, "dynamic", {friction = 0.2, bounce = 0.0, density = 2 })
	ren.isFixedRotation = true
	mte.addSprite(ren, renSetup)

	ren.jump = 0
	ren.jumpForce = 0
	ren.hp = 100
	ren.hpBonus = 0

	return ren
end

return chars