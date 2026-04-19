extends Resource
class_name Core

@export_group("Vitals")
@export_subgroup("Health")
@export var Health : int
@export var MaxHealth : int
@export_subgroup("Body Health")
@export var Head : int
@export var Eyes : int
@export var Ears : int
@export var Throat : int
@export var Chest : int
@export var Heart : int
@export var Stomach : int
@export var LeftArm : int
@export var LeftHand : int
@export var RightArm : int
@export var RightHand : int
@export var Hips : int
@export var LeftLeg : int
@export var LeftFoot : int
@export var RightLeg : int
@export var RightFoot : int
@export_subgroup("Stamina")
@export var Stamina : int
@export var MaxStamina : int
@export_subgroup("Breath")
@export var Breath : int
@export var MaxBreath : int
@export_subgroup("Hunger")
@export var Hunger : int
@export var MaxHunger: int
@export_subgroup("Calories")
@export var Protiens : int
@export var Fats : int
@export var Carbs : int
@export_subgroup("Fatigue")
@export var Fatigue : int
@export var MaxFatigue : int
@export_subgroup("Fluids")
@export var Blood : int
@export var MaxBlood : int
@export var Hydration : int
@export var MaxHydration : int
@export_group("Enviroment")
@export_subgroup("Temperature")
@export var Temperature : int
@export var MinTemperature : int
@export var MaxTemperature : int
@export_subgroup("Weather")
@export var Radiation : int
@export var MaxRadiation : int
@export var Wetness : int
@export var MaxWetness : int
@export_group("Psyche")
@export_subgroup("Morale")
@export var Morale : int
@export var MaxMorale : int
@export_subgroup("Spirit")
@export var Spirit : int
@export var MaxSpirit : int
@export_subgroup("Pain")
@export var Pain : int
@export var MaxPain : int
@export_group("Resources")
@export var InventorySlots : int
@export var Encumberance : float
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
