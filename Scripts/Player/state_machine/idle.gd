extends BaseState
class_name Idle

func enter(previous_state_path: String, data := {}) -> void:
	super.enter(previous_state_path, data)
	player._anim_body.play("RESET")

func update(_delta: float) -> void:
	var moving := Input.get_vector(
		player.KEY_BIND_LEFT,
		player.KEY_BIND_RIGHT,
		player.KEY_BIND_UP,
		player.KEY_BIND_DOWN
	).length() > 0.1

	if moving:
		if Input.is_action_pressed("run") and player._stamina.can_run:
			finished.emit("run", {})
		else:
			finished.emit("walk", {})
		return

	if Input.is_action_just_pressed("crouch"):
		finished.emit("crouch", {})
