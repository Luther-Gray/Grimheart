@tool
extends Node

#// TerrainGen is the way in which the world is generated. For a visual example of how the world is created, load the Terrain.ptex file in MaterialMaker. It's done in a few steps.
# 1. Make a Noise for Peaks/Mountains
# 2. Make a Noise 2 for Landforms/Continents
# 3. Create a Curve to tune and multiply the noise maps together.

@onready var T3D: Terrain3D = $"../Terrain3D"
@onready var MRoad: RoadManager = $"../Terrain3D/RoadManager"


func _ready() -> void:
	pass
