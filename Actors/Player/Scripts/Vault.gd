@icon("res://addons/IconGodotNode/node_3D/icon_vault.png")
extends Node3D

@export var Source: CharacterBody3D
@export var VaultSound : AudioStream
@export var AudioPlayer : AudioStreamPlayer3D
@onready var ClamberCast: ShapeCast3D = $"../ClamberShapecast"
@onready var LedgeRay: RayCast3D = $"../LedgeCeilingRaycast"
@onready var AnimManager: AnimationManager = $"../AnimCenter"
@onready var DEV_Target: MeshInstance3D = $"../../DEV_Target"
@onready var VaultRaycast: RayCast3D = $VaultRaycast

const VaultLayer : int = 2

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("MV_Jump") and Source.isSprinting:
		_can_vault()

func _can_vault():
	if !VaultRaycast.is_colliding():
		return
	if VaultRaycast.get_collision_mask_value(VaultLayer):
		if Input.is_action_pressed("MV_Forward") and Source.is_on_floor():
			_vault()
	else:
		return

#// Vault
func _vault():
	if VaultSound:
		AudioPlayer.stream = VaultSound
		AudioPlayer.play()
	AnimManager._override_travel("aVault")
		# Speed Boost whenever you successfully vault
	Source.MoveSpeed += 4.5
	get_tree().create_timer(1.0).timeout.connect(func(): Source.MoveSpeed -= 4.5)
	
	Source.isVaulting = true
	var VaultDirection = -Source.global_transform.basis.z
	var VaultBoost : float = 1.8
	# Boost Vault
	var VaultTween = get_tree().create_tween()
	VaultTween.set_parallel(true)
	VaultTween.tween_property(Source, "global_position:y", Source.global_position.y + 1.0, 0.01)
	VaultTween.tween_property(Source, "global_position:x", Source.global_position.x + VaultDirection.x * VaultBoost, 0.5)
	VaultTween.tween_property(Source, "global_position:z", Source.global_position.z + VaultDirection.z * VaultBoost, 0.3)
	
	VaultTween.tween_callback(func(): # When the Tween Ends ->
		AnimManager.AnimOverride = false
		Source.isVaulting = false
		
		)
