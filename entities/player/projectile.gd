extends Area2D

@onready var line_container = get_parent().get_node("LineContainer")
@onready var playerPosition = to_local(get_parent().position)

var line: Line2D

var speed = 200
var damage = 33.4
var target = null
var chain_limit = 2
var current_chain_index = 0
var chain_radius: float = 100.0
var chain_targets = []

func _ready():
	line = Line2D.new()
	line.clear_points()
	line.width = 5.0
	line.default_color = Color(.21, 1, 1, 1)
	line.show()
	line.z_index = 5
	line.add_point(playerPosition)
	line.add_point(position)
	line_container.add_child(line)
	populate_chain_targets()

func _physics_process(delta):
	if is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		position += direction * speed * delta
		look_at(target.get_parent().global_position)
	else:
		target = get_closest_target()
		if !target:
			remove_projectile()
		
	if current_chain_index > line.get_point_count() - 2:
		line.add_point(position)
	
	line.set_point_position(line.get_point_count() - 1, position)
	
	# if over 50 points are added, remove the first point
	if line.get_point_count() > 50:
		line.remove_point(0)

	if current_chain_index > chain_limit:
		remove_projectile()

func _on_body_entered(body):
	if body.is_in_group("enemies") or body.is_in_group("pylons"):
		if !is_instance_valid(body):
			return
		if body.is_in_group("enemies"):
			body.health.take_damage(damage)
			current_chain_index += 1
			
			# when projectile hits enemy, damage falls off
			damage = damage / current_chain_index
			
		# if hit a conduit, increase damage
		elif body.is_in_group("pylons"):
			damage = damage + 10
		
		# remove from chain_targets so an enemy can't be hit twice
		if body in chain_targets:
			chain_targets.erase(body)

		# pick the next closest target
		target = get_closest_target()
		
		# if there is no next closest target, remove projectile
		if target == null:
			remove_projectile()

func _on_chain_radius_body_entered(body):
	if body.is_in_group("enemies") or body.is_in_group("pylons"):
		if body not in chain_targets:
			chain_targets.append(body)
	
func _on_chain_radius_body_exited(body):
	if body in chain_targets:
		chain_targets.erase(body)
		
func populate_chain_targets():
	# When the projectile loads, we need to add any enemies in the radius into the array
	# we may need to sort the array as soon as an enemy is hit
	for body in $ChainRadius.get_overlapping_areas():
		print('pylon' if body.is_in_group("pylons") else '')
		if body.is_alive:
			return
		if body not in chain_targets:
			chain_targets.append(body)

func get_closest_target():
	chain_targets.sort_custom(compare_distance)
	#var closest_target = null
	#var closest_distance = chain_radius
	#
	#for target in chain_targets:
		#if is_instance_valid(target):
			#var distance = global_position.distance_to(target.global_position)
			#if distance < closest_distance:
				#closest_distance = distance
				#closest_target = target
			
	return chain_targets[0] if chain_targets.size() > 0 else null

func compare_distance(a, b):
	var distance_a = global_position.distance_to(a.global_position)
	var distance_b = global_position.distance_to(b.global_position)
	return distance_a < distance_b

func remove_projectile():
	queue_free()
	line.queue_free()
