extends Node

var nodes = []

func add_node(node): 
	if node not in nodes:
		nodes.append(node)
		update_connections()
		
func remove_node(node):
	if node in nodes:
		nodes.erase(node)
		for other in nodes:
			other.connections.erase(node)
		update_connections()

func update_connections():
	if nodes.size() > 2:
		for i in range(nodes.size()):
			for j in range(i + 1, nodes.size()):
				var node_a = nodes[i].get_parent()
				var node_b = nodes[j].get_parent()
				if node_a.global_position.distance_to(node_b.global_position) <= node_a.get_parent().get_node("ChainRadius").get_node("CollisionShape2D").shape.get_radius() + node_b.get_parent().get_node("ChainRadius").get_node("CollisionShape2D").shape.get_radius():
					node_a.connect_to(node_b)

func find_shortest_path_weighted(start: NodeGraph, target: NodeGraph) -> Array:
	var priority_queue = []
	var distances = { start: 0 }
	var previous_nodes = {}

	priority_queue.append([0, start])

	while priority_queue.size() > 0:
		priority_queue.sort()
		var current = priority_queue.pop_front()
		var current_node = current[1]

		if current_node == target:
			var path = []
			while current_node:
				path.insert(0, current_node)
				current_node = previous_nodes.get(current_node, null)
			return path

		for neighbor in current_node.connections:
			var distance = distances[current_node] + current_node.position.distance_to(neighbor.position)
			if neighbor not in distances or distance < distances[neighbor]:
				distances[neighbor] = distance
				previous_nodes[neighbor] = current_node
				priority_queue.append([distance, neighbor])

	return []
