class_name door
extends RigidBody3D
@onready var hinge_joint_3d: HingeJoint3D = %HingeJoint3D
var must_close = false
var closed_rotation
func _ready() -> void:
	closed_rotation = global_rotation.y

func _process(delta: float) -> void:
	if rotation.y < closed_rotation - 0.5 or rotation.y > closed_rotation + 0.5:

		if %Timer.is_stopped():
			%Timer.start(5)

func interac():
		var rot_dir = 1
		var dir = global_position.direction_to(get_tree().get_first_node_in_group("player").global_position)
		if get_parent().rotation.y != 0:
			dir = -dir
		%Timer.stop()
		must_close = false
		apply_central_force(global_transform.basis.z * dir * 150)
		



func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var tangente = atan2(rotation.y,closed_rotation)
	
	if must_close:
		if tangente < -0.10 or tangente > 0.10:
			hinge_joint_3d.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR,true)
			hinge_joint_3d.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY,tangente * 2)
		else:
			must_close = false
			hinge_joint_3d.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR,false)
			angular_velocity = Vector3.ZERO
			linear_velocity = Vector3.ZERO
			%Timer.stop()

		
	


func _on_timer_timeout() -> void:
	must_close = true
