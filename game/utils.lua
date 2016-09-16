local util = {}

util.toUpSideWorld = function (mte, ren, ben)
	local transitionTime = 2000

	mte.setCameraFocus(nil)
	mte.moveCameraTo({levelPosY = ren.y + 80, levelPosX = ren.x + 2, time = transitionTime})
	ben.gravityScale = 0
	ren.gravityScale = 1
	mte.physics.setGravity(0, -200)
	timer.performWithDelay(transitionTime, focusCameraInRen) 

	return ren
end

util.toCommonWorld = function (mte, ren, ben)
	local transitionTime = 2000

	mte.setCameraFocus(nil)
	mte.moveCameraTo({levelPosY = ben.y - 80, levelPosX = ben.x - 2, time = transitionTime})
	ren.gravityScale = 0
	ben.gravityScale = 1
	mte.physics.setGravity(0, 50)
	timer.performWithDelay(transitionTime, focusCameraInBen) 

	return ren
end

util.setInitialWorld = function(destinyId, mte, ben, ren)
	local currentChar = ben
	if(destinyId > 0) then
		--common world
		mte.setCameraFocus(nil)
		ren.gravityScale = 0
		ben.gravityScale = 1
		mte.physics.setGravity(0, 50)
		focusCameraInBen()
	else 
		mte.setCameraFocus(nil)
		ren.gravityScale = 1
		ben.gravityScale = 0
		mte.physics.setGravity(0, -200)
		focusCameraInRen()
		currentChar = ren
	end

	return currentChar
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