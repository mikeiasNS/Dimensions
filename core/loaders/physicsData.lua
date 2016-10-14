local physicsData = {}

local raptorShapeHeadB = {-153, 101.5 , -166, 43.5 , -126, 10.5 , -89, 39.5 , -98, 101.5}
local raptorShapeFootsBodyB = {55, -9.5 , 52, 46.5 , -89, 39.5 , -126, 10.5 , -103, -74.5 , -34, -102.5 , 34, -102.5}
local raptorShapeTailB = {113, 84.5 , 52, 46.5 , 55, -9.5 , 167, 81.5}
local raptorShapeHeadA = {153, 101.5 , 166, 43.5 , 126, 10.5 , 89, 39.5 , 98, 101.5}
local raptorShapeFootsBodyA = {-55, -9.5 , -52, 46.5 , 89, 39.5 , 126, 10.5 , 103, -74.5 , 34, -102.5 , -34, -102.5}
local raptorShapeTailA = {-113, 84.5 , -52, 46.5 , -55, -9.5 , -167, 81.5}

physicsData["Raptor1"] = {
	{ friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeHeadA, 
	  applyToSequences={"stoppedAhead", "walkingAhead"}, applyToSequenceFrameIndexes={{1}, {1,2}} },

	{ friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeFootsBodyA, 
	  applyToSequences={"stoppedAhead", "walkingAhead"}, applyToSequenceFrameIndexes={{1}, {1,2}} },

	{ friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeTailA, 
	  applyToSequences={"stoppedAhead", "walkingAhead"}, applyToSequenceFrameIndexes={{1}, {1,2}} },

	{ friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeHeadB,
	  applyToSequences={"stoppedBack", "walkingBack"}, applyToSequenceFrameIndexes={{1}, {1,2}} },

	{ friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeFootsBodyB,
	  applyToSequences={"stoppedBack", "walkingBack"}, applyToSequenceFrameIndexes={{1}, {1,2}} },

	{ friction = 0.2, bounce = 0.0, density = 3, shape=raptorShapeTailB,
	  applyToSequences={"stoppedBack", "walkingBack"}, applyToSequenceFrameIndexes={{1}, {1,2}} }
}

function physicsData:get(name)
	return unpack(self[name])
end

return physicsData