@icon("res://addons/IconGodotNode/node_3D/icon_camera_grid.png")
extends Node3D

#----Camera----
## The Camera controls anything having to do with mouse movement and mouse locking. When you open a menu, this script is pinged. When you press escape, this script is pinged.
## This Camera script also controls Camera Parameters such as head bob, sway, zoom, and the like.

@export var Player: CharacterBody3D
@export var CameraMarker : Marker3D
@onready var CameraPivot: Node3D = self
@export var Settings : Resource
@export var PlayerMesh : Node3D
var isMouseCaptured = true
var isCameraForced = false
var isLookingBack = false
var ChaseCamAngle : float = 150.0
var ChaseCamSpeed : float = 18.0
var ChaseCamTilt : float = 0.2
var ChaseCamSlide : float = -1.2
var ChaseCamYaw : float = 0.0
var OldRotation : Vector3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	CameraPivot.rotation = Vector3.ZERO
	CameraPivot.rotation.x = deg_to_rad(0)
	
func _unhandled_input(event: InputEvent) -> void:
#// Mouse Look
	if event is InputEventMouseMotion and isMouseCaptured and !isCameraForced:
# Left & Right Mouse Look (When on Ledge)
		if Player.isHanging:
			CameraPivot.rotation.y -= deg_to_rad(event.relative.x * Settings.MouseSensitivity)
			CameraPivot.rotation.y = clamp(CameraPivot.rotation.y, deg_to_rad(-60), deg_to_rad(60))
		else:
# Left & Right Mouse Look
			Player.rotate_y(deg_to_rad(-event.relative.x * Settings.MouseSensitivity))
# Up & Down Mouse Look
		CameraPivot.rotation.x -= deg_to_rad(event.relative.y * Settings.MouseSensitivity)
#Clamp how far up and down the player can look.
		CameraPivot.rotation.x = clamp(CameraPivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))
#// Look Back
	if Input.is_action_just_pressed("LOOK_Back"):
		ChaseCamYaw = CameraPivot.rotation.y
		isLookingBack = true
	elif Input.is_action_just_released("LOOK_Back"):
		isLookingBack = false
		
func _process(delta: float) -> void:
### Camera Sway
	if isCameraForced:
		return
	if isLookingBack:
		pass
	if Player.InputDir.x > 0 :
		CameraPivot.rotation.z = lerp_angle(CameraPivot.rotation.z, deg_to_rad(-Settings.SwayAmount), Settings.SwaySpeed * delta)
	elif Player.InputDir.x < 0 :
		CameraPivot.rotation.z = lerp_angle(CameraPivot.rotation.z, deg_to_rad(Settings.SwayAmount),Settings.SwaySpeed * delta)
	else:
		CameraPivot.rotation.z = lerp_angle(CameraPivot.rotation.z, deg_to_rad(0), Settings.SwaySpeed * delta)
### Chase Cam (Looking Backwards)
	if isLookingBack:
		var ChaseCamTarget := ChaseCamYaw + deg_to_rad(ChaseCamAngle)
		CameraPivot.rotation.y = lerp_angle(CameraPivot.rotation.y, ChaseCamTarget, ChaseCamSpeed * delta)
		CameraPivot.rotation.z = lerp_angle(CameraPivot.rotation.z, ChaseCamTilt, ChaseCamSpeed * delta)
		CameraPivot.position.x = lerp(CameraPivot.position.x, ChaseCamSlide, ChaseCamSpeed * delta)
	else:
		CameraPivot.rotation.y = lerp_angle(CameraPivot.rotation.y, ChaseCamYaw, ChaseCamSpeed * delta)
		CameraPivot.position.x = lerp(CameraPivot.position.x, 0.0, ChaseCamSpeed * delta)

func _physics_process(delta: float) -> void:
### Head Bobbing
	global_position = global_position.lerp(CameraMarker.global_position, delta * Settings.CameraSmooth)
### Camera Rotation Locking
	if isCameraForced:
		var targetRotation := CameraMarker.global_transform.basis.get_rotation_quaternion()
		global_transform.basis = Basis(global_transform.basis.get_rotation_quaternion().slerp(targetRotation.normalized(), delta * Settings.CameraSmooth))

func _force_camera(flag : bool) -> void:
	isCameraForced = flag
	if isCameraForced:
		PlayerMesh.visible = false
		OldRotation = CameraPivot.rotation
	else: 
		PlayerMesh.visible = true
		CameraPivot.rotation = Vector3(OldRotation.x, OldRotation.y, 0.0)
