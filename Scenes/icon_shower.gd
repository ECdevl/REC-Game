extends SubViewportContainer

func show_icon(obj:Node3D = null):
	if obj != null:
		var obj_mesh : MeshInstance3D
		for i in obj.get_children():
			if i is MeshInstance3D:
				obj_mesh = i
				print_debug(i)
		$SubViewport/Camera3D/MeshInstance3D.mesh = obj_mesh.mesh
	else:
		$SubViewport/Camera3D/MeshInstance3D.mesh = null
