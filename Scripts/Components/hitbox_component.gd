# Hitbox that forwards damage to a HealthComponent.
# Place as an Area3D child. Connect body_entered or use it as a target for attacks.
extends Area3D
class_name HitboxComponent

# The HealthComponent that receives damage. Must be assigned in the Inspector.
@export var health: HealthComponent


# Call this from a weapon or monster script to deal damage.
func hit(dmg: int) -> void:
	if health:
		health.hurt(dmg)
