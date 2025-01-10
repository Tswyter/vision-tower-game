extends Node
class_name NodeGraph

var position : Vector2
var connections : Array = []

func _ready():
	position = get_parent().position

func connect_to(other_node: NodeGraph):
	if other_node not in connections:
		connections.append(other_node)
		other_node.connections.append(self) # Ensure bidirectional connection

func build_graph(tower, pylons: Array, enemies: Array) -> Node:
	var nodes = [tower] + pylons + enemies
	for i in range(nodes.size()):
		for j in range(i + 1, nodes.size()):
			var node_a = nodes[i]
			var node_b = nodes[j]

			var distance = node_a.position.distance_to(node_b.position)
			if distance <= get_radius_for_connection(node_a, node_b):
				node_a.connect_to(node_b)

	return tower

func get_radius_for_connection(node_a, node_b):
	return node_a.get_radius() + node_b.get_radius()
