@icon("res://addons/IconGodotNode/control/icon_card.png")
extends Control
class_name HUD

var Interact : bool

func _ready():
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
