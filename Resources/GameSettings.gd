extends Resource
class_name GameSettings
@export_category("Game Difficulty")
@export_enum("Casual", "Survival", "Cataclysm") var Difficulty : String = "Cataclysm"
@export_category("Mouse Controls")
@export_range(0, 1) var MouseSensitivity : float = 0.35
@export_range(0, 1) var ADSSensitivity : float = 0.20
@export_category("Camera Controls")
@export_range(0, 20) var SwayAmount : int = 2
@export_range(0,100) var SwaySpeed : int =  5
@export_range(0, 20, 0.1) var CameraSmooth : float = 10.0
@export_category("Toggle Controls")
@export var CrouchToggle : bool = true
@export var AimToggle : bool = false
@export var SprintToggle : bool = true
@export var InvertMouseToggle : bool = false
