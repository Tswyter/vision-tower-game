extends Area2D

#-------- ON READY --------#
@onready var player_attack_range = get_parent().get_node("Player").get_node("AttackRange")
@onready var animated_sprite = $AnimatedPylon
@onready var load_in_sound = $"Load In Sound"

#-------- VARIABLES --------#
var is_alive = true
var is_placed = false
var can_be_hit = false

#region built-in functions
func _ready():
	animated_sprite.connect("animation_finished", _on_animation_finished)
	add_to_group("pylons")
	load_in_sound.set_pitch_scale(randf_range(1.0, 2.5))
	
func _process(_delta):
	if !is_placed:
		animated_sprite.offset.y = 0
		animated_sprite.play("idle-drag")
#endregion

func warp_in_pylon():
	animated_sprite.offset.y = -37.135
	load_in_sound.play()
	animated_sprite.play("warp-in")

#region signals
func _on_animation_finished():
	animated_sprite.offset.y = 0
	animated_sprite.play("idle")
	can_be_hit = true
	GraphManager.add_node(self)
#endregion
