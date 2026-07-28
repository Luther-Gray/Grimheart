extends Resource
class_name Stats

@export_category("Secondary Stats")
@export var AttackSpeed : float
@export var WalkSpeed : float = 3.0
@export var SprintSpeed : float = 7.0
@export var JumpStrength : float = 7.2
@export var StaminaEfficiency : float
@export var PhysicalAttack : float
@export var PhysicalDefense : float
@export var ClimbSpeed : float = 3.1
@export var CrouchSpeed : float = 1.5

func _alter_stat(Stat: String, Amount: float, Duration: float, Scene: SceneTree) -> void:
	if Stat:
		# Boost Value
		var OriginalStat = get(Stat)
		set(Stat, OriginalStat + Amount)
		# Timer
		await Scene.create_timer(Duration).timeout
		# Restore Original Stat
		set(Stat, get(Stat) - Amount)
	else:
		print_debug("No Stat Found")
