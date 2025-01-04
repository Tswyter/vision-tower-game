extends Area2D

@onready var line_container = get_parent().get_node("LineContainer")
@onready var playerPosition = to_local(get_parent().position)

var line: Line2D

var speed = 200
var damage = 33.4
var target = null
var chain_limit = 2
var current_chain_index = 0
@onready var chain_radius = $ChainRadius
var original_chain_radius
var chain_targets = []
var previously_hit = []

var rng = RandomNumberGenerator.new()

func _ready():
	original_chain_radius = chain_radius.transform
	z_index = 5
	line = Line2D.new()
	line.clear_points()
	line.width = 5.0
	line.default_color = Color(0.9, 1, 1, 1)
	line.show()
	line.z_index = 5
	line.add_point(playerPosition)
	line_container.add_child(line)
	populate_chain_targets()

func _physics_process(delta):
	if !is_instance_valid(target):
		target = get_closest_target()
		if !target or current_chain_index > chain_limit or previously_hit.size() > 5:
			remove_projectile()
			return
	else:
		move_toward_target(delta)
		
	update_line()

func move_toward_target(delta):
	var direction = (target.global_position - global_position).normalized()
	position += direction * speed * delta
	
func update_line():
	if current_chain_index > line.get_point_count() - 2:
		line.add_point(position)
	line.set_point_position(line.get_point_count() - 1, position)
	if line.get_point_count() - 2 > chain_limit:
		line.remove_point(0)

func handle_hit(entity):
	if !is_instance_valid(entity):
		return
	line.add_point(entity.position)
	if entity.is_in_group("enemies"):
		hit_enemy(entity)
	if entity.is_in_group("pylons"):
		hit_pylon(entity)

	# pick the next closest target
	target = get_closest_target()

	# if there is no next closest target, remove projectile
	if target == null:
		remove_projectile()

func hit_pylon(pylon):
	damage = damage * 1.1 if current_chain_index > 0 else damage * 2
	chain_radius.transform = chain_radius.transform * 1.01
	if line.default_color.r > 0.1:
		line.default_color.r = line.default_color.r - 0.1
	elif line.default_color.g > 0.1:
		line.default_color.g = line.default_color.g - 0.1
	else:
		damage = damage / 2
		line.default_color.a = line.default_color.a - 0.1
	
	print(damage)
	if line.default_color.a <= 0:
		remove_projectile()
		
	if pylon in chain_targets:
		chain_targets.erase(pylon)
		previously_hit.append(pylon)
	
func hit_enemy(enemy):
	enemy.health.take_damage(damage)
	current_chain_index += 1
	damage = damage / current_chain_index
	chain_radius.transform = original_chain_radius
	if enemy in chain_targets:
		chain_targets.erase(enemy)

func _on_projectile_hit_area(area):
	handle_hit(area)

func _on_projectile_hit_body(body):
	handle_hit(body)

func _on_chain_radius_body_entered(body):
	populate_chain_targets()
	
func _on_chain_radius_area_entered(area):
	populate_chain_targets()
	
func _on_chain_radius_body_exited(body):
	if body in chain_targets:
		chain_targets.erase(body)
		
func populate_chain_targets():
	# When the projectile loads, we need to add any enemies in the radius into the array
	# we may need to sort the array as soon as an enemy is hit
	for body in $ChainRadius.get_overlapping_areas() + $ChainRadius.get_overlapping_bodies():
		if body.is_in_group("enemies") or body.is_in_group("pylons"):
			if body not in chain_targets + previously_hit:
				insert_sorted_chain_target(body)

func insert_sorted_chain_target(target):
	var index = 0
	var target_distance = global_position.distance_to(target.global_position)
	while index < chain_targets.size() and global_position.distance_to(chain_targets[index].global_position):
		index += 1
	chain_targets.insert(index, target)

func get_closest_target():
	return chain_targets[0] if chain_targets.size() > 0 else null

func compare_distance(a, b):
	var distance_a = global_position.distance_to(a.global_position)
	var distance_b = global_position.distance_to(b.global_position)
	
	if distance_a != distance_b:
		return distance_a < distance_b
	
	var is_a_enemy = a.is_in_group("enemies")
	var is_b_enemy = b.is_in_group("enemies")
	
	return is_a_enemy and not is_b_enemy

func remove_projectile():
	queue_free()
	line.queue_free()
