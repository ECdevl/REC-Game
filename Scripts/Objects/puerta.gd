# Door controller using a HingeJoint3D for physics-based swinging.
#
# CURRENT BEHAVIOUR (prototype):
#   - Player interacts → door gets a force push in the direction away from the player.
#   - After 5 seconds of being open, the door motor closes it automatically.
#
# KNOWN ISSUES / THINGS YOU MAY WANT TO REVISIT:
#   1. The direction logic uses get_first_node_in_group("player") every interaction,
#      which couples the door to a global group. Works fine, but consider passing
#      the player reference explicitly if you need multiplayer or multiple players.
#   2. get_parent().rotation.y != 0 is an imprecise float comparison. If you find
#      the door pushing the wrong way, replace with:
#          if not is_zero_approx(get_parent().rotation.y)
#   3. The motor closing speed (tangente * 2) is hardcoded. Expose it as @export
#      if you want to tune it per door.
#   4. _integrate_forces runs every physics frame even when the door is still.
#      Consider disabling the motor entirely when must_close is false.

class_name door
extends RigidBody3D

# Reference to the hinge joint that constrains the door rotation.
# Must be set as a unique node (%HingeJoint3D) in the scene.
@onready var hinge_joint_3d: HingeJoint3D = %HingeJoint3D

# Tracks whether the auto-close routine is active.
var must_close: bool = false

# Y rotation (radians) when the door is fully closed — captured at _ready.
var closed_rotation: float = 0.0


func _ready() -> void:
	# Store the resting rotation so we know when the door has swung open.
	closed_rotation = global_rotation.y


func _process(_delta: float) -> void:
	# If the door has swung more than 0.5 rad from closed, start the auto-close timer.
	var angle_diff := absf(rotation.y - closed_rotation)
	if angle_diff > 0.5:
		if %Timer.is_stopped():
			%Timer.start(5.0)


func interac() -> void:
	# Find the player to determine which side they are standing on.
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("door.interac(): no node in group 'player' found.")
		return

	var dir := global_position.direction_to(player.global_position)

	# If the door parent is rotated, invert the push direction so it always
	# swings away from the player regardless of the door's world orientation.
	# TODO: replace != 0 with is_zero_approx check for float safety.
	if get_parent().rotation.y != 0:
		dir = -dir

	# Cancel auto-close and apply the opening impulse.
	%Timer.stop()
	must_close = false
	apply_central_force(global_transform.basis.z * dir * 150.0)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not must_close:
		return

	# atan2 gives a signed angle that drives the motor back toward closed_rotation.
	# NOTE: this is an approximation — for a more robust solution consider
	# computing the actual angular error against closed_rotation directly.
	var tangente := atan2(rotation.y, closed_rotation)

	if absf(tangente) > 0.10:
		# Drive the motor toward the closed position.
		hinge_joint_3d.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, true)
		hinge_joint_3d.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, tangente * 2.0)
	else:
		# Door is close enough to closed — stop and lock it.
		must_close = false
		hinge_joint_3d.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, false)
		state.angular_velocity = Vector3.ZERO
		state.linear_velocity  = Vector3.ZERO
		%Timer.stop()


func _on_timer_timeout() -> void:
	must_close = true
