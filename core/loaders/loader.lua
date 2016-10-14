local buttonsLoader = require ("core.loaders.buttons")
local effectsLoader = require ("core.loaders.effects")
local sceneLoader = require ("core.loaders.scene")
local charsLoader = require ("core.loaders.chars")
local enemiesLoader = require ("core.loaders.enemies")

local loader = {}

loader.loadBen = charsLoader.loadBen

loader.loadRen = charsLoader.loadRen

loader.loadObjects = sceneLoader.loadObjects

loader.loadEnemies = charsLoader.loadEnemies

loader.loadButtons = buttonsLoader.loadButtons

loader.loadMenuButtons = buttonsLoader.loadMenuButtons

loader.loadMap = sceneLoader.loadMap

loader.loadUpSideRain = effectsLoader.loadUpSideRain

loader.loadEnemies = enemiesLoader.loadEnemies

return loader