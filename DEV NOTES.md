# Add-Ons Explained
Terrain3D as the logical choice for Terrain Streaming, Clipmaps, and large world sizes on limited hardware.
OWDB handles massive zombie populations with ease.
[GDE GoZen](https://github.com/VoylinsGamedevJourney/gde_gozen) is for extended video format support. If players want to play shrek using OGV, not only do they have to "convert" the mp4 to this obscure format, but it's lacks in many ways to WEBM or other formats.

# Raycasts
The player has 8 Rays in total. One for the 4 cardinal directions coming out of their body, one that points up, one down, one for the camera and the last is a shapecast that stays infront of them. The 4 Cardinal Directions and Ray going up are part of the temperature system. If 4/5 are colliding, the player is insulated.

# Player ParkourDriver
In the PlayerScene, there's an obtuse Skeleton3D node called the ParkourDriver. Since the player isn't using a skinned mesh or armature/rig, if we still want IK functionality we have to make a "Shadow Skeleton" to force those behaviors. The ParkourDriver exists to be moved at runtime to snap the player's limbs during certain animations. In most cases, these animatons are parkour related.

# Bugs


# TODO
