extends CharacterBody2D

@onready var health = get_node("Health")
@onready var sprite = $AnimatedSprite2D
@onready var attack_range = $AttackRange

@export var projectile_scene: PackedScene
@export var fire_rate: float = 3.0

var enemy_targets = []
var can_fire: bool = true

func _ready():
	z_index = 10

func _process(_delta):
	reprioritize_targets()
	if enemy_targets.size() > 0:
		for enemy in enemy_targets:
			if can_fire:
				shoot_projectile(enemy)

func shoot_projectile(target):
	if !can_fire:
		return
	
	if !projectile_scene:
		print("Projectile scene not assigned!")
		return

	if target and is_instance_valid(target):
		var projectile = projectile_scene.instantiate()
		projectile.target = target
		add_child(projectile)
		
		can_fire = false
		await get_tree().create_timer(fire_rate).timeout
		can_fire = true
	
func detect_targets(entity):
	if entity.is_in_group("enemies") or entity.is_in_group("pylons"):
		enemy_targets.append(entity)

func reprioritize_targets():
	enemy_targets.filter(remove_dead_targets)
	enemy_targets.sort_custom(compare_distance)

func remove_dead_targets(entity):
	return is_instance_valid(entity)

func compare_distance(a, b):
	if !is_instance_valid(a) or !is_instance_valid(b):
		return
	var distance_a = global_position.distance_to(a.global_position)
	var distance_b = global_position.distance_to(b.global_position)
	return distance_a < distance_b

func _on_died():
	queue_free()
	SceneManager.switch_scene("res://scenes/game_over.tscn")

func _on_health_entity_took_damage():
	sprite.self_modulate = Color(255,0,0)
	await get_tree().create_timer(0.25).timeout
	sprite.self_modulate = Color(1,1,1)

func _on_attack_range_body_entered(body):
	detect_targets(body)

func _on_attack_range_area_entered(area):
	detect_targets(area)
