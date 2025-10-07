extends RayCast3D
class_name LookingatComponent
var looking_at = null
func _process(delta: float) -> void:
	if is_colliding():
		looking_at = get_collider()
	else:
		looking_at = null
