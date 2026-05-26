extends Panel
class_name UISlot


var scene : PackedScene = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = 0

var tween_fade : Tween = null

func set_new_scene(new_scene: PackedScene) -> void:
	scene = new_scene
	if scene:
		%icon1.show()
		var instance = scene.instantiate() as RigidBody3D
		%icon1.show_icon(instance)
	else:
		%icon1.hide()

	if get_tree():
		if tween_fade:
			tween_fade.kill()
		modulate.a = 1
		await get_tree().create_timer(0.5).timeout
		tween_fade = create_tween()
		tween_fade.tween_property(self, "modulate:a", 0, 1)
