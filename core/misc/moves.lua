local constants = require ("core.misc.constants")
local objNames = constants.objNames

local moves = {}

moves.goAhead = function(currentChar, event)
	if ( event.phase == "began" ) then
        currentChar:setSequence( "walkAhead" )
        currentChar:play()
    elseif (event.phase == "ended" or event.phase == "cancelled") then
        currentChar:setSequence( "stoppedAhead" )
        currentChar:play()
    end
end

moves.goBack = function(currentChar, event)
	if (event.phase == "began") then
        currentChar:setSequence( "walkBack" )
        currentChar:play()
    elseif (event.phase == "ended" or event.phase == "cancelled") then
        currentChar:setSequence( "stoppedBack" )
        currentChar:play()
    end
end

moves.jump = function(currentChar, event) 
	if(currentChar.jump < 2) then
		currentChar.jump = currentChar.jump + 1
		currentChar:applyLinearImpulse(0, currentChar.jumpForce, currentChar.x, currentChar.y)
	end
end

moves.fire = function(currentChar, event)
	local spriteSheet = graphics.newImageSheet("images/laser.png", {width = 35, height = 10, numFrames = 1})

	local laser = display.newSprite(spriteSheet, {name="default", frames={1}})
	mte.physics.addBody(laser, "dynamic", {friction = 0.2, bounce = 0.0, density = 1})
	local laserX, laserY, velX = 0, currentChar.y, 0

	if string.find(currentChar.sequence, "Ahead") then
		laserX = currentChar.x + currentChar.width/2 + 6
		velX = 500
	else 
		laserX = currentChar.x - (currentChar.width/2 + 6)
		velX = -500
	end

	local setup = {layer = 3, kind = "sprite", 
					levelPosX = laserX,
					levelPosY = laserY,
					offscreenPhysics = true }

	mte.addSprite(laser, setup)
	laser.gravityScale = 0
	laser:setLinearVelocity(velX, 0)
	laser.collision = moves.onLaserCollision
	laser:addEventListener("collision")
end

moves.onLaserCollision = function(self, event)
	if event.other.name ~= objNames.ren and event.other.name ~= objNames.ben then
		self:removeSelf()
		if event.other.x <= mte.getCamera().levelPosX + display.contentHeight then
			if event.other.type == "destructible" then
				event.other:removeSelf()
			end

			if event.other.name == "crate" then
				objects["guard"]:removeSelf()
			elseif event.other.name == "chain" then
				objects["crate"]:setLinearVelocity(0, 300)
				objects["totemToBen2"]:removeSelf()

				objects["totemToDown"]:setLinearVelocity(0, -300)
				objects["totemToDown"].isFixedRotation = true
			end
		end
	end
end

return moves