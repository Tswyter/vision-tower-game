extends Control

@export var pylon_scene : PackedScene
@onready var play_node = get_parent()
@onready var rng = RandomNumberGenerator.new()
@onready var button = $Button
@onready var player = get_parent().get_node("Player")
@onready var playerAttackRange = player.get_node("AttackRange")

var is_dragging = false
var dragged_pylon = null

signal pylon_placed

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

## start_drag
# drag_position @Vector2 - the position where dragging begins
# - creates the pylon
# - moves the pylon's position out of view so it's ready when the user drags
# - checks if the user's drag position is within the bounds of the button, if so, do not move it or add the pylon to the scene (this cancels the pylon if they don't drag off)
# - otherwise, add the pylon to the scene and set it's global position to the drag position so it appears under the player's finger/mouse
func start_drag(drag_position: Vector2):
	is_dragging = true
	dragged_pylon = create_dragged_pylon()
	dragged_pylon.global_position = Vector2(-10000, -10000)
	if !button.get_global_rect().has_point(drag_position):
		add_child(dragged_pylon)
		dragged_pylon.global_position = drag_position

## update_drag
# drag_position @Vector2 - theposition where the pylon is being dragged
# - checks for the existence of the pylon and wether or not the player is still on the button
# - otherwise sets the position of the pylon while the user is dragging
func update_drag(drag_position: Vector2):
	if dragged_pylon and !button.get_global_rect().has_point(drag_position):
		dragged_pylon.global_position = drag_position

## end_drag
# drag_position @Vector2 - the position where the pylong should be placed
# - checks if the player is not over the button
# - if not, adds the pylon to the play node
# - if it is, then removes the pylon from the scene entirely
func end_drag(drag_position: Vector2):
	if dragged_pylon:
		if !button.get_global_rect().has_point(drag_position):
			place_pylon_on_map(drag_position)
		else:
			reject_placement()
		is_dragging = false

## place_pylon_on_map
# drag_position @Vector2 - the position where the pylon should be placed
# - checks that the play node exists
# - gets the drag_position in relation to the play_node
# - sets the dragged pylon's position to the local position of the play node
# - emits signal that pylon has been placed for other nodes to use later
func place_pylon_on_map(drag_position: Vector2):
	if play_node:
		var local_position = play_node.to_local(drag_position)
		dragged_pylon.position = local_position
		dragged_pylon.is_placed = true
		dragged_pylon = null
		emit_signal("pylon_placed")

## create_dragged_pylon
# no arguments
# - instantiates the pylon via the scene connected in the godot editor
# - adds the pylon to the play_node scene
# Returns: The pylon node instance that was added to the scene
func create_dragged_pylon():
	var pylon = pylon_scene.instantiate()
	play_node.add_child(pylon)
	return pylon

## reject_placement
# no arguments
# - change pylon color
# - remove pylon
# - reset dragged_pylon to null
func reject_placement():
	dragged_pylon.self_modulate = Color(1, 0, 0, 1)
	dragged_pylon.queue_free()
	dragged_pylon = null
