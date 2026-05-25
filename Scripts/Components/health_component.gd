# Manages health for any entity. Attach as a child node.
# Call hurt() or heal() from outside. Death is delegated to the parent.
extends Component
class_name HealthComponent

@export var health: int = 100


# Deal [dmg] points of damage. Triggers death() if health drops to zero or below.
func hurt(dmg: int) -> void:
	health -= dmg
	if health <= 0:
		death()


# Restore [hp] points of health. No upper cap — add one if needed.
func heal(hp: int) -> void:
	health += hp


# Called when health reaches zero.
# If the parent has a death() method, delegates to it (allows custom death logic).
# Otherwise simply removes the parent from the scene tree.
func death() -> void:
	if get_parent().has_method("death"):
		get_parent().death()
	else:
		get_parent().queue_free()
