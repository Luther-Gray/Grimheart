extends Resource
class_name Core

@export_category("Vitals")
@export var Health : int
@export var MaxHealth : int
@export var Stamina : int
@export var MaxStamina : int
@export var Hunger : int
@export var MaxHunger: int
@export var Thirst : int
@export var MaxThirst: int
@export_range(0, 100, 0.01) var Fatigue : int
@export_range(0, 100, 0.01) var MaxFatigue : int
@export_range(-50, 50, 0.01) var Temperature : int
@export_category("Resources")
@export var InventorySlots : int
@export_range (-1000, 1000, 0.1) var Reputation : int
var CoreXP : Dictionary = {
	"MaxHealth" = 0,
	"MaxStamina" = 0,
	"MaxThirst" = 0,
	"MaxFatigue" = 0
}
# Timed Resource Drains
var HealthDrain := 0.0
var StaminaDrain := 1.0

#//-----------FUNCTIONS--------------------------------
func _vital_impact(Vital: String, Amount: int) -> void:
	if Vital in self:
		var VitalValue = get(Vital)
		set(Vital, VitalValue - Amount)
