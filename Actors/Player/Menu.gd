@icon("res://addons/IconGodotNode/control/icon_paused.png")
extends CanvasLayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SYS_Escape"):
		self.visible = !self.visible

func _on_resume() -> void:
	self.visible = !self.visible


func _on_options() -> void:
	print("Options Here!")


func _on_quit() -> void:
	pass # Replace with function body.
