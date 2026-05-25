extends BaseState

func enter(previous_state_path: String, data := {}) -> void:
	super.enter(previous_state_path, data)

	player._anim_player.play("crouch")
	player.crouching_collision.disabled = false
	player.standing_collision.disabled = true
	player.current_speed = player.SPEED / 2.0

func exit(next_state_path: String) -> void:
	player._anim_player.play_backwards("crouch")
	player._anim_player.queue("standup")
	player.crouching_collision.disabled = true
	player.standing_collision.disabled = false
	player.current_speed = player.SPEED

func update(_delta: float) -> void:
	if Input.is_action_just_released("crouch"):
		finished.emit("idle", {})
