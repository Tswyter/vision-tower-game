extends Node
class_name Health

@export var max_health = 100.0
var current_health = max_health

signal entity_died
signal entity_took_damage
signal entity_healed

func take_damage(amount):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	emit_signal("entity_took_damage")
	if current_health <= 0:
		die()
	
func heal(amount):
	current_health += amount
	if current_health >= max_health:
		current_health = max_health
	emit_signal("entity_healed")

func die():
	emit_signal("entity_died")
