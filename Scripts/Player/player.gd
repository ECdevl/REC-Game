class_name Player
extends CharacterBody3D

var addedHead = false
signal toggle_run(run:bool)

func _enter_tree():

	if find_child("Head"):
		addedHead = true
	else:
		push_error("no se encontro el nodo para la cabeza, se te olvido agregarlo?")
		print("Recuerda que el nodo 'Head' debe contener un Camera3D como hijo")
	
@export var LookComponent : LookingatComponent

## PLAYER MOVMENT SCRIPT ##
###########################
var input_dir
@export_category("Mouse Capture")
@export var CAPTURE_ON_START := true

@export_category("Movement")
@export_subgroup("Settings")
@export var SPEED := 5.0
@export var ACCEL := 50.0
@export var IN_AIR_SPEED := 3.0
@export var IN_AIR_ACCEL := 5.0
@export var JUMP_VELOCITY := 4.5
@export var THROW_FORCE := 15.0
@export_subgroup("Movimineot de Cabeza")
@export var BOB_FREQ = 2.4
@export var BOB_AMP = 0.08
@export var t_bob = 0.0
@export_subgroup("Limitar rotacion de cabeza")
@export var CLAMP_HEAD_ROTATION := true
@export var CLAMP_HEAD_ROTATION_MIN := -90.0
@export var CLAMP_HEAD_ROTATION_MAX := 90.0

@export_category("Teclas asignadas")
@export_subgroup("Mouse")
@export var MOUSE_ACCEL := true
@export var KEY_BIND_MOUSE_SENS := 0.005
@export var KEY_BIND_MOUSE_ACCEL := 50
@export_subgroup("Movimiento")
@export var KEY_BIND_UP := "forward"
@export var KEY_BIND_LEFT := "left"
@export var KEY_BIND_RIGHT := "right"
@export var KEY_BIND_DOWN := "back"
@export var KEY_BIND_JUMP := "ui_accept"

var tween : Tween


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# To keep track of current speed and acceleration
var current_speed = SPEED
var speed = current_speed
var accel = ACCEL

# Used when lerping rotation to reduce stuttering when moving the mouse
var rotation_target_player : float
var rotation_target_head : float

# Used when bobing head
var head_start_pos : Vector3

# Current player tick, used in head bob calculation
var tick = 0


func _ready():
	
	tween = get_tree().create_tween()
		
	# Capture mouse if set to true
	if CAPTURE_ON_START:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED





var crouched : bool = false


func _process(delta: float) -> void:
	if holding:
		holding_logic()
	
	if LookComponent.looking_at:
		if LookComponent.looking_at.is_in_group("interact") or LookComponent.looking_at.is_in_group("grab"):
			%UI.can_grab = true
		else:
			%UI.can_grab = false
	else:
		%UI.can_grab = false
	
	if Input.is_action_just_pressed("release"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	if Input.is_action_just_pressed("crouch") and !Input.is_action_pressed("run"):
		$AnimationPlayer.play("crouch")
		$crouch.disabled = false
		$stand.disabled = true
		crouched = true
		current_speed = SPEED / 2
	if Input.is_action_just_released("crouch"):
		$AnimationPlayer.play_backwards("crouch")
		$AnimationPlayer.queue("standup")
		$crouch.disabled = true
		$stand.disabled = false
		crouched = false
		current_speed = SPEED
	#elif $AnimationPlayer.current_animation == "crouched" and !$canStand.is_colliding():
		#$AnimationPlayer.play_backwards("crouch")
		#$AnimationPlayer.queue("standup")
		#crouched = false
		#current_speed = SPEED

	if !crouched:
		if Input.is_action_just_pressed("run"):
			emit_signal("toggle_run",true)
		if !Input.is_action_pressed("run"):
			emit_signal("toggle_run",false)


func _physics_process(delta):
	tick += 1

	move_player(delta)
	rotate_player(delta)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	$Head.get_child(0).transform.origin = _headbob(t_bob)
signal slot_selected(slot)
var current_slot = 1 :
	set(new):
		current_slot = new
		_equip_item()
		emit_signal("slot_selected",new)

func _input(event):
	if event.is_action_pressed("grab"):
		_interact()

	if event.is_action_pressed("throw"):
		_throw_object()


	for i in range(1, 4): # Asumiendo slots del 1 al 3
		if event.is_action_pressed("slot%d" % i):
			current_slot = i
			break # Salir del bucle una vez que se procesa el input
	# Obtener el movimiento del mouse
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		set_rotation_target(event.relative)


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func set_rotation_target(mouse_motion : Vector2):
	# Obtener el objetivo de rotacion del eje X e Y
	rotation_target_player += -mouse_motion.x * KEY_BIND_MOUSE_SENS
	rotation_target_head += -mouse_motion.y * KEY_BIND_MOUSE_SENS
	# Clamp rotation
	if CLAMP_HEAD_ROTATION:
		rotation_target_head = clamp(rotation_target_head, deg_to_rad(CLAMP_HEAD_ROTATION_MIN), deg_to_rad(CLAMP_HEAD_ROTATION_MAX))
func rotate_player(delta):
	$NPC/Cuerpo/Cintura/Torso/Cuello.quaternion = $Head.quaternion
	if MOUSE_ACCEL:
		# Shperical lerp between player rotation and target
		quaternion = quaternion.slerp(Quaternion(Vector3.UP, rotation_target_player), KEY_BIND_MOUSE_ACCEL * delta)
		# Same again for head
		$Head.quaternion = $Head.quaternion.slerp(Quaternion(Vector3.RIGHT, rotation_target_head), KEY_BIND_MOUSE_ACCEL * delta)
		
	else:
		# If mouse accel is turned off, simply set to target
		quaternion = Quaternion(Vector3.UP, rotation_target_player)
		$Head.quaternion = Quaternion(Vector3.RIGHT, rotation_target_head)
	
func move_player(delta):
	if velocity != Vector3.ZERO:
		$NPC/AnimationPlayer.play("Caminar")

	else:
		$NPC/AnimationPlayer.play("RESET")

	# Check if not on floor
	if not is_on_floor():
		# Reduce speed and accel
		speed = IN_AIR_SPEED
		accel = IN_AIR_ACCEL
		# Add the gravity
		velocity.y -= gravity * delta
	else:
		# Set speed and accel to defualt
		speed = current_speed
		accel = ACCEL

	# Handle Jump.
	if Input.is_action_just_pressed(KEY_BIND_JUMP) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	input_dir = Input.get_vector(KEY_BIND_LEFT, KEY_BIND_RIGHT, KEY_BIND_UP, KEY_BIND_DOWN)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)

	move_and_slide()

