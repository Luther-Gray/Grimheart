extends Resource
class_name Stats

@export_category("Secondary Stats")
@export var AttackSpeed : float
@export var WalkSpeed : float
@export var SprintSpeed : float
@export var JumpStrength : float
@export var StaminaEfficiency : float
@export var PhysicalAttack : float
@export var PhysicalDefense : float
@export var ClimbSpeed : float
@export var CrouchSpeed : float

func _boost_stat(Stat: String, Amount: float, Duration: float, Scene: SceneTree) -> void:
	if Stat:
		# Boost Value
		var OriginalStat = get(Stat)
		set(Stat, OriginalStat + Amount)
		# Timer
		await Scene.create_timer(Duration).timeout
		# Restore Original Stat
		set(Stat, get(Stat) - Amount)
	else:
		print("No Stat Found")
