extends Node

signal slot_changed(which)




var slot1 = null :
	set(new):
		
		slot1 = new
		emit_signal("slot_changed",1)
		
var slot2 = null :
	set(new):
		slot2 = new
		emit_signal("slot_changed",2)
var slot3 = null :
	set(new):
		slot3 = new
		emit_signal("slot_changed",3)





func store_item(item:Node3D):
	var nodo = item.duplicate()
	var scene = PackedScene.new()
	
	for i in nodo.get_children():
		i.owner = nodo
	scene.pack(nodo)
	if null in [slot1,slot2,slot3]:
		if slot1 == null:
			slot1 = scene
		elif slot2 ==null:
			slot2 = scene
		elif slot3 == null:
			slot3 = scene
	else:
		print_debug("ME CAGO EN LA PUTAAAA")
		return
	
	item.queue_free()
