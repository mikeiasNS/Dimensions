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
	local setup = {layer = 6, kind = "sprite", levelPosX = benProperties[1].x, levelPosY = benProperties[1].y}	
	mte.physics.addBody(ben, "dynamic", {friction = 0.2, bounce = 0.0, density = 1})
	ben.isFixedRotation = true
	mte.addSprite(ben, setup)

	ben.jump = false
	ben.jumpForce = -150

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

loader.loadObjects = function(mte)
	local objProperties = mte.getObject({name = "sceneObj"})
	local objects = {}

	for k,v in pairs(objProperties) do
		print(k, v)
		local w, h = objProperties[k].width, objProperties[k].height
		local numFrames = objProperties[k].properties.numFrames or 1
		local path = objProperties[k].properties.path
		local bodyType = objProperties[k].properties.bodyType or "static"
		local offscreenPhysics = objProperties[k].properties.offscreenPhysics or false
		local layer = objProperties[k].layer
		local count = objProperties[k].properties.count or 1
		local time = objProperties[k].properties.time or 0
		local id = objProperties[k].properties.id or objProperties[k].properties.name
		local bounce = objProperties[k].properties.bounce or 0
		local density = objProperties[k].properties.density or 0

		local objSpriteSheet = graphics.newImageSheet(path, {width = w, height = h, numFrames = numFrames})
		local seqData = {name="default", start=1, count=count, time=time}
		local obj = display.newSprite(objSpriteSheet, seqData)

		local objX, objY = objProperties[k].x + obj.width/2, objProperties[k].y + obj.height/2
		local objSetup = {  layer = layer, kind = "sprite", 
							levelPosX = objX, levelPosY = objY, 
							offscreenPhysics = offscreenPhysics  }

		mte.physics.addBody(obj, bodyType, {bounce=bounce, density=density})
	 	mte.addSprite(obj, objSetup)

	 	obj.name = objProperties[k].properties.name
	 	obj.type = objProperties[k].type
	 	obj.id = id

	 	if objProperties[k].properties.disableCollideTo then
	 		obj.disableCollideTo = objProperties[k].properties.disableCollideTo
	 		obj.preCollision = loader.macgyver
			obj:addEventListener("preCollision")
	 	end

	 	objects[obj.id] = obj
	end

	return objects
end

loader.macgyver = function(self, event)
	if(event.other.name == self.disableCollideTo) then
		if event.contact then
			event.contact.isEnabled = false
		end
	end
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
	mte.loadMap(mapPath .. ".tmx")
	local blockScale = 33
	map = mte.setCamera({blockScale = blockScale})
	mte.constrainCamera()

	local backdrop = display.newImageRect(mapPath .. "BG.png", 3200, 3840)
	local setup = {layer = 1, levelWidth = 3200, levelHeight = 3840, kind = "imageRect", locX=50.5, locY=60.5}
	mte.addSprite(backdrop, setup)
end

loader.loadUpSideRain = function(mte)
	local physics = mte.physics
	local physicsVentGroup = CBE.newVentGroup({
		{
			title = "rain1", -- Though the preset already names the vent "snow", always title!
			preset = "rain",
			alpha = 0.5,
			build = function()
				return display.newRect(0, 0, 2, 80)
			end,
			onVentInit = function(v)
				v:setMovementScale(0) -- Make the vent's internal movement scale zero, which means particles will not be moved by the vent
			end,
			onCreation = function(p, v)
				physics.addBody(p, {density = 55, radius = p.width * 0.5})
				p.rotation = 310
				p.isFixedRotation = true
				p:applyLinearImpulse(-5, -5)
			end
		},

		{
			title = "rain2", -- Though the preset already names the vent "snow", always title!
			preset = "rain",
			alpha = 0.5,
			build = function()
				return display.newRect(0, 0, 2, 50)
			end,
			onVentInit = function(v)
				v:setMovementScale(0) -- Make the vent's internal movement scale zero, which means particles will not be moved by the vent
			end,
			onCreation = function(p, v)
				physics.addBody(p, {density = 50, radius = p.width * 0.5})
				p.rotation = 310
				p.isFixedRotation = true
				p:applyLinearImpulse(-5, -5)
			end
		}
	})

	physicsVentGroup:move("rain1", display.contentCenterX, display.contentHeight + 100)
	physicsVentGroup:move("rain2", 0, display.contentHeight + 100)
end
return loader