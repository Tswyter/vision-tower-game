extends Area2D

var is_alive = true

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("pylons")
	z_index = 5
