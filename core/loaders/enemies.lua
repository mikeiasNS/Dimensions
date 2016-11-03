local enemies_loader = {}

--[[
	> Enemies properties on Tiled
		> 'spriteImagePath'
			'-> The path for the sprite image :p : String
		> 'numFrames'
			'-> Total number of frames in the sprite image : String
		> 'sequence:sequence_name'
			'-> Array of frames to the sequence : String
			'-> A same object can have multi sequences
					Ex.: sequence:walkingAhead | {1,2,3} 
						sequence:walkingBack | {4,5,6}
		> 'sequence_name:time' (opt) 
			'-> Time of the sequence : String
				Obs.: case not defined the default sequence_time 200 will be used 
		> 'sequence_name:loopCount' (opt) 
			'-> number of times that the sequence will happens when played : String
				Obs.: case not defined the default sequence_loopCount 0 will be used 
		> 'attackPower' (opt)
			'-> the damage that the attack will cause in other char : String 
		> 'hp' (opt)
			'-> The total HP of the enemy : String 
		> 'moveLoop' (opt)
			'-> A table with the distance to move relative with the initial postion
				Obs.: This table must have the format {left, up, right, bottom}
		> 'moveSequence' (opt)
			'-> A table with the name of the sequences to be applied in each movimentation
				Obs.: the same format of moveLoop, must to be seted if moveLoop be

	> Enemies can't have the preCollision function overwritten.
	> They have to receive the Name 'Enemy' in Tiled, and the type of your enemy to be loaded in EnemyByProperties function.
	> The Tiled object must have tha same size of the sprite frames
]]

local physicsData = require("core.loaders.physicsData")

enemies_loader.loadEnemies = function ()
	local enemies = {}
	local enemiesProperties = mte.getObject({name = "Enemy"})

	for k, currentEnemy in pairs(enemiesProperties) do
		local enemy = enemies_loader.enemyByProperties(currentEnemy)
		table.insert(enemies, enemy)
	end

	return enemies
end

enemies_loader.enemyByProperties = function(properties) 
	local path = properties.properties.spriteImagePath
	local w, h, f = properties.width, properties.height, tonumber(properties.properties.numFrames)
	local spriteSheet = graphics.newImageSheet(path, {width = w, height = h, numFrames = f})
	local sequenceData = {}

	for k, v in pairs(properties.properties) do
		if string.find(k, "sequence:") then
			local sequenceName = string.sub(k, 10)
			local f = loadstring("return "..v)() -- sequence frames
			local t = tonumber(properties.properties[sequenceName..":time"]) or 200 -- sequence time
			local lc = tonumber(properties.properties[sequenceName..":loopCount"]) or 0 -- sequence loopcount

			table.insert(sequenceData, {name = sequenceName, sheet = spriteSheet, frames = f, time = t, loopCount = lc})
		end
	end

	local enemy = display.newSprite(spriteSheet, sequenceData)
	local x, y = properties.x + properties.width / 2, properties.y + properties.height / 2
	local setup = {layer = 3, kind = "sprite", levelPosX = x, levelPosY = y, offscreenPhysics = true}

	enemyPhysics = physicsData:get(properties.type) or {friction = 0.2, bounce = 0.0, density = 1}

	mte.physics.addBody(enemy, "dynamic", enemyPhysics)
	enemy.isFixedRotation = true
	mte.addSprite(enemy, setup)

	enemy.preCollision = enemies_loader.enemiesPreCollision
	enemy:addEventListener("preCollision")

	enemy.attackPower = properties.properties["attackPower"] or 1
	enemy.hp = properties.properties.hp or 100
	enemy.type = properties.type
	enemy.framesBySequenceAndShapes = {}
	enemy.name = properties.name

	local moveLoopStr = properties.properties["moveLoop"] or "{}"
	local moveSequencesStr = properties.properties["moveSequences"] or "{}"
	enemy.moveLoop = loadstring("return "..moveLoopStr)()
	enemy.moveSequences = loadstring("return "..moveSequencesStr)()
	enemy.initialPosition = {x, y}
	enemy.stepValue = properties.properties.stepValue or 10
	enemy.flyStepValue = properties.properties.flyStepValue or 0

	local canFollow = properties.properties.canFollow or "nil"
	local followInX = properties.properties.followInX or "nil"
	local followInY = properties.properties.followInY or "nil"

	enemy.canFollow = loadstring("return "..canFollow)() or true
	enemy.followInX = loadstring("return "..followInX)() or true
	enemy.followInY = loadstring("return "..followInY)() or false

	enemy.dead = false

	enemy:setSequence( properties.properties["firstSequence"] )

	if physicsData[properties.type] then
		for i, bodyShape in ipairs(physicsData[properties.type]) do
			if bodyShape.applyToSequences then
				for j, sequence in ipairs(bodyShape.applyToSequences) do
					if not enemy.framesBySequenceAndShapes[sequence] then
						enemy.framesBySequenceAndShapes[sequence] = {}
					end
					enemy.framesBySequenceAndShapes[sequence][i] = bodyShape.applyToSequenceFrameIndexes[j]
				end
			end
		end
	end

	return enemy
end

enemies_loader.enemiesPreCollision = function(self, event)
	local shape = event.selfElement

	if self.framesBySequenceAndShapes[self.sequence] then
		if self.framesBySequenceAndShapes[self.sequence][shape] then
			if not enemies_loader.tableContains(self.framesBySequenceAndShapes[self.sequence][shape], self.frame) then
				event.contact.isEnabled = false
			end
		end
	end
end

enemies_loader.updateEnemies = function(enemies, player) 
	for i, enemy in ipairs(enemies) do
		enemies_loader.updateEnemy(enemy, player)
	end
end

enemies_loader.updateEnemy = function(enemy, player)
	if enemy.dead then
		return
	end

	if enemy.hp <= 0 then 
		enemy.dead = true
		enemy:removeSelf()
	end

	local currentSequence = enemy.sequence
	local initialX = enemy.initialPosition[1]
	local initialY = enemy.initialPosition[2]

	local camX, camY = mte.getCamera().levelPosX, mte.getCamera().levelPosY
	local screenW, screenH = display.contentWidth, display.contentHeight;

	local startCamX, startCamY = camX - screenW / 2, camY - screenH / 2;

	local isEnemyOnScreen = enemy.x > startCamX and enemy.x < startCamX + screenW

	local canFollow = enemy.canFollow

	if player.jump > 0 then
		canFollow = false
	end

	if isEnemyOnScreen and canFollow then
		-- follow player
		if player.x < enemy.x and enemy.followInX then
			--follow left
			enemy:setSequence(enemy.moveSequences[1])
			enemy.x = enemy.x - enemy.stepValue
		elseif player.x > enemy.x and enemy.followInX then
			--follow right
			enemy:setSequence(enemy.moveSequences[3])
			enemy.x = enemy.x + enemy.stepValue
		end

		if player.y > enemy.y and enemy.followInY then
			--follow up
			enemy:setSequence(enemy.moveSequences[2])
			enemy.y = enemy.y + enemy.flyStepValue
		elseif player.y < enemy.y and enemy.followInY then
			--follow down
			enemy:setSequence(enemy.moveSequences[4])
			enemy.y = enemy.y - enemy.flyStepValue
		end
	else
		-- movimentation loop
		if currentSequence == enemy.moveSequences[1] then --go left
			if (enemy.x - enemy.stepValue) >= (initialX - enemy.moveLoop[1])  then
				enemy.x = enemy.x - enemy.stepValue
			else
				enemy:setSequence(enemy.moveSequences[3])
			end
		elseif currentSequence == enemy.moveSequences[3] then --go right
			if (enemy.x + enemy.stepValue) <= (initialX + enemy.moveLoop[3])  then
				enemy.x = enemy.x + enemy.stepValue
			else
				enemy:setSequence(enemy.moveSequences[1])
			end
		elseif currentSequence == enemy.moveSequences[2] then --go up
			if (enemy.y + enemy.flyStepValue) <= (initialY + enemy.moveLoop[2])  then
				enemy.y = enemy.y + enemy.flyStepValue
			else
				enemy:setSequence(enemy.moveSequences[4])
			end
		elseif currentSequence == enemy.moveSequences[4] then --go bottom
			if (enemy.y - enemy.flyStepValue) >= (initialY - enemy.moveLoop[4])  then
				enemy.y = enemy.y - enemy.flyStepValue
			else
				enemy:setSequence(enemy.moveSequences[2])
			end
		end
	end

	enemy:play()
end

enemies_loader.tableContains = function(table, val) 
	for k, v in ipairs(table) do
		if(v == val) then
			return true
		end
	end
	return false
end

return enemies_loader