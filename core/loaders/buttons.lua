local widget = require "widget"
local buttonsLoader = {}

local screenLeft, screenWidth = display.screenOriginX, display.contentWidth
local centerX, centerY = display.contentCenterX, display.contentCenterY
local screenRight = screenWidth - screenLeft

buttonsLoader.loadButtons = function ()
	backBtn = widget.newButton{
		label="",
		defaultFile="images/back.png",
		width = display.contentHeight * 0.15, 
		height= display.contentHeight * 0.15, 
		onEvent = goBack
	}
	backBtn.x, backBtn.y = screenLeft + display.contentHeight * 0.1, display.contentHeight - display.contentHeight * 0.13
	backBtn.alpha = 0.5

	aheadBtn = widget.newButton{
		label="",
		defaultFile="images/ahead.png",
		width = display.contentHeight * 0.15, 
		height= display.contentHeight * 0.15, 
		onEvent = goAhead
	}
	aheadBtn.x, aheadBtn.y = backBtn.x + (backBtn.width / 2) + screenWidth * 0.06, display.contentHeight - display.contentHeight * 0.1
	aheadBtn.alpha = 0.5

	jumpBtn = widget.newButton{
		label="",
		defaultFile="images/up.png",
		width = display.contentHeight * 0.15, 
		height= display.contentHeight * 0.15, 
		onPress = jump
	}
	jumpBtn.x, jumpBtn.y = screenRight - display.contentHeight * 0.1, (aheadBtn.y + backBtn.y) / 2
	jumpBtn.alpha = 0.5

	attackBtn = widget.newButton{
		label="",
		defaultFile="images/attack.png",
		width = display.contentHeight * 0.15, 
		height= display.contentHeight * 0.15, 
		onPress = fire
	}
	attackBtn.x, attackBtn.y = jumpBtn.x, jumpBtn.y
	attackBtn.alpha = 0.5

	gateBtn = widget.newButton{
		label="",
		defaultFile="images/portal.png",
		width = display.contentHeight * 0.15, 
		height= display.contentHeight * 0.15, 
		onPress = swapWorld
	}
	gateBtn.x, gateBtn.y = display.contentCenterX, jumpBtn.y

	pauseBtn = widget.newButton{
		label="",
		defaultFile="images/pause.png",
		width = display.contentHeight * 0.15, 
		height= display.contentHeight * 0.15, 
		onPress = playPause
	}
	pauseBtn.x, pauseBtn.y = jumpBtn.x, display.contentHeight * 0.1
	pauseBtn.alpha = 0.5


	return backBtn, aheadBtn, jumpBtn, attackBtn, gateBtn, pauseBtn
end

buttonsLoader.loadMenuButtons = function ()
	playBen = widget.newButton{
		label="",
		defaultFile = "images/play_ben.png",
		width = display.contentWidth * 0.3,
		height = display.contentWidth * 0.3,
		onEvent = playWithBen
	}
	playBen.anchorY = 0
	playBen.x, playBen.y = centerX, centerY - playBen.contentHeight

	playRen = widget.newButton{
		label="",
		defaultFile = "images/play_ren.png",
		width = display.contentWidth * 0.3,
		height = display.contentWidth * 0.3,
		onEvent = playWithRen
	}
	playRen.anchorY = 1
	playRen.x, playRen.y = centerX, centerY + playRen.contentHeight 

	return playBen, playRen
end

return buttonsLoader