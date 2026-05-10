@icon("res://addons/IconGodotNode/control/icon_thunder.png")
extends Control

@export var Source: CharacterBody3D

@onready var property_container: VBoxContainer = $MarginContainer/PropertyContainer

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SYS_Debug"):
		visible = !visible

func _process(_delta: float) -> void:
	if visible:
		_add_debug("FPS", int(Performance.get_monitor(Performance.TIME_FPS)), 0)
		_add_debug("Draw Calls", int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)), 1)
		_add_debug("Jump State", Source.isJumping, 2)
		_add_debug("Fall State", Source.isFalling, 3)
		_add_debug("Hang State", Source.isHanging, 4)
		_add_debug("Sprint State", Source.isSprinting, 5)

func _add_debug(MetricName: String, Metric, ListOrder: int):
	var DebugLabel = property_container.find_child(MetricName, true, false)
	if not DebugLabel:
		DebugLabel = Label.new()
		DebugLabel.name = MetricName
		property_container.add_child(DebugLabel)

	DebugLabel.text = "%s : %s" % [MetricName, str(Metric)]
	property_container.move_child(DebugLabel, ListOrder)
