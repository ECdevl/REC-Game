class_name Inventory
extends Resource

signal slot_changed(slot)

@export var slot1 : PackedScene  : 
	set(new):
		emit_signal("slot_changed",1)
@export var slot2 : PackedScene  : 
	set(new):
		emit_signal("slot_changed",2)
@export var slot3 : PackedScene : 
	set(new):
		emit_signal("slot_changed",3)
