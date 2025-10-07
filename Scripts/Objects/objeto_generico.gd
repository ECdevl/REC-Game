class_name obj
extends CollisionObject3D

@export var held_rotation: Vector3 = Vector3(0, 0, 0) # Rotación en grados Euler
@export var held_offset: Vector3 = Vector3(0, 0, 0)   # Opcional: para ajustar la posición

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("grab")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
