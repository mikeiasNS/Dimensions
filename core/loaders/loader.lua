local buttonsLoader = require ("core.loaders.buttons")
local effectsLoader = require ("core.loaders.effects")
local sceneLoader = require ("core.loaders.scene")
local charsLoader = require ("core.loaders.chars")
local enemiesLoader = require ("core.loaders.enemies")

local loader = {}

loader.loadBen = charsLoader.loadBen

loader.loadRen = charsLoader.loadRen

loader.loadObjects = sceneLoader.loadObjects

loader.loadButtons = buttonsLoader.loadButtons

loader.loadMenuButtons = buttonsLoader.loadMenuButtons

loader.loadMap = sceneLoader.loadMap

loader.loadUpSideRain = effectsLoader.loadUpSideRain

loader.loadEnemies = enemiesLoader.loadEnemies

loader.updateEnemies = enemiesLoader.updateEnemies

return loader