extends Node

# Emitted whenever a slot changes (used by UI to refresh icons).
signal slot_changed(which: int)

# ─── Inventory slots ───────────────────────────────────────────────────────────
# Each slot holds a PackedScene (the duplicated object) or null when empty.
# The setter emits slot_changed so the UI stays in sync automatically.

var slots : int = 3

var inventory : Array[PackedScene] 

func slot_selected(which:int):
	emit_signal("slot_changed",which)

func drop_item(where:int):
	inventory[where-1] = null
	emit_signal("slot_changed", where)  # Emit which slot changed (1-based index
	inventory.pop_at(where-1)  # where is 1-based index
	

# Packs [item] into a PackedScene and stores it in the first available slot.
# Then removes the original node from the scene tree.
#
# NOTE: item.duplicate() is used so the PackedScene is self-contained.
# Children need their owner set to the duplicated root before packing,
# otherwise pack() silently drops them.
func store_item(item: Node3D) -> void:
	# Check if at least one slot is free before doing any work.
	if inventory.size() >= slots:
		push_warning("No inventory slots available to store item: %s" % item.name)
		return

	# Duplicate the node so the packed scene is independent of the scene tree.
	var dupe := item.duplicate()

	# Set owner on all children so PackedScene.pack() includes them.
	for child in dupe.get_children():
		child.owner = dupe

	var scene := PackedScene.new()
	var err := scene.pack(dupe)
	dupe.queue_free()  # Duplicated node is no longer needed.

	if err != OK:
		push_error("PackedScene.pack() failed for item: %s (error %d)" % [item.name, err])
		return

	# Store in the first empty slot.
	inventory.append(scene)
	emit_signal("slot_changed", inventory.find(scene)+1)  # Emit which slot changed (1-based index).
	# Remove the original from the world now that it is safely packed.
	item.queue_free()
