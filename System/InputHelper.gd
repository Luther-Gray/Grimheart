extends Node

var InputTimerTarget: Dictionary = {}
var HoldThreshold: float = 0.3

func _process(delta: float) -> void:
	for Keybind in InputMap.get_actions():
		if Input.is_action_pressed(Keybind):
			InputTimerTarget[Keybind] = InputTimerTarget.get(Keybind, 0.0) + delta
		elif Input.is_action_just_released(Keybind):
			InputTimerTarget[Keybind] = 0.0

# Helper to check if a release was a 'Tap'
func isTap(Keybind: String) -> bool:
	return Input.is_action_just_released(Keybind) and InputTimerTarget.get(Keybind, 0.0) <= HoldThreshold

# Helper to check if a release was a 'Hold'
func isHold(Keybind: String) -> bool:
	return Input.is_action_just_released(Keybind) and InputTimerTarget.get(Keybind, 0.0) > HoldThreshold

# Helper to check if it's CURRENTLY being held (for progress bars or continuous 'Heavy' charging)
func isHolding(Keybind: String) -> float:
	return InputTimerTarget.get(Keybind, 0.0)
