extends Area3D
class_name HitboxComponent
@export var health : HealthComponent

func hit(dmg:int):
	if health:
		health.hurt(dmg)
