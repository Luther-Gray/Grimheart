extends Resource
class_name Consumable

@export var ConsumableName : String
@export var ConsumableID : String
@export_enum ("S", "A", "B", "C", "D") var ConsumableGrade : String
@export var ConsumablePotency : float
@export var ConsumableDuration : float
@export var ConsumableSpeed : float
@export var ConsumableStatTarget : String
@export var ConsumableElement : String
@export_range(0, 100, 0.1) var ToxicityAmount : float
