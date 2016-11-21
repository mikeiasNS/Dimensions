local composer = require( "composer" )
local scene = composer.newScene()
local loader = require("core.loaders.loader")

function scene:create(event)
	local sceneGroup = self.view

	local playBen, playRen = loader.loadMenuButtons()

	local whiteRect = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth*2, display.contentHeight/2)
	whiteRect.anchorX, whiteRect.anchorY = 0, 0
	whiteRect:setFillColor(1, 1, 1)

	sceneGroup:insert(whiteRect)
	sceneGroup:insert(playBen)
	sceneGroup:insert(playRen)
end

function play(chapterName)
	local options = {
		effect = "fade",
		time = 200,
		params = {chapter = chapterName, scene = "chapters.chapter1"}
	}
	composer.removeScene("menu")
	composer.gotoScene("chapters.chapter0", options)
end

function playWithBen()
	play("Odihna_chapter0")
end

function playWithRen()
	play("Golgota_chapter1")
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
	--package.loaded[physics] = nil		
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene