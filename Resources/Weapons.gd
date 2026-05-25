extends Resource
class_name Weapons
@export var WeaponID : String
@export_enum("Sword", "Hammer", "Spear", "Dagger") var WeaponArchetype : String
@export_enum("Sharp", "Blunt", "Pierce", "Ballistic", "Toxic", "Electric", "Daemonic", "Otherworldly", "Holy", "Grim") var WeaponDamageType : String
@export_multiline var WeaponLore : String
@export var WeaponMesh: PackedScene
@export var isTwoHanded : bool
@export var WeaponDamage : int
@export var StealthDamage : float
@export var WeaponDurability : float
@export var WeaponWeathering : int
@export var Accuracy : float
