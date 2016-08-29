local composer = require("composer")
local scene = composer.newScene()
local widget = require "widget"

local function playAgain(event)
	composer.removeScene("gameover")
	composer.gotoScene("tutorial")
end

function scene:create(event)
	local sceneGroup = self.view
	img = display.newImageRect("images/gameover.png", display.contentWidth, display.contentHeight)
	img.x, img.y = display.contentCenterX, display.contentCenterY

	playAgainBtn = widget.newButton{
		label="Jogar novamente",
		width=100,
		onRelease = playAgain
	}
	playAgainBtn.x, playAgainBtn.y = display.contentCenterX, display.contentCenterY + 100

	sceneGroup:insert(playAgainBtn)
	sceneGroup:insert(img)
end

function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
	end
end

function scene:hide(event)
	print("eita")
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
		playAgainBtn:removeSelf()
		img:removeSelf()
		playAgain = nil	
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene