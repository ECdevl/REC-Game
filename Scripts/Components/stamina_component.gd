# Manages player stamina: drains while running, regenerates while idle/walking.
# Emits signals so the player script and UI can react without polling.
extends Component
class_name StaminaComponent

# Emitted when running state changes. [runing] = true means sprint started.
# [speed] = extra speed units added on top of base speed.
signal running(runing: bool, speed: float)

# Emitted every frame stamina changes — used by UI to update the stamina bar.
signal value_changed(new_value: float)

@export var max_stamina:       int   = 100
@export var stamina_degrade:   float = 0.5   ## Points lost per second while running.
@export var stamina_regen:     float = 1.5   ## Points gained per second while not running.
@export var extra_speed:       float = 2.0   ## Bonus speed added when sprinting.
@export var stamina_treshold:  int   = 50    ## Stamina must exceed this to allow running again.

var stamina: float = max_stamina :
	set(new):
		stamina = new
		emit_signal("value_changed", stamina)

# Whether the player is currently allowed to run.
# Set to false when stamina hits 0; recovers once stamina exceeds stamina_treshold.
var can_run: bool = true :
	set(new):
		can_run = new
		if not can_run:
			# Force-emit running=false so the player script resets speed immediately.
			emit_signal("running", false, extra_speed)

# Whether the player is actively holding the run key.
var is_run: bool = false :
	set(new):
		is_run = new
		emit_signal("running", is_run, extra_speed)


func _process(delta: float) -> void:
	if is_run and can_run:
		stamina -= stamina_degrade * delta
	elif not is_run and stamina < max_stamina:
		stamina += stamina_regen * delta

	if stamina <= 0.0:
		can_run = false
		is_run  = false
	elif stamina > stamina_treshold:
		can_run = true


# Connected to Player's toggle_run signal.
func _on_player_toggle_run(run: bool) -> void:
	is_run = run
