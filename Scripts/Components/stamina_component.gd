extends Node3D
signal running(runing,speed)
signal value_changed(new_value)
@export var max_stamina : int = 100
@export var stamina_degrade : float = 0.5
@export var stamina_regen : float = 1.5
@export var extra_speed : float = 2.0
@export var stamina_treshold : int = 50

var stamina = max_stamina : 
	set(new):
		stamina = new
		emit_signal("value_changed",stamina)
var can_run : bool = true : 
	set(new):
		can_run = new
		if !can_run:
			emit_signal("running",!is_run,extra_speed)
var is_run : bool = false : 
	set(new):
		is_run = new
		emit_signal("running",is_run,extra_speed)




func _process(delta: float) -> void:
	if is_run and can_run:
		stamina -= stamina_degrade * delta
		
	elif !is_run and stamina < max_stamina:
		stamina += stamina_regen * delta
	
	
	
	if stamina <= 0:
		can_run = false
		is_run = false
	elif stamina > stamina_treshold:
		can_run = true




func _on_player_toggle_run(run:bool) -> void:
	is_run = run
