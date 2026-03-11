extends Control

@onready var property_container: VBoxContainer = $MarginContainer/PropertyContainer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SYS_Debug"):
		visible = !visible

func _process(_delta: float) -> void:
	if visible:
		_add_debug("FPS", int(Performance.get_monitor(Performance.TIME_FPS)), 0)
		_add_debug("Draw Calls", int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)), 1)

func _add_debug(MetricName: String, Metric, ListOrder: int):
	var DebugLabel = property_container.find_child(MetricName, true, false)
	if not DebugLabel:
		DebugLabel = Label.new()
		DebugLabel.name = MetricName
		property_container.add_child(DebugLabel)

	DebugLabel.text = "%s : %s" % [MetricName, str(Metric)]
	property_container.move_child(DebugLabel, ListOrder)
