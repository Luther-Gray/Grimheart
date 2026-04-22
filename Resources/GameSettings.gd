extends Resource
class_name GameSettings

@export_category("Mouse Controls")
@export_range(0, 1) var MouseSensitivity : float = 0.35
@export_range(0, 1) var ADSSensitivity : float = 0.20
@export_category("Camera Controls")
@export_range(0, 20) var SwayAmount : int = 2
@export_range(0,100) var SwaySpeed : int =  5
@export_range(0, 20) var CameraSmooth : float = 10.0
@export_category("Toggle Controls")
@export var CrouchToggle : bool = false
@export var AimToggle : bool = false
@export var SprintToggle : bool = false
@export var InvertMouseToggle : bool = false
