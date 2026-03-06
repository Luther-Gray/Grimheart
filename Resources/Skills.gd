extends Resource
class_name Skills

@export var LearnedSkills : Dictionary = {}

## Reduce damage taken from the same damage type within window.  Increase Damage Dealt using repeated damage type
@export_range(0, 100) var Adaptation : int
