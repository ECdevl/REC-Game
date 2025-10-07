extends Control
class_name UI

var can_grab : bool = false : 
	set(new):
		can_grab = new
		can_grab_tip()
	

func _ready() -> void:
	Global.connect("slot_changed",Callable(self,"_on_slot_changed"))




func _input(event: InputEvent) -> void:
	if event.is_action_pressed("salir"):
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			%Crosshair.hide()
			%PauseMenu.show()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			%PauseMenu.hide()
			%Crosshair.show()

func can_grab_tip():
	if can_grab:
		var tween = get_tree().create_tween()
		tween.tween_property(%spr,"scale",Vector2(1,1),0.5)
		%spr.modulate = Color(0,255,0)
		var event =  InputMap.action_get_events("grab")[0]
		$Crosshair/Key.text = "[" + event.as_text() + "]"
		$Crosshair/Key.show()
		
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(%spr,"scale",Vector2(0.5,0.5),0.5)
		%spr.modulate = Color(1, 1.0, 1.0)
		$Crosshair/Key.hide()
	


func _on_slot_changed(which:int):
	match which:
		1:
			if Global.slot1:
				var instance = Global.slot1.instantiate() as RigidBody3D
				%icon1.show_icon(instance)
			else:
				%icon1.show_icon()
		2:
			if Global.slot2:
				var instance = Global.slot2.instantiate() as RigidBody3D
				%icon2.show_icon(instance)
			else:
				%icon2.show_icon()
		3:
			if Global.slot3:
				var instance = Global.slot3.instantiate()
				%icon3.show_icon(instance)
			else:
				%icon3.show_icon()
func _on_player_slot_selected(slot: Variant) -> void:
	match slot:
		1:
			%SLOT1.get_child(1).play("select")
		2:
			%SLOT2.get_child(1).play("select")
		3:
			%SLOT3.get_child(1).play("select")


func _on_stamina_component_value_changed(new_value: Variant) -> void:
	%StaminaBar.value = new_value
