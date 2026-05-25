extends SpotLight3D

@export var sibling : Player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if sibling:
		global_position = lerp(global_position,sibling.get_child(2).global_position,.25)
		global_rotation_degrees.x = lerp(global_rotation_degrees.x,sibling.get_child(2).global_rotation_degrees.x,.25)
