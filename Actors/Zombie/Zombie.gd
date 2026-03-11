extends CharacterBody3D

@export var speed: float = 3.0
@export var roam_radius: float = 10.0

@onready var nav_agent: NavigationAgent3D = $"NavigationAgent3D"
@onready var roam_timer: Timer = $Timer
@onready var zombie_anim_tree: AnimationTree = $ZombieAnimTree

var isMoving = false

func _ready():
	roam_timer.wait_time = randf_range(0.1, 2.0)
	roam_timer.start()
	pick_random_target()

func _physics_process(delta: float) -> void:
	# 1. Check if we've arrived
	if nav_agent.is_navigation_finished():
		if isMoving:
			isMoving = false
			velocity = Vector3.ZERO
			print("Arrived! Taking a breather...")
			start_roam_logic() # Start the wait-then-pick cycle
		return

	# 2. Movement logic (only runs if isMoving is true)
	if isMoving:
		var next_path_pos = nav_agent.get_next_path_position()
		velocity = (next_path_pos - global_position).normalized() * speed
		move_and_slide()

	if velocity.length() > 0.1:
		look_at(global_position + velocity, Vector3.UP)

	zombie_anim_tree.set("parameters/WalkBlend/blend_amount", 0.0)

func start_roam_logic():
# Wait for a random amount of time
	var wait_time = randf_range(2.0, 5.0)
	await get_tree().create_timer(wait_time).timeout

	# After the wait, pick a new target
	pick_random_target()

func _on_timer_timeout():
	pick_random_target()

func pick_random_target():
	var random_dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var target_pos = global_position + (random_dir * randf_range(2, roam_radius))

	nav_agent.target_position = target_pos
	isMoving = true # Flip the switch to start moving again
	print("New target set: ", target_pos)
