local scene = {}

scene.loadObjects = function()
	local objProperties = mte.getObject({name = "sceneObj"})
	local objects = {}

	if not objProperties then
		return objects
	end

	for k,v in pairs(objProperties) do

		local w, h = objProperties[k].width, objProperties[k].height
		local numFrames = objProperties[k].properties.numFrames or 1
		local path = objProperties[k].properties.path
		local bodyType = objProperties[k].properties.bodyType or "static"
		local offscreenPhysics = objProperties[k].properties.offscreenPhysics or false
		local layer = objProperties[k].layer
		local count = objProperties[k].properties.count or 1
		local time = objProperties[k].properties.time or 0
		local id = objProperties[k].properties.id or objProperties[k].properties.name
		local bounce = objProperties[k].properties.bounce or 0
		local density = objProperties[k].properties.density or 0

		local objSpriteSheet = graphics.newImageSheet(path, {width = w, height = h, numFrames = numFrames});
		local seqData = {}

		for key, v in pairs(objProperties[k].properties) do
			if string.find(key, "sequence:") then
				local sequenceName = string.sub(key, 10)
				local f = loadstring("return "..v)() -- sequence frames
				local t = tonumber(objProperties[k].properties[sequenceName..":time"]) or 200 -- sequence time
				local lc = tonumber(objProperties[k].properties[sequenceName..":loopCount"]) or 0 -- sequence loopcount

				table.insert(seqData, {name = sequenceName, sheet = objSpriteSheet, frames = f, time = t, loopCount = lc})
			end
		end

		if #seqData == 0 then
			seqData = {name="default", start=1, count=count, time=time}
		end

		local obj = display.newSprite(objSpriteSheet, seqData)

		local objX, objY = objProperties[k].x + obj.width/2, objProperties[k].y + obj.height/2
		local objSetup = {  layer = layer, kind = "sprite", 
							levelPosX = objX, levelPosY = objY, 
							offscreenPhysics = offscreenPhysics  }

		mte.physics.addBody(obj, bodyType, {bounce=bounce, density=density})
	 	mte.addSprite(obj, objSetup)

	 	obj.name = objProperties[k].properties.name
	 	obj.type = objProperties[k].type
	 	obj.id = id

	 	if objProperties[k].properties.disableCollideTo then
	 		obj.disableCollideTo = objProperties[k].properties.disableCollideTo
	 		obj.preCollision = scene.avoidCollision
			obj:addEventListener("preCollision")
	 	end

	 	if objProperties[k].properties.eventName then
	 		obj.preCollision = scene.takeblePreCollision
	 		obj.eventName = objProperties[k].properties.eventName
	 		obj.eventId = objProperties[k].properties.eventId
	 		obj:addEventListener("preCollision")
	 	end
        
        if objProperties[k].properties.rotation then
            obj.rotation = objProperties[k].properties.rotation
        end
            
	 	objects[obj.id] = obj
	end
	scene.loadShapeObjects()

	return objects
end

scene.loadShapeObjects = function() 
	local objProperties = mte.getObject({name = "shapeObj"})
	local shapeObjects = {}

	if not objProperties then
		return
	end

	for k,v in pairs(objProperties) do
		local w, h = objProperties[k].width, objProperties[k].height
		local red = objProperties[k].properties.red or "1.0"
		local green = objProperties[k].properties.green or "1.0"
		local blue = objProperties[k].properties.blue or "1.0"
		local alpha = objProperties[k].properties.alpha or "0.0"
		local id = objProperties[k].properties.id or objProperties[k].properties.name
		local layer = objProperties[k].layer
		local bodyType = objProperties[k].properties.bodyType or "static"
		local bounce = objProperties[k].properties.bounce or 0
		local density = objProperties[k].properties.density or 0

		local obj = display.newRect(0, 0, w, h)

		local x, y = objProperties[k].x + obj.width/2, objProperties[k].y + obj.height/2
		local objSetup = {  layer = layer, kind = "sprite", 
							levelPosX = x, levelPosY = y, 
							offscreenPhysics = offscreenPhysics  }

		mte.physics.addBody(obj, bodyType, {bounce=bounce, density=density})
		mte.addSprite(obj, objSetup)

		obj:setFillColor(loadstring("return "..red)(), 
						loadstring("return "..green)(), 
						loadstring("return "..blue)())
		obj.alpha = loadstring("return "..alpha)()
		obj.name = objProperties[k].properties.name
	 	obj.type = objProperties[k].type
	 	obj.id = id
	end
end

scene.takeblePreCollision = function(self, event) 
	if event.other.name == "ben"or event.other.name == "ren" then 
		if self.type == "takeble" then
			self:removeSelf()
		end

		local dialogEvent = { name=self.eventName, id=self.eventId }
		map:dispatchEvent(dialogEvent)
	end
end

scene.avoidCollision = function(self, event)
	if(event.other.name == self.disableCollideTo) then
		if event.contact then
			event.contact.isEnabled = false
		end
	end
end

scene.loadMap = function (mapPath)
	mte.toggleWorldWrapX(false)
	mte.toggleWorldWrapY(false)
	mte.loadMap(mapPath .. ".tmx")
	local blockScale = 33
	map = mte.setCamera({blockScale = blockScale})
	mte.constrainCamera()
	mte.addPropertyListener("name", scene.onNameProperty)

	local bgW, bgH = mte.getMap().width * 32, mte.getMap().height * 32
	local bgx, bgy = mte.getMap().width / 2 + 0.5, mte.getMap().height / 2 + 0.5
	print("bg", bgW, bgH )

	local backdrop = display.newImageRect(mapPath .. "BG.png", bgW, bgH)
	local setup = {layer = 1, levelWidth = bgW, levelHeight = bgH, kind = "imageRect", locX=bgx, locY=bgy}
	mte.addSprite(backdrop, setup)
end

scene.onNameProperty = function(event)
    event.target.name = event.propValue
end

return scene