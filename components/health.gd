extends Node
class_name Health

@export var max_health = 100.0
var health_bar : TextureProgressBar
var health_bar_label : Label
var current_health = max_health

signal entity_died
signal entity_took_damage
signal entity_healed

func _ready():
	health_bar = get_parent().get_node("HealthBar")
	health_bar_label = health_bar.get_node("Label")

func update_health_bar():
	if !is_instance_valid(health_bar):
		return
	var health_ratio = current_health / max_health
	health_bar.value = current_health
	health_bar_label.text = str(health_ratio * 100) + "%"

func take_damage(amount):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	update_health_bar()
	emit_signal("entity_took_damage")
	if current_health <= 0:
		die()
	
func heal(amount):
	current_health += amount
	if current_health >= max_health:
		current_health = max_health
	update_health_bar()
	emit_signal("entity_healed")

func die():
	emit_signal("entity_died")
