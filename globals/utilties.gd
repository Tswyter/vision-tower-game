extends Node

func compare_distance(parent, a, b):
	if a.global_position and b.global_position:
		var distance_a = parent.global_position.distance_to(a.global_position)
		var distance_b = parent.global_position.distance_to(b.global_position)
		return distance_a < distance_b
	return a < b
