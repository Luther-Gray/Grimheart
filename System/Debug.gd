extends Control

@onready var property_container: VBoxContainer = $MarginContainer/PropertyContainer
@export var zombie: PackedScene

func _ready() -> void:
    # Hide by default so it doesn't block the screen
	visible = false

func _input(event: InputEvent) -> void:
    # Check for your toggle key (ensure "SYS_Debug" is in Input Map)
	if event.is_action_pressed("SYS_Debug"):
		visible = !visible
	if event.is_action_pressed("ui_accept"):
	# Safety check: Make sure you dragged the Zombie.tscn into the Inspector!
		if zombie == null:
			print("ERROR: Drag your Zombie.tscn into the Zombie Scene slot in the Inspector!")
			return
		for i in 10:
			var z = zombie.instantiate()
			# 1. Add it to the level (Eden), NOT to the Debug menu
			get_tree().current_scene.add_child(z)
			# 2. Set the position AFTER adding to the scene
			var spawn_pos = Vector3(randf_range(-20, 20), 0, randf_range(-20, 20))
			z.global_position = spawn_pos

func _process(_delta: float) -> void:
	if visible:
		# Update FPS label every frame while visible
		var fps = Engine.get_frames_per_second()
		_add_debug("FPS", int(fps), 0) # Cast to int for a cleaner look
		var count = get_tree().get_nodes_in_group("Zombies").size()
		_add_debug("Total Actors", count, 1)
		_add_debug("Draw Calls", Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), 2)

func _add_debug(key: String, value, order: int):
	var target = property_container.find_child(key, true, false)

# If the label doesn't exist, create it once
	if not target:
		target = Label.new()
		target.name = key
		property_container.add_child(target)

	target.text = "%s : %s" % [key, str(value)]
	property_container.move_child(target, order)
