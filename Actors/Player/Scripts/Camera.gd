@icon("res://addons/IconGodotNode/node_3D/icon_camera_grid.png")
extends Node3D

#----Camera----
## The Camera controls anything having to do with mouse movement and mouse locking. When you open a menu, this script is pinged. When you press escape, this script is pinged.
## This Camera script also controls Camera Parameters such as head bob, sway, zoom, and the like.

@export var Player: CharacterBody3D
@export var HeadBone: Node3D
@export var CameraMarker : Marker3D
@onready var CameraPivot: Node3D = self
@export var Settings : Resource
var isMouseCaptured = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	CameraPivot.rotation = Vector3.ZERO
	CameraPivot.rotation.x = deg_to_rad(0)
	
func _unhandled_input(event: InputEvent) -> void:
#// Mouse Look
	if event is InputEventMouseMotion and isMouseCaptured:
# Left & Right Mouse Look
		Player.rotate_y(deg_to_rad(-event.relative.x * Settings.MouseSensitivity))
# Up & Down Mouse Look
		CameraPivot.rotation.x -= deg_to_rad(event.relative.y * Settings.MouseSensitivity)
#Clamp how far up and down the player can look.
		CameraPivot.rotation.x = clamp(CameraPivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
func _process(delta: float) -> void:
	### Camera Sway
	if Player.InputDir.x > 0 :
		CameraPivot.rotation.z = lerp_angle(CameraPivot.rotation.z, deg_to_rad(-Settings.SwayAmount), Settings.SwaySpeed * delta)
	elif Player.InputDir.x < 0 :
		CameraPivot.rotation.z = lerp_angle(CameraPivot.rotation.z, deg_to_rad(Settings.SwayAmount),Settings.SwaySpeed * delta)
	else:
		CameraPivot.rotation.z = lerp_angle(CameraPivot.rotation.z, deg_to_rad(0), Settings.SwaySpeed * delta)

func _physics_process(delta: float) -> void:
	### Prevent Camera from clipping into wall.
	var CameraTarget = CameraMarker.global_position
	var WorldSpace = get_world_3d().direct_space_state
	var RayQuery = PhysicsRayQueryParameters3D.create(
		Player.global_position,
		CameraTarget
	)
	RayQuery.exclude = [Player]
	var IntersectionResult = WorldSpace.intersect_ray(RayQuery)
	if IntersectionResult:
		var Buffer = (CameraTarget - Player.global_position).normalized()
		CameraTarget = IntersectionResult.position - Buffer * 0.05
### Head Bobbing
	global_position = global_position.lerp(CameraMarker.global_position, delta * Settings.CameraSmooth)

func _on_menu_visibility_changed() -> void:
		isMouseCaptured = !isMouseCaptured
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if isMouseCaptured else Input.MOUSE_MODE_VISIBLE
