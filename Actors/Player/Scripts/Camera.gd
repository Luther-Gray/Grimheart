extends Node3D
@export var Player: CharacterBody3D
@export var Head: Node3D
@export var CameraMarker : Marker3D
@onready var CameraPivot: Node3D = self
@export var Settings : Resource
var isMouseCaptured = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	CameraPivot.rotation = Vector3.ZERO
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("SYS_Escape"):  # Esc to toggle mouse
		isMouseCaptured = !isMouseCaptured
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if isMouseCaptured else Input.MOUSE_MODE_VISIBLE
#/ Mouse Look
	if event is InputEventMouseMotion and isMouseCaptured:
# Left & Right Mouse Look
		Player.rotate_y(deg_to_rad(-event.relative.x * Settings.MouseSensitivity))
# Up & Down Mouse Look
		CameraPivot.rotate_x(deg_to_rad(-event.relative.y * Settings.MouseSensitivity))
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
### Head Bobbing
	global_position = global_position.lerp(CameraMarker.global_position, delta * Settings.CameraSmooth)
