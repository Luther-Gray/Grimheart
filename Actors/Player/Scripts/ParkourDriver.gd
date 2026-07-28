@tool
extends Skeleton3D

func _ready():
	if not Engine.is_editor_hint():
		return
	_build_parkour_bones()

func _build_parkour_bones():
	# Root
	add_bone("Root")
	
	# Left arm chain
	add_bone("UpperArm.L")
	set_bone_parent(find_bone("UpperArm.L"), find_bone("Root"))
	
	add_bone("LowerArm.L")
	set_bone_parent(find_bone("LowerArm.L"), find_bone("UpperArm.L"))
	
	add_bone("Hand.L")
	set_bone_parent(find_bone("Hand.L"), find_bone("LowerArm.L"))
	
	# Right arm chain
	add_bone("UpperArm.R")
	set_bone_parent(find_bone("UpperArm.R"), find_bone("Root"))
	
	add_bone("LowerArm.R")
	set_bone_parent(find_bone("LowerArm.R"), find_bone("UpperArm.R"))
	
	add_bone("Hand.R")
	set_bone_parent(find_bone("Hand.R"), find_bone("LowerArm.R"))
	
	print_debug("Bones added: ", get_bone_count())
