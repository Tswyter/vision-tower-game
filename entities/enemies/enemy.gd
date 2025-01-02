extends CharacterBody2D

@onready var health = get_node("Health")
@onready var sprite = $AnimatedSprite2D
var original_modulate: Color

const SPEED = 0.15

var is_alive = true

func _ready():
	z_index = 1
	original_modulate = sprite.modulate

func _physics_process(delta):
	if get_tree().get_nodes_in_group("player").size() > 0:
		var player = get_tree().get_nodes_in_group("player")[0]
		if not is_instance_valid(player):
			return
		if is_alive:
			var direction = player.global_position
			if direction:
				velocity = (direction - global_position) * SPEED * delta

			var collision = move_and_collide(velocity)
			if collision:
				var collider = collision.get_collider()
				if collider.name == "Player":
					collider.health.take_damage(10)
					health.take_damage(100)

func _on_enemy_died():
	is_alive = false
	sprite.self_modulate = Color(255,0,0)
	queue_free()
	# show dead animation
	# stop moving

func flash_effect():
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = original_modulate

func _on_health_entity_took_damage():
	if get_tree():
		sprite.self_modulate = Color(255,0,0)
		await get_tree().create_timer(0.25).timeout
		sprite.self_modulate = Color(1,1,1)
