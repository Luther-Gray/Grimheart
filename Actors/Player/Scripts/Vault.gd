@icon("res://addons/IconGodotNode/node_3D/icon_vault.png")
extends Node3D

@export var Source: CharacterBody3D
@export var ActionSound : AudioStream
@export var AudioPlayer : AudioStreamPlayer3D
@onready var ClamberTarget: RayCast3D = $"../ClamberTargetRaycast"
@onready var ClamberCast: ShapeCast3D = $"../ClamberShapecast"
@onready var AnimManager: AnimationManager = $"../AnimCenter"
@onready var DEV_Target: MeshInstance3D = $"../../DEV_Target"

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("MV_Jump"):
		_detect_ledge()

func _detect_ledge():
	if !ClamberCast.is_colliding():
		return
	if !ClamberTarget.is_colliding():
		return
	var TargetTopSurface = ClamberTarget.get_collision_point().y
	var HeightDiff = TargetTopSurface - Source.global_position.y
	
	if HeightDiff < 1.2: #Waist Height - Vault
		if Input.is_action_pressed("MV_Forward") and Source.is_on_floor() and Source.isSprinting:
			_vault()
	else: # Too Tall - Ignore
		return
		

#// Vault
func _vault():
	if ActionSound:
		AudioPlayer.stream = ActionSound
		AudioPlayer.play()
	AnimManager._override_travel("aVault")
		# Speed Boost whenever you successfully vault
	Source.MoveSpeed += 4.5
	get_tree().create_timer(1.0).timeout.connect(func(): Source.MoveSpeed -= 4.5)
	
	Source.isVaulting = true
	var VaultTarget = ClamberTarget.get_collision_point().y
	var VaultDirection = -Source.global_transform.basis.z
	var VaultBoost : float = 1.8
	
	# Disable Collision
	var CastObject = ClamberCast.get_collider(0)
	if CastObject:
		Source.add_collision_exception_with(CastObject)
	# Boost Vault
	var VaultTween = get_tree().create_tween()
	VaultTween.set_parallel(true)
	VaultTween.tween_property(Source, "global_position:y", VaultTarget, 0.01)
	VaultTween.tween_property(Source, "global_position:x", Source.global_position.x + VaultDirection.x * VaultBoost, 0.5)
	VaultTween.tween_property(Source, "global_position:z", Source.global_position.z + VaultDirection.z * VaultBoost, 0.3)
	VaultTween.set_parallel(false)
	
	VaultTween.tween_callback(func():
		if CastObject:
			Source.remove_collision_exception_with(CastObject)
		AnimManager.AnimOverride = false
		Source.isVaulting = false
		
		)
	print("Vault")
