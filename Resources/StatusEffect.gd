extends Resource
class_name StatusEffects
#// Status
@export var Afflicted : bool
@export var Blind : bool
@export var Bleeding : bool
@export var Blessed : bool
@export var Burning : bool
@export var Crippled : bool
@export var Diseased : bool
@export var Drowning : bool
@export var Fatigued : bool
@export var Fear : bool
@export var Freezing : bool
@export var Injured : bool
@export var Poisoned : bool
@export var Starving : bool
@export var Stunned : bool
@export var Wet : bool
#// Timers
var FearTimer : float = 0.0
var StunTimer : float = 0.0

func _stunned(Duration: float):
	Stunned = true
	StunTimer = Duration
