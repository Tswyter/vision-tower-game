extends Area2D
class_name ChainRadius

#------ ON READY ------#
@onready var collision_shape = $CollisionShape2D

#------ EXPORTS ------#
@export var radius_size = 100.0

func _ready():
	if collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()
	update_radius(radius_size)

func update_radius(new_radius: float):
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = new_radius
		radius_size = new_radius
