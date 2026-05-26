class_name Player
extends CharacterBody3D

# ─────────────────────────────────────────
#  SEÑALES
# ─────────────────────────────────────────
signal toggle_run(run: bool)
signal slot_selected(slot: int)

# ─────────────────────────────────────────
#  REFERENCIAS
# ─────────────────────────────────────────
@export var _look_component : LookingatComponent

@onready var _head: Node3D                   = $Head
@onready var _camera: Camera3D               = $Head/Camera3D
@onready var _anim_body: AnimationPlayer     = $NPC/AnimationPlayer
@onready var _anim_player: AnimationPlayer   = $AnimationPlayer
@onready var _stamina: StaminaComponent                = $StaminaComponent
@onready var _ui: Control                    = %UI
@onready var _grab_target: Node3D            = %GrabTarget
@onready var state_machine: StateMachine     = $StateMachine
@onready var standing_collision = %stand
@onready var crouching_collision = %crouch

# ─────────────────────────────────────────
#  EXPORTS
# ─────────────────────────────────────────
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

@export_subgroup("Head Bob")
@export var BOB_FREQ := 2.4
@export var BOB_AMP := 0.08

@export_subgroup("Limitar rotación de cabeza")
@export var CLAMP_HEAD_ROTATION := true
@export var CLAMP_HEAD_ROTATION_MIN := -90.0
@export var CLAMP_HEAD_ROTATION_MAX := 90.0

@export_category("Mouse")
@export var MOUSE_ACCEL := true
@export var KEY_BIND_MOUSE_SENS := 0.005
@export var KEY_BIND_MOUSE_ACCEL := 50

@export_category("Teclas asignadas")
@export var KEY_BIND_UP := "forward"
@export var KEY_BIND_LEFT := "left"
@export var KEY_BIND_RIGHT := "right"
@export var KEY_BIND_DOWN := "back"
@export var KEY_BIND_JUMP := "ui_accept"

@export_category("Stun")
@export var STUN_DURATION := 2.0

# ─────────────────────────────────────────
#  VARIABLES
# ─────────────────────────────────────────
var input_dir: Vector2 = Vector2.ZERO
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var current_speed := SPEED
var _speed := SPEED
var _accel := ACCEL

var rotation_target_player: float = 0.0
var rotation_target_head: float = 0.0

var t_bob: float = 0.0

var holding: RigidBody3D = null

var current_slot: int = 1:
	set(new):
		current_slot = new
		_equip_item()
		Global.slot_selected(new)  # Emit which slot was selected (1-based index)
		

# ─────────────────────────────────────────
#  READY
# ─────────────────────────────────────────
func _ready() -> void:
	connect("slot_selected", Callable(self, "_slot_selected"))
	if CAPTURE_ON_START:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ─────────────────────────────────────────
#  INPUT
# ─────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_set_rotation_target(event.relative)

	if event.is_action_pressed("grab"):
		_interact()


	if event.is_action_pressed("throw"):
		_throw_object()

	if event.is_action_pressed("release"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	for i in range(1, 4):
		if event.is_action_pressed("slot%d" % i):
			current_slot = i
			break

# ─────────────────────────────────────────
#  PROCESS
# ─────────────────────────────────────────
func _process(delta: float) -> void:
	_update_grab_ui()

	if holding:
		_holding_logic()

func _update_grab_ui() -> void:
	if _look_component.looking_at == null:
		_ui.can_grab = false
	else:
		_ui.can_grab = true
		

# ─────────────────────────────────────────
#  PHYSICS
# ─────────────────────────────────────────
func _physics_process(delta: float) -> void:
	_move_player(delta)
	_rotate_player(delta)

	t_bob += delta * velocity.length() * float(is_on_floor())
	_head.get_child(0).transform.origin = _headbob(t_bob)

# ─────────────────────────────────────────
#  MOVIMIENTO
# ─────────────────────────────────────────
func _move_player(delta: float) -> void:
	if not is_on_floor():
		_speed = IN_AIR_SPEED
		_accel = IN_AIR_ACCEL
		velocity.y -= gravity * delta
	else:
		_speed = current_speed
		_accel = ACCEL

	if Input.is_action_just_pressed(KEY_BIND_JUMP) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	input_dir = Input.get_vector(KEY_BIND_LEFT, KEY_BIND_RIGHT, KEY_BIND_UP, KEY_BIND_DOWN)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	velocity.x = move_toward(velocity.x, direction.x * _speed, _accel * delta)
	velocity.z = move_toward(velocity.z, direction.z * _speed, _accel * delta)

	move_and_slide()

func _rotate_player(delta: float) -> void:
	$NPC/Cuerpo/Cintura/Torso/Cuello.quaternion = _head.quaternion

	if MOUSE_ACCEL:
		quaternion = quaternion.slerp(
			Quaternion(Vector3.UP, rotation_target_player),
			KEY_BIND_MOUSE_ACCEL * delta
		)

		_head.quaternion = _head.quaternion.slerp(
			Quaternion(Vector3.RIGHT, rotation_target_head),
			KEY_BIND_MOUSE_ACCEL * delta
		)
	else:
		quaternion = Quaternion(Vector3.UP, rotation_target_player)
		_head.quaternion = Quaternion(Vector3.RIGHT, rotation_target_head)

func _set_rotation_target(mouse_motion: Vector2) -> void:
	rotation_target_player += -mouse_motion.x * KEY_BIND_MOUSE_SENS
	rotation_target_head += -mouse_motion.y * KEY_BIND_MOUSE_SENS

	if CLAMP_HEAD_ROTATION:
		rotation_target_head = clamp(
			rotation_target_head,
			deg_to_rad(CLAMP_HEAD_ROTATION_MIN),
			deg_to_rad(CLAMP_HEAD_ROTATION_MAX)
		)

func _headbob(time: float) -> Vector3:
	var pos := Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2.0) * BOB_AMP
	return pos

