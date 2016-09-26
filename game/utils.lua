local util = {}

util.toUpSideWorld = function (mte, ren, ben, jumpBtn, attackBtn)
	local transitionTime = 2000

	mte.setCameraFocus(nil)
	mte.moveCameraTo({levelPosY = ren.y + 80, levelPosX = ren.x + 2, time = transitionTime})
	ben.gravityScale = 0
	ren.gravityScale = 1
	mte.physics.setGravity(0, -200)
	timer.performWithDelay(transitionTime, focusCameraInRen) 
	attackBtn.isVisible = true
	jumpBtn.isVisible = false
	audio.stop()

	return ren
end

util.toCommonWorld = function (mte, ren, ben, jumpBtn, attackBtn, st)
	local transitionTime = 2000

	mte.setCameraFocus(nil)
	mte.moveCameraTo({levelPosY = ben.y - 80, levelPosX = ben.x - 2, time = transitionTime})
	ren.gravityScale = 0
	ben.gravityScale = 1
	mte.physics.setGravity(0, 50)
	timer.performWithDelay(transitionTime, focusCameraInBen) 
	attackBtn.isVisible = false
	jumpBtn.isVisible = true
	audio.play(st, {channel=audio.findFreeChannel(), loops=-1})

	return ben
end

util.setInitialWorld = function(destinyId, mte, ben, ren, jumpBtn, attackBtn, stC, stU)
	local currentChar = ben
	if(destinyId > 0) then
		--common world
		ren.gravityScale = 0
		ben.gravityScale = 1
		mte.physics.setGravity(0, 50)
		focusCameraInBen()
		attackBtn.isVisible = false
		backgroundMusicChannel = audio.play(stC, {channel=audio.findFreeChannel(), loops=-1})
	else 
		ren.gravityScale = 1
		ben.gravityScale = 0
		mte.physics.setGravity(0, -200)
		focusCameraInRen()
		currentChar = ren
		jumpBtn.isVisible = false
		backgroundMusicChannel = audio.play(stU, {channel=audio.findFreeChannel(), loops=-1})
	end

	return currentChar
end

util.repositionChar = function(destinationObjName, mte, char)
	local newProperties = mte.getObject({name = destinationObjName})

	char.x = newProperties[1].x
	char.y = newProperties[1].y
end

util.tableContains = function(table, val) 
	for k, v in ipairs(table) do
		if(v == val) then
			return true
		end
	end
	return false
end

return util