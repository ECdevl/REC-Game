# Base class for all grabbable/interactable objects in the game.
# Must extend RigidBody3D so the player's cast to RigidBody3D succeeds.
# Previously extended CollisionObject3D, which caused the cast to always return null.
class_name GrabObject
extends RigidBody3D

# Euler rotation (degrees) applied when the object is held by the player.
# Lets each object define its own "held" orientation without touching the player script.
@export var held_rotation: Vector3 = Vector3.ZERO

# Positional offset applied when the object is held, relative to GrabTarget.
@export var held_offset: Vector3 = Vector3.ZERO


func _ready() -> void:
	# Register as grabbable so the player's raycast can detect it.
	add_to_group("grab")