var holding = null
func _interact() -> void:
	# Usar get_node() con la constante para obtener el nodo de forma segura.
	if LookComponent.looking_at and LookComponent.looking_at.is_in_group("grab"):
		if null in [Global.slot1,Global.slot2,Global.slot3]:
			if holding:
				_drop_object()
				holding = LookComponent.looking_at as RigidBody3D # Aseguramos el tipo
				Global.store_item(holding) # Guardar el objeto en el inventario
				_equip_item()
				return
			else:
				holding = LookComponent.looking_at as RigidBody3D # Aseguramos el tipo
				Global.store_item(holding) # Guardar el objeto en el inventario
			
			if current_slot < 3:
				current_slot += 1
			return
	elif LookComponent.looking_at and LookComponent.looking_at.is_in_group("interact"):
		LookComponent.looking_at.interac()
		return

func _equip_item() -> void:
	# Si ya hay un objeto en la mano y cambiamos de slot, lo soltamos primero
	if holding:
		holding.queue_free() # Liberar el objeto actual si hay uno
		holding = null

	var item_packed_scene = null

	# Usar un `match` para obtener la PackedScene del slot correspondiente
	match current_slot:
		1: item_packed_scene = Global.slot1
		2: item_packed_scene = Global.slot2
		3: item_packed_scene = Global.slot3
		_:
			return

	if item_packed_scene:
		# Instanciar y añadir el objeto a la escena
		var new_object = item_packed_scene.instantiate()
		get_tree().current_scene.add_child(new_object)
		holding = new_object as RigidBody3D 
		if !holding:
			if holding:
				holding.queue_free()
			holding = null


func holding_logic() -> void:
	holding.linear_velocity = Vector3.ZERO
	holding.angular_velocity = Vector3.ZERO
	
	var target_transform: Transform3D = %GrabTarget.global_transform

	var held_object_transform: Transform3D = Transform3D()

	if "held_rotation" in holding and "held_offset" in holding:
		var held_rot_euler = holding.held_rotation # Rotación en grados Euler
		var held_offset_vec = holding.held_offset   # Vector de offset

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
	holding.global_transform = target_transform * held_object_transform
	holding.set_collision_layer_value(1, false)
	holding.set_collision_mask_value(1, false)

func _throw_object() -> void:
	if holding:
		# Calcular la dirección desde la posición del objeto a la posición del punto de lanzamiento.
		# Esto asegura que el lanzamiento vaya en la dirección de la cámara.
		var direction_to_throw = $Head/Camera3D.global_transform.basis.z
		# Aplicar una fuerza impulsiva para un lanzamiento más físico.
		if holding is RigidBody3D:
			holding.apply_central_impulse(-direction_to_throw * THROW_FORCE) # Impulso en la dirección opuesta

			# Restaurar capas de colisión y máscara después del lanzamiento.
			holding.set_collision_layer_value(1, true)
			holding.set_collision_mask_value(1, true)

		_clear_inventory_slot(current_slot)
		holding = null

func _drop_object() -> void:
	if holding:
		# Restaurar capas de colisión y máscara
		if holding is RigidBody3D:
			# Es crucial asegurarse de que las capas que restauras sean las correctas para el objeto.
			holding.set_collision_layer_value(1, true)
			holding.set_collision_mask_value(1, true)
		
		# Eliminar la referencia del slot del inventario.
		# Considera una función en Global para manejar esto de manera más abstracta.
		_clear_inventory_slot(current_slot)
		
		holding = null # Limpiar la referencia al objeto

func _clear_inventory_slot(slot_index: int) -> void:
	# Función auxiliar para limpiar el slot del inventario
	match slot_index:
		1: Global.slot1 = null
		2: Global.slot2 = null
		3: Global.slot3 = null


func _on_stamina_component_running(runing: Variant, speed: Variant) -> void:
	if runing:
		current_speed = SPEED + speed
	else:
		current_speed = SPEED
