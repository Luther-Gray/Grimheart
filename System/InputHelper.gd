extends Node

var InputTimerTarget: Dictionary = {}
var HoldThreshold: float = 0.3

func _process(delta: float) -> void:
	for Keybind in InputMap.get_actions():
		if Input.is_action_pressed(Keybind):
			InputTimerTarget[Keybind] = InputTimerTarget.get(Keybind, 0.0) + delta
		elif Input.is_action_just_released(Keybind):
			InputTimerTarget[Keybind] = 0.0

func isTap(Keybind: String) -> bool: ## Helper to check if a release was a 'Tap'
	return Input.is_action_just_released(Keybind) and InputTimerTarget.get(Keybind, 0.0) <= HoldThreshold


func isHold(Keybind: String) -> bool: ## Helper to check if a release was a 'Hold'
	return Input.is_action_just_released(Keybind) and InputTimerTarget.get(Keybind, 0.0) > HoldThreshold

func isHolding(Keybind: String) -> float: ## Helper to check if a keybind is CURRENTLY being held (for progress bars or continuous 'Heavy' charging)
	return InputTimerTarget.get(Keybind, 0.0)
