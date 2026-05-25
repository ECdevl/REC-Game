extends Node3D
class_name MeshIcon

func _ready() -> void:
	global_position = Vector3(0,99999,0)

func get_icon(obj : PackedScene):
	if obj != null:
		var mesh : MeshInstance3D
		var instancia = obj.instantiate()
		for i in instancia.get_children():
			if i is MeshInstance3D:
				mesh = i
		var arrayMesh = mesh.mesh
		%pos.mesh = arrayMesh
		%pos.material_override = mesh.material_override
		var img = $SubViewportContainer/SubViewport.get_texture()
		img = img.get_image()
		var tex = ImageTexture.create_from_image(img)

		instancia.queue_free()
		
		
		
		return tex
