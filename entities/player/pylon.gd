extends Area2D

var is_alive = true
var is_placed = false
@onready var animated_sprite = $AnimatedSprite2D
@onready var load_in_sound = $"Load In Sound"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("pylons")
	animated_sprite.connect("animation_finished", _on_animation_finished)
	z_index = 5
	load_in_sound.set_pitch_scale(randf_range(1.0, 2.5))
	
func _process(_delta):
	if !is_placed:
		animated_sprite.play("idle-drag")
	
func warp_in_pylon():
	animated_sprite.offset.y = -37.135
	load_in_sound.play()
	animated_sprite.play("warp-in")
	
func _on_animation_finished():
	animated_sprite.offset.y = 0
	animated_sprite.play("idle")
