composer = require( "composer" )
scene = composer.newScene()
widget = require "widget"
mte = require("MTE.mte").createMTE()
loader = require("core.loaders.loader")
util = require("core.misc.utils")
constants = require("core.misc.constants")
dialogs = require("core.misc.dialogs")

display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )
system.activate("multitouch")
ben, ren, enemies = nil, nil, nil
rain = nil
currentChar = nil
backBtn, aheadBtn, jumpBtn, attackBtn, gateBtn, pauseBtn = nil, nil, nil, nil, nil, nil 
OdihnaBG = audio.loadStream("sound/de_boa.mp3")
rainSound = audio.loadStream("sound/rain.wav")
laserSound = audio.loadSound("sound/laser1.wav")
destinationObjName = nil
hpRect = nil
headStatusRect = nil
paused = false
dialogList = {}
pausedImage, continueButton = nil, nil

--collision names
benName = "ben"
renName = "ren"
groundName = "ground"

function focusCameraInRen()
	mte.setCameraFocus(ren, 0, 80)
end

function focusCameraInBen()
	mte.setCameraFocus(ben, 0, -80)
end

function onCharCollision(self, event)
	if(event.other.name == groundName and event.phase == "began") then
		currentChar.jump = 0
	elseif(string.find(event.other.name, "totem") and event.target.name == benName and event.phase == "began") then
		destinationObjName = string.match(event.other.name, "R..%d")
		gateBtn.isVisible = true
	elseif(string.find(event.other.name, "totem") and event.target.name == renName and event.phase == "began") then
		destinationObjName = string.match(event.other.name, "B..%d")
		gateBtn.isVisible = true
	elseif(string.find(event.other.name, "totem") and event.phase == "ended") then
		gateBtn.isVisible = false
	elseif event.other.name == "death" then
		if event.phase == "began" then
			currentChar.hpBonus = -1
		else
			currentChar.hpBonus = 0
		end
	elseif string.find(event.other.name, "end") then
		util.restart(rain)
	end
end

function setupStatus()
	if hpRect ~= nil then
		hpRect:removeSelf()
		headStatusRect:removeSelf()
	end
	currentChar.hp = currentChar.hp + currentChar.hpBonus

	hpRect = display.newRoundedRect(backBtn.x + 100, display.contentHeight - display.contentHeight * 0.87, currentChar.hp * 3, 30, 0)
	hpRect.anchorX = 0
	hpRect:setFillColor(1, 0, 0)

	local imgName = "images/"

	if currentChar.name == benName then
		imgName = imgName.."B"
	else 
		imgName = imgName.."R"
	end

	if string.find(currentChar.sequence, "Back") then
		imgName = imgName.."headB.png"
	else 
		imgName = imgName.."headA.png"
	end

	headStatusRect = display.newImageRect(imgName, 100, 100)
	headStatusRect.x , headStatusRect.y = backBtn.x + 20, hpRect.y
	headStatusRect:setFillColor(1, 1, 1)
	
	if currentChar.hp <= 0 then
		util.die(rain)
	end
end

function dialogIterator(event) 
	if event.phase == "began" then
		showTextInDlgRect(event.target)
	end
end

function dialogListener(event)
	if util.tableContains(dialogList, event.id) then
		--dialog already started
		return
	end

	table.insert(dialogList, event.id)
	if not paused then
		playPause()
	end

	local dialog = dialogs[event.id]

	--dialog box
	local dlgX = aheadBtn.x + aheadBtn.width / 2 + 10
	local dlgY = aheadBtn.y - display.contentHeight * 0.25

	local dialogRect = display.newRoundedRect(dlgX, dlgY, display.contentWidth, display.contentHeight * 0.3, 10)
	dialogRect.anchorX, dialogRect.anchorY = 0, 0
	dialogRect.dialog = dialog
	dialogRect:setFillColor(0, 0, 1)
	dialogRect.alpha = 0.8

	--dialog imgs
	local img1 = display.newImageRect(dialog.img_one_path, 100, 100)
	img1.anchorX = 0
	img1.x, img1.y = dialogRect.x, dialogRect.y + dialogRect.height / 2

	local img2
	if dialog.img_two_path then
		img2 = display.newImageRect(dialog.img_two_path, 100, 100)
		img2.anchorX = 1
		img2.x, img2.y = dialogRect.width + dialogRect.x, dialogRect.y + dialogRect.height / 2
	end

	dialogRect.img1 = img1
	dialogRect.img2 = img2

	--dialog text
	showTextInDlgRect(dialogRect)

	dialogRect:addEventListener( "touch", dialogIterator )
