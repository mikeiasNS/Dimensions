local composer = require("composer")
local scene = composer.newScene()

local chapterName
local chapterScene

local function goToChapter() 
	local destiny = 1

	if string.find( chapterName, "Golgota" ) then 
		destiny = -1
	end

	local options = {
		effect = "fade",
		time = 500,
		params = {destinyId = destiny}
	}
	composer.removeScene("loader")
	composer.gotoScene(chapterScene, options)
end

function scene:create(event)
	local sceneGroup = self.view
	chapterName = event.params.chapter
	chapterScene = event.params.scene
	print(handleMove)
	local chapterImg = display.newImage("images/chaptersTitles/"..chapterName..".png")
	chapterImg.x, chapterImg.y = display.contentCenterX, display.contentCenterY

	local loaderSequenceData = {name = "unique", time = 500, frames = {1, 2, 3}}
	local loaderImageSheet = graphics.newImageSheet("images/loadSprite.png", {width = 33, height = 50, numFrames = 3})
	local loaderSprite = display.newSprite(loaderImageSheet, loaderSequenceData)
	loaderSprite.x, loaderSprite.y = chapterImg.x, chapterImg.y + chapterImg.height / 2
	loaderSprite:play()

	sceneGroup:insert(chapterImg)
	sceneGroup:insert(loaderSprite)
end

function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		timer.performWithDelay( 500, goToChapter)
		physics.start()
	end
end

function scene:hide(event)
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy(event)
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	scene:removeEventListener("create", scene)
	scene:removeEventListener("show", scene)
	scene:removeEventListener("hide", scene)
	scene:removeEventListener("destroy", scene)
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene