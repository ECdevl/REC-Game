extends Node3D


 # Tipado para mayor claridad y prevención de errores
@export var player: Player # Asegúrate de que Player sea el tipo correcto (e.g., CharacterBody3D o tu clase Player)
@export var GrabTarget: Node3D
@onready var ui_node: Control = %UI


signal slot_selected(slot)
var _held_object: RigidBody3D = null # Usamos un prefijo de guion bajo para variables internas
var holding_obj = false
var _current_slot: int = 1:
	set(new_value):
		_current_slot = new_value
		_equip_item() # Llamamos a la función con el prefijo
		emit_signal("slot_selected",new_value)
var _last_position: Vector3 = Vector3.ZERO # Mejor nombre para la variable

const THROW_FORCE: float = 15.0 # Constante para la fuerza de lanzamiento, fácil de ajustar
 # Constante para la ruta del nodo


func _process(delta: float) -> void:
	if %GrabLine.get_collider():
		if %GrabLine.get_collider().is_in_group("interact") or %GrabLine.get_collider().is_in_group("grab"):
			ui_node.can_grab = true
	else:
		ui_node.can_grab = false
	if _held_object:
		_held_object_logic() # Renombramos a una función más descriptiva


func _input(event: InputEvent) -> void:
	# Refactorizar la lógica de slots para ser más escalable.
	# Usar un bucle para manejar múltiples slots reduce la repetición.
	for i in range(1, 4): # Asumiendo slots del 1 al 3
		if event.is_action_pressed("slot%d" % i):
			_current_slot = i
			break # Salir del bucle una vez que se procesa el input



# --- Funciones Refactorizadas y Mejoradas ---



func _interact() -> void:
	# Usar get_node() con la constante para obtener el nodo de forma segura.
	


	var collider = grab_line.get_collider() as RigidBody3D
	if !collider:
		return
	elif collider and collider.is_in_group("grab"):
		if null in [Global.slot1,Global.slot2,Global.slot3]:
			_held_object = collider as RigidBody3D # Aseguramos el tipo
			Global.store_item(_held_object) # Guardar el objeto en el inventario
			if _current_slot < 3:
				_current_slot += 1
			return
	elif collider and collider.is_in_group("interact"):
		collider.interac()
		return

func _drop_object() -> void:
	if _held_object:
		# Restaurar capas de colisión y máscara
		if _held_object is RigidBody3D:
			# Es crucial asegurarse de que las capas que restauras sean las correctas para el objeto.
			_held_object.set_collision_layer_value(1, true)
			_held_object.set_collision_mask_value(1, true)
		
		# Eliminar la referencia del slot del inventario.
		# Considera una función en Global para manejar esto de manera más abstracta.
		_clear_inventory_slot(_current_slot)
		
		_held_object = null # Limpiar la referencia al objeto

func _throw_object() -> void:
	if _held_object:
		var throw_point = $Camera3D/GrabLine/ThrowPoint # Acceso directo al nodo
		if not throw_point:
			push_warning("Advertencia: Nodo 'ThrowPoint' no encontrado.")
			return

		# Calcular la dirección desde la posición del objeto a la posición del punto de lanzamiento.
		# Esto asegura que el lanzamiento vaya en la dirección de la cámara.
		var direction_to_throw = (_held_object.global_position - throw_point.global_position).normalized()
		# Aplicar una fuerza impulsiva para un lanzamiento más físico.
		if _held_object is RigidBody3D:
			_held_object.apply_central_impulse(-direction_to_throw * THROW_FORCE) # Impulso en la dirección opuesta

			# Restaurar capas de colisión y máscara después del lanzamiento.
			_held_object.set_collision_layer_value(1, true)
			_held_object.set_collision_mask_value(1, true)

		_clear_inventory_slot(_current_slot)
		_held_object = null

func _equip_item() -> void:
	# Si ya hay un objeto en la mano y cambiamos de slot, lo soltamos primero
	if _held_object:
		_held_object.queue_free() # Liberar el objeto actual si hay uno
		_held_object = null

	var item_packed_scene: PackedScene = null

	# Usar un `match` para obtener la PackedScene del slot correspondiente
	match _current_slot:
		1: item_packed_scene = Global.slot1
		2: item_packed_scene = Global.slot2
		3: item_packed_scene = Global.slot3
		_:
			push_warning("Slot de inventario inválido: %d" % _current_slot)
			return

	if item_packed_scene:
		# Instanciar y añadir el objeto a la escena
		var new_object = item_packed_scene.instantiate()
		get_tree().current_scene.add_child(new_object)
		_held_object = new_object as RigidBody3D # Aseguramos el tipo
		# Posicionar el objeto recién equipado inmediatamente
		if !_held_object:
			if _held_object:
				_held_object.queue_free()
			_held_object = null




func _held_object_logic() -> void:
	if not _held_object: return

	if _held_object is RigidBody3D:
		# Detener cualquier movimiento o rotación física del Rigidbody.
		_held_object.linear_velocity = Vector3.ZERO
		_held_object.angular_velocity = Vector3.ZERO

		# --- NUEVA LÓGICA DE TRANSFORMACIÓN: Seguir la cámara con offset y rotación local ---

		# 1. Obtener la Transformación base del GrabTarget (posición y rotación de la cámara).
		var target_transform: Transform3D = GrabTarget.global_transform

		# 2. Crear una Transformación para el objeto sostenido.
		var held_object_transform: Transform3D = Transform3D()

		# 3. Aplicar el offset y rotación específicos del objeto,
		# PERO COMO TRANSFORMACIONES RELATIVAS a la base del GrabTarget.
		if "held_rotation" in _held_object and "held_offset" in _held_object:
			var held_rot_euler = _held_object.held_rotation # Rotación en grados Euler
			var held_offset_vec = _held_object.held_offset   # Vector de offset

			# Convertir la rotación Euler del objeto a una Basis.
			# Esta Basis representa la rotación local deseada para el objeto.
			var local_rotation_basis = Basis()
			local_rotation_basis = local_rotation_basis.rotated(Vector3(1, 0, 0), deg_to_rad(held_rot_euler.x))
			local_rotation_basis = local_rotation_basis.rotated(Vector3(0, 1, 0), deg_to_rad(held_rot_euler.y))
			local_rotation_basis = local_rotation_basis.rotated(Vector3(0, 0, 1), deg_to_rad(held_rot_euler.z))

			# Construir la transformación local deseada del objeto:
			# Primero la rotación, luego la traslación (offset).
			held_object_transform = Transform3D(local_rotation_basis, held_offset_vec)

		# 4. Combinar la transformación del GrabTarget con la transformación local del objeto.
		# Esto coloca el objeto en la posición y orientación del GrabTarget,
		# y luego aplica su offset y rotación *relativos* a ese punto.
		_held_object.global_transform = target_transform * held_object_transform

		# --- FIN NUEVA LÓGICA DE TRANSFORMACIÓN ---

		# Desactivar colisiones mientras se sostiene el objeto.
		_held_object.set_collision_layer_value(1, false)
		_held_object.set_collision_mask_value(1, false)

	_last_position = _held_object.global_position

func _clear_inventory_slot(slot_index: int) -> void:
	# Función auxiliar para limpiar el slot del inventario
	match slot_index:
		1: Global.slot1 = null
		2: Global.slot2 = null
		3: Global.slot3 = null
