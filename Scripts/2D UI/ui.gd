extends Control
class_name UI

signal grab_tip_toggle
@onready var slots_scene = preload("res://Scenes/2D UI/slot.tscn")


var can_grab : bool = false : 
	set(new):
		can_grab = new
		can_grab_tip()
	

func _ready() -> void:
	Global.connect("slot_changed",Callable(self,"_on_slot_changed"))
	for i in Global.slots:
		var slot : UISlot = slots_scene.instantiate()
		slot.name = "Slot%d" % (i+1)
		if Global.inventory.size() > i:
			if Global.inventory[i]:
				slot.set_new_scene(Global.inventory[i])
		%Inventory.add_child(slot)



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("salir"):
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			%PauseMenu.show()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			%PauseMenu.hide()

func can_grab_tip():
	if can_grab:

		var event =  InputMap.action_get_events("grab")[0]
		%Key.text = "[" + event.as_text() + "]"
		%Key.show()
		
	else:
		%Key.hide()
	


func _on_slot_changed(which:int):
	print_debug(Global.inventory.size(), " ", which)
	var slot_select = %Inventory.get_child(which-1) as UISlot
	if Global.inventory.size() >= which and Global.inventory[which-1] != null:
		slot_select.set_new_scene(Global.inventory[which-1])
	else:
		slot_select.set_new_scene(null)
	

	

func _on_player_slot_selected(slot: Variant) -> void:
	var slot_select = %Inventory.get_child(slot-1) as UISlot



func _on_stamina_component_value_changed(new_value: Variant) -> void:
	%StaminaBar.value = new_value
