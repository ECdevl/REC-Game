extends BaseState

func enter(previous_state_path: String, data := {}) -> void:
	super.enter(previous_state_path, data)

	player._anim_body.play("Caminar")
	player.emit_signal("toggle_run", true)

func exit(next_state_path: String) -> void:
	player.emit_signal("toggle_run", false)

func update(_delta: float) -> void:
	var moving := Input.get_vector(
		player.KEY_BIND_LEFT,
		player.KEY_BIND_RIGHT,
		player.KEY_BIND_UP,
		player.KEY_BIND_DOWN
	).length() > 0.1

	if not moving:
		finished.emit("idle", {})
		return

	if not Input.is_action_pressed("run"):
		finished.emit("walk", {})
		return

	if not player._stamina.can_run:
		finished.emit("walk", {})