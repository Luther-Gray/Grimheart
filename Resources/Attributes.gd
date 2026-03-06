extends Resource
class_name Attributes

## Might is a measure of one's strength and their ability to exert incredible feats of force.
@export_range(0, 100, 1) var Might : int
## Toughness is a measure of one's defenses. Not just against physical blows but also all kinds of ailments. Magical, biological, soul, mind, Toughness is the power to resist it all.
@export_range(0, 100, 1) var Toughness : int
## Coordination is a stat that represents how well one can use their extremities for the purpose of handling weapons, maneuvering their body, and coordinating their hands and eyes accurately.
@export_range(0, 100, 1) var Coordination  : int
## Representation of the Maximum Life a creature holds.
@export_range(0, 100, 1) var Vitality :int
## Mind influences the player's ability to cast Magic Artes. It also represents the player's ability to see beyond the visible.
@export_range(0, 100, 1) var Mind :int
## Alacrity is a value that controls how fast you are capable of moving.
@export_range(0, 100, 1) var Alacrity :int
## Fortune is a stat that influences hidden mechanics.
@export_range(0, 100, 1) var Fortune : int
## Persona is a measure of one's ability to roleplay. The ability to charm whoever they may come across.
@export_range(0, 100, 1) var Persona : int
## Soul is a stat that determines the size of your Mana Seed.
@export_range(0, 100, 1) var Soul :int
#// Secret Stats
## Piety is a Hidden Stat that is a representation of how in-touch this being is with higher power(s).
var Piety : int
## Power is a hidden accumulation of all Attributes as a loose representation of actor strength.
var Power : int = Might + Toughness + Coordination + Vitality + Mind + Alacrity + Fortune + Persona + Soul

@export var AttributeXP : Dictionary = {
	"Might": 0,
	"Toughness": 0,
	"Coordination": 0,
	"Vitality": 0,
	"Mind": 0,
	"Alacrity": 0,
	"Fortune": 0,
	"Persona": 0,
	"Soul": 0,
	"Piety": 0
}
var NextAttributeXP : Dictionary = {
	"Might": 10,
	"Toughness": 10,
	"Coordination": 10,
	"Vitality": 10,
	"Mind": 10,
	"Alacrity": 10,
	"Fortune": 10,
	"Persona": 10,
	"Soul": 10,
	"Piety": 5
}

const SLEEP_CAP : int  = 5
var SleepEarnings : int

# Use this function anywhere to Grant the Entity XP
func _grant_xp(Attr: String, XP: float) -> void:
	if AttributeXP.has(Attr) and NextAttributeXP.has(Attr):
		AttributeXP[Attr] += XP # Add to that Stat's XP
		print(AttributeXP[Attr])
	else:
		print("Tried to grant XP to unknown Attribute: ", Attr)

# When you sleep, run this function to Level Up
func _check_level():
	SleepEarnings = 0
	for Key in AttributeXP.keys():
		if not (AttributeXP.has(Key) and NextAttributeXP.has(Key)):
			continue
		while AttributeXP[Key] >= NextAttributeXP[Key] and SleepEarnings < SLEEP_CAP:
			print("Leveling up: ", Key)
			set(Key, get(Key) + 1)
			SleepEarnings += 1
			NextAttributeXP[Key] = int(round(NextAttributeXP[Key] * 1.5))
