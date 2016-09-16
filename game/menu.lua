local composer = require( "composer" )
local scene = composer.newScene()
local loader = require("loader")

function scene:create(event)
	local sceneGroup = self.view

	local playBen, playRen = loader.loadMenuButtons()

	sceneGroup:insert(playBen)
	sceneGroup:insert(playRen)
end

--destiny > 0 
--	play with ben
--destiny <= 0
--	play with ren
function play(destiny)
	local options = {
		effect = "fade",
		time = 1000,
		params = {destinyId = destiny}
	}
	composer.removeScene("menu")
	composer.gotoScene("chapter1", options)
end

function playWithBen()
	play(1)
end

function playWithRen()
	play(-1)
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