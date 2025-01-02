extends Control

@export var pylon_scene : PackedScene
@onready var play_node = get_parent()
@onready var rng = RandomNumberGenerator.new()
@onready var button = $Button
@onready var player = get_parent().get_node("Player")
@onready var playerAttackRange = player.get_node("AttackRange")

var is_dragging = false
var dragged_pylon = null

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if not is_dragging:
				if button.get_global_rect().has_point(event.position):
					start_drag(event.position)
		else:
			if is_dragging:
				end_drag(event.position)
	elif event is InputEventScreenDrag:
		if is_dragging and dragged_pylon:
			update_drag(event.position)

func start_drag(drag_position: Vector2):
	is_dragging = true
	dragged_pylon = create_dragged_pylon()
	dragged_pylon.global_position = Vector2(-10000, -10000)
	if !button.get_global_rect().has_point(drag_position):
		add_child(dragged_pylon)
		dragged_pylon.global_position = drag_position
	
func update_drag(drag_position: Vector2):
	if dragged_pylon and !button.get_global_rect().has_point(drag_position):
		dragged_pylon.global_position = drag_position
		
func end_drag(drag_position: Vector2):
	if dragged_pylon:
		if !button.get_global_rect().has_point(drag_position):
			place_pylon_on_map(drag_position)
		else:
			dragged_pylon.queue_free()
		is_dragging = false

func place_pylon_on_map(drag_position: Vector2):
	if play_node:
		var local_position = play_node.to_local(drag_position)
		dragged_pylon.position = local_position
		dragged_pylon = null

func create_dragged_pylon():
	var pylon = pylon_scene.instantiate()
	play_node.add_child(pylon)
	return pylon

func is_valid_placement(position: Vector2) -> bool:
	return playerAttackRange

func reject_placement():
	dragged_pylon.queue_free()
	dragged_pylon = null