# ─────────────────────────────────────────
#  STUN API
# ─────────────────────────────────────────
#func stun() -> void:
#	state_machine._transition_to_next_state("StunnedState")

# ─────────────────────────────────────────
#  INVENTARIO / INTERACCION
# ─────────────────────────────────────────
# TODO: dejar acá todo lo de interactuar,
# equipar items, agarrar objetos, tirar objetos,
# UI de grab, etc...

func _interact() -> void:
	if _look_component.looking_at == null:
		return

	var target := _look_component.looking_at

	if target is GrabObject:
		
		# El inventario tiene espacio
		if Global.inventory.size() < Global.slots:
			print_debug("intente agarrarlo")
			if holding:
				_drop_object()
			holding = target as RigidBody3D
			Global.store_item(holding)
			_equip_item()
		return

	if target.is_in_group("interact") or target is DoorComponent:
		target.interact(self)


func _equip_item() -> void:
	
	if holding:
		holding.queue_free()
		holding = null

	var item_scene: PackedScene = null
	if Global.inventory.size() >= current_slot:
		item_scene = Global.inventory[current_slot-1]  # current_slot is 1-based index
	emit_signal("slot_selected", current_slot)
	if item_scene == null:
		return
	
	var new_obj := item_scene.instantiate()
	get_tree().current_scene.add_child(new_obj)

	if not new_obj is RigidBody3D:
		new_obj.queue_free()
		return

	holding = new_obj as RigidBody3D
	


func _holding_logic() -> void:
	holding.linear_velocity  = Vector3.ZERO
	holding.angular_velocity = Vector3.ZERO

	var target_transform := _grab_target.global_transform
	var held_transform   := Transform3D()

	if "held_rotation" in holding and "held_offset" in holding:
		var rot_euler: Vector3 = holding.held_rotation
		var offset:    Vector3 = holding.held_offset

		var local_basis := Basis()
		local_basis = local_basis.rotated(Vector3(1, 0, 0), deg_to_rad(rot_euler.x))
		local_basis = local_basis.rotated(Vector3(0, 1, 0), deg_to_rad(rot_euler.y))
		local_basis = local_basis.rotated(Vector3(0, 0, 1), deg_to_rad(rot_euler.z))

		held_transform = Transform3D(local_basis, offset)

	holding.global_transform = target_transform * held_transform
	holding.set_collision_layer_value(1, false)
	holding.set_collision_mask_value(1, false)
	holding.remove_from_group("grab")


func _throw_object() -> void:
	if holding == null:
		return

	# basis.z apunta hacia atrás de la cámara; negarlo = adelante
	var throw_dir: Vector3 = -_camera.global_transform.basis.z
	holding.apply_central_impulse(throw_dir * THROW_FORCE)
	holding.set_collision_layer_value(1, true)
	holding.set_collision_mask_value(1, true)
	holding.add_to_group("grab")

	_clear_inventory_slot(current_slot)
	holding = null


func _drop_object() -> void:
	if holding == null:
		return

	holding.set_collision_layer_value(1, true)
	holding.set_collision_mask_value(1, true)
	holding.add_to_group("interactable")

	_clear_inventory_slot(current_slot)
	holding = null


func _clear_inventory_slot(slot_index: int) -> void:
	Global.drop_item(slot_index)


# ─────────────────────────────────────────
#  SEÑALES RECIBIDAS
# ─────────────────────────────────────────
func _on_stamina_component_running(runing: bool, speed: float) -> void:
	if runing:
		current_speed = SPEED + speed
	else:
		current_speed = SPEED
