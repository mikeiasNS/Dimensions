local CBE = require ("CBE.CBE")
local effects = {}

effects.loadUpSideRain = function()
	local physics = mte.physics
	local physicsVentGroup = CBE.newVentGroup({
		{
			title = "rain1", -- Though the preset already names the vent "snow", always title!
			preset = "rain",
			alpha = 0.2,
			build = function()
				local p = display.newRect(0, 0, 2, 80)
				p.rotation = 310
				return p
			end,
			physics = {
				gravityY = -2,
				gravityX = -1
			}
		},

		{
			title = "rain2", -- Though the preset already names the vent "snow", always title!
			preset = "rain",
			alpha = 0.2,
			build = function()
				local p = display.newRect(0, 0, 2, 80)
				p.rotation = 310
				return p
			end,
			physics = {
				gravityY = -2,
				gravityX = -1
			}
		}
	})

	physicsVentGroup:move("rain1", 0, display.contentHeight + 50)
	physicsVentGroup:move("rain2", display.contentCenterX + 300, display.contentHeight + 50)

	return physicsVentGroup
end

return effects