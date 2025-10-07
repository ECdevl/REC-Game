extends Node3D
class_name HealthComponent

@export var health : int = 100

func hurt(dmg:int):
	health -= dmg
	if health <= 0:
		death()

func heal(hp:int):
	health += hp

func death():
	if get_parent().has_method("death"):
		get_parent().death()
	else:
		get_parent().queue_free()
