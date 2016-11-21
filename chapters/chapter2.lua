function scene:create(event)
	local sceneGroup = self.view
	--ENABLE PHYSICS -----------------------------------------------------------------------
	mte.enableBox2DPhysics()
	mte.physics.start()
	--mte.physics.setDrawMode("hybrid")

	--LOAD SCENE -----------------------------------------------------------------------------
	loader.loadMap("maps/chapter2")
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

	backBtn, aheadBtn, jumpBtn, attackBtn, gateBtn, pauseBtn = loader.loadButtons()
	gateBtn.isVisible = false

	currentChar = util.setInitialWorld(event.params.destinyId, ben, ren)
	mte.update()
	setupStatus()

	enemies = loader.loadEnemies()

	for k,v in pairs(objects) do
		objects[k].gravityScale = 0
	end

	map:addEventListener("dialog", dialogListener)
    
    if currentChar.name == renName then
        local event = { name="dialog", id="ren_initial" }
        map:dispatchEvent(event)
    end

	sceneGroup:insert(map)
	sceneGroup:insert(hpRect)
	sceneGroup:insert(aheadBtn)
	sceneGroup:insert(backBtn)
	sceneGroup:insert(jumpBtn)
	sceneGroup:insert(attackBtn)
	sceneGroup:insert(gateBtn)
	sceneGroup:insert(pauseBtn)
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
	headStatusRect, hpRect = nil, nil
	backBtn, jumpBtn, aheadBtn = nil, nil, nil
	util.switchRain(rain, false)
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
Runtime:addEventListener("enterFrame", handleMove)
Runtime:addEventListener(constants.eventNames.worldChanged, onWorldChanged)

return scene