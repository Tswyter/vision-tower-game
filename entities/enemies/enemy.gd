extends CharacterBody2D

#------ ON READY ------#
@onready var health = get_node("Health")
@onready var sprite = $AnimatedSprite2D
@onready var death_sound = $DeathSound
@onready var jump_sound = $JumpSound

#------ VARIABLES ------#
var play_jump_sound = false
var original_modulate: Color
var speed = 0.15
var is_alive = true
var can_be_hit = false

enum State {
	IDLE,
	JUMP,
	DEATH,
	HIT
}

#region Built-In Functions
func _ready():
	z_index = 1
	original_modulate = sprite.modulate
	jump_sound.set_pitch_scale(randf_range(0, 2))
	death_sound.set_pitch_scale(randf_range(0, 4))
	health.max_health = 10
	health.current_health = health.max_health
	can_be_hit = true
	GraphManager.add_node(self)

func _physics_process(delta):
	if get_tree().get_nodes_in_group("player").size() > 0:
		var player = get_tree().get_nodes_in_group("player")[0]
		if not is_instance_valid(player):
			return
		if is_alive:
			var direction = player.global_position
			if direction:
				velocity = (direction - global_position) * speed * delta
				sprite.play("jump")

			var collision = move_and_collide(velocity)
			if collision:
				var collider = collision.get_collider()
				if collider.name == "Player":
					collider.health.take_damage(10)
					health.take_damage(100)
#endregion

#region signals
func _on_enemy_died():
	if get_tree():
		is_alive = false
		sprite.play("death")
		jump_sound.stream_paused = true
		death_sound.play()
		await get_tree().create_timer(0.66).timeout
		death_sound.stream_paused = true
		queue_free()

func _on_health_entity_took_damage():
	if get_tree():
		sprite.play("hit")
#endregion