end

function showTextInDlgRect(dlgRect) 
	local index = 1
	if dlgRect.currentText then
		dlgRect.currentText:removeSelf()
		index = dlgRect.currentTextI + 1
	end

	if #dlgRect.dialog.content >= index then
		local str = string.sub(dlgRect.dialog.content[index], 6) 
		local txtX, txtY = dlgRect.x + dlgRect.img1.width + 5, dlgRect.y + 20
		local txtW = dlgRect.width - (dlgRect.img1.width * 2) - 5

		local text = display.newText(str, txtX, txtY, txtW , 0, native.systemFont)
		text.anchorX, text.anchorY = 0, 0
		text:setFillColor(1, 1, 1)

		dlgRect.currentText = text
		dlgRect.currentTextI = index

		if string.sub(dlgRect.dialog.content[index], 1, 4) == "%01%" then 
			-- 01 speaking
			dlgRect.img1.alpha = 1
			if dlgRect.img2 then
				dlgRect.img2.alpha = 0.5
			end
		else
			-- 02 speaking
			dlgRect.img2.alpha = 1
			dlgRect.img1.alpha = 0.5
		end
	else
		dlgRect.img1:removeSelf()
		if dlgRect.img2 then
			dlgRect.img2:removeSelf()
		end

		dlgRect:removeSelf()
		playPause()
	end
end

function goAhead(event)
	util.goAhead(currentChar, event)
end

function goBack(event)
	util.goBack(currentChar, event)
end

function jump(event)
	util.jump(currentChar, event)
end

function fire(event)
	audio.play(laserSound)
	util.fire(currentChar, event)
end

function swapWorld(event)
	if event.phase == "began" then
		local otherChar = ben
		if currentChar.name == benName then
			otherChar = ren
		end

		currentChar, ben, ren = util.swapWorld(currentChar, otherChar, destinationObjName)
	end
end

function playPause(event)
	if string.find(currentChar.sequence, "head") then
		currentChar:setSequence("stoppedAhead")
	else
		currentChar:setSequence("stoppedBack")
	end

	if event then
		if not paused then
			pausedImage = display.newImage("images/paused.png")
			pausedImage.x, pausedImage.y = display.contentCenterX, display.contentCenterY
			pausedImage.width = display.contentWidth
			continueButton = widget.newButton({defaultFile="images/continue.png", x=pausedImage.x, y=pausedImage.y+10, onEvent=playPause})
		elseif pausedImage then
			pausedImage:removeSelf()
			continueButton:removeSelf()
		end
	end

	paused = not paused
	backBtn:setEnabled(not paused)
	aheadBtn:setEnabled(not paused)
	pauseBtn:setEnabled(not paused)
	jumpBtn:setEnabled(not paused)
	attackBtn:setEnabled(not paused)
	gateBtn:setEnabled(not paused)
end

function onWorldChanged(event) 
	audio.stop()
	gateBtn.isVisible = false
	if event.world == "Golgota" then
		audio.play(rainSound, {channel=audio.findFreeChannel(), loops=-1})
		attackBtn.isVisible = true
		jumpBtn.isVisible = false
		util.switchRain(rain, true)
	else
		audio.play(OdihnaBG, {channel=audio.findFreeChannel(), loops=-1})
		attackBtn.isVisible = false
		jumpBtn.isVisible = true
		util.switchRain(rain, false)
	end
end

function handleMove(event)	
	mte.update()
	setupStatus()

	if not paused then
		loader.updateEnemies(enemies, currentChar)
	end

	if string.find(currentChar.sequence, "walk") then
		if(string.find(currentChar.sequence, "Ahead")) then 
			currentChar.x = currentChar.x + 5
		elseif (string.find(currentChar.sequence, "Back")) then
			currentChar.x = currentChar.x - 5
		end
	end
end

function scene:create(event)
	local sceneGroup = self.view
	local options = {
		params = event.params
	}

	print(handleMove)
	composer.removeScene("chapter0")
	composer.gotoScene("loader", options)
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
	scene:removeEventListener("create", scene)
	scene:removeEventListener("show", scene)
	scene:removeEventListener("hide", scene)
	scene:removeEventListener("destroy", scene)
	Runtime:removeEventListener("enterFrame", handleMove)
end

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene