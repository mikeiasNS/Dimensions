local enemies_loader = {}

--[[
	> All enemies must have the following properties in Tiled
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
				Obs.: case not defined the default sequence_time defined in config file will be used 
		> 'sequence_name:loopCount' (opt) 
			'-> number of times that the sequence will happens when played : String
				Obs.: case not defined the default sequence_loopCount defined in config file will be used 
		> 'attackPower' (opt)
			'-> the damage that the attack will cause in other char : String 
		> 'hp' (opt)
			'-> The total HP of the enemy : String 

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
			local f = loadstring("return "..v)()
			local t = tonumber(properties.properties[sequenceName..":time"]) or 200
			local lc = tonumber(properties.properties[sequenceName..":loopCount"]) or 0

			table.insert(sequenceData, {name = sequenceName, sheet = spriteSheet, frames = f, time = t, loopCount = lc})
		end
	end

	local enemy = display.newSprite(spriteSheet, sequenceData)
	local x, y = properties.x + properties.width / 2, properties.y + properties.height / 2
	local setup = {layer = 3, kind = "sprite", levelPosX = x, levelPosY = y, offscreenPhysics = true}
	mte.physics.addBody(enemy, "dynamic", physicsData:get(properties.type))
	enemy.isFixedRotation = true
	mte.addSprite(enemy, setup)

	enemy.preCollision = enemies_loader.enemiesPreCollision
	enemy:addEventListener("preCollision")

	enemy.attackPower = properties.properties["attackPower"] or 1
	enemy.hp = properties.properties.hp or 100
	enemy.type = properties.type
	enemy.framesBySequenceAndShapes = {}
	for i, bodyShape in ipairs(physicsData[properties.type]) do
		for j, sequence in ipairs(bodyShape.applyToSequences) do
			if not enemy.framesBySequenceAndShapes[sequence] then
				enemy.framesBySequenceAndShapes[sequence] = {}
			end
			enemy.framesBySequenceAndShapes[sequence][i] = bodyShape.applyToSequenceFrameIndexes[j]
		end
	end


	return enemy
end

enemies_loader.enemiesPreCollision = function(self, event)
	local shape = event.selfElement
	if self.framesBySequenceAndShapes[self.sequence][shape] then
		if not enemies_loader.tableContains(self.framesBySequenceAndShapes[self.sequence][shape], self.frame) then
			event.contact.isEnabled = false
		end
	end
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