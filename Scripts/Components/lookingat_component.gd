# Raycast-based component that tracks what the player is currently looking at.
# Attach as a child of Camera3D. The player script reads looking_at every frame.
extends RayCast3D
class_name LookingatComponent

@export_category("Debug")
@export var debug_looking_at : bool = false

# The collider the raycast is currently hitting, or null if hitting nothing.
# Type is Object (not Node3D) because get_collider() can return PhysicsBody3D
# or other physics objects — let the caller cast to the type it needs.
var looking_at: Object = null


func _process(_delta: float) -> void:
	if is_colliding() and get_collider():
		if get_collider().is_in_group("interactable") or get_collider() is DoorComponent:
			looking_at = get_collider()
			if debug_looking_at:
				print("Looking at: %s" % looking_at.name)

	else:
		looking_at = null
