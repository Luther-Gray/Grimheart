extends CharacterBody3D

@export var speed: float = 3.0
@export var roam_radius: float = 10.0

@onready var nav_agent: NavigationAgent3D = $"NavigationAgent3D"
@onready var roam_timer: Timer = $Timer

var F3 : String = "SysDebug"

func _ready():
	roam_timer.wait_time = randf_range(0.1, 2.0)
	roam_timer.start()
	pick_random_target()

func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	# Calculate direction to the next path point
	var current_pos = global_position
	var next_path_pos = nav_agent.get_next_path_position()
	var new_velocity = (next_path_pos - current_pos).normalized() * speed

	velocity = new_velocity
	move_and_slide()

    # Look where moving
	if velocity.length() > 0.1:
		look_at(global_position + velocity, Vector3.UP)

func pick_random_target():
# Pick a random point on a horizontal plane
	roam_timer.wait_time = randf_range(2.0, 5.0)
	var random_dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	var target_pos = global_position + (random_dir * randf_range(2, roam_radius))

# Set the navigation target
	nav_agent.target_position = target_pos

func _on_timer_timeout():
	pick_random_target()
