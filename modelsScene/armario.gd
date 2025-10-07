extends Area3D
@export var AP : AnimationPlayer
var toggle : bool = false
var can_interact : bool = true

func interac():
	if can_interact:
		can_interact = false
		toggle = !toggle
		if toggle:
			AP.play("open")
		else:
			AP.play_backwards("open")
		await AP.animation_finished
		can_interact = true
