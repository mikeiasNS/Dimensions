local scene = {}

scene.loadObjects = function()
	local objProperties = mte.getObject({name = "sceneObj"})
	local objects = {}

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

		local objSpriteSheet = graphics.newImageSheet(path, {width = w, height = h, numFrames = numFrames})
		local seqData = {name="default", start=1, count=count, time=time}
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

	 	objects[obj.id] = obj
	end

	return objects
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

	local backdrop = display.newImageRect(mapPath .. "BG.png", 3200, 3840)
	local setup = {layer = 1, levelWidth = 3200, levelHeight = 3840, kind = "imageRect", locX=50.5, locY=60.5}
	mte.addSprite(backdrop, setup)
end

scene.onNameProperty = function(event)
    event.target.name = event.propValue
end

return scene