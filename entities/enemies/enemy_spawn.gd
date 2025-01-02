extends Area2D

@export var enemy_scene: PackedScene
@export_range(5.0, 15.0, 0.1) var spawn_interval_min: float = 5.0
@export_range(10.0, 30.0, 0.1) var spawn_interval_max: float = 10.0

var active_timer: Timer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_start_spawning()
	pass # Replace with function body.

func _start_spawning():
	spawn_enemy()
	_schedule_next_spawn()

func _schedule_next_spawn():
	if active_timer:
		active_timer.queue_free()
	var next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)
	var timer = Timer.new()
	timer.wait_time = next_spawn_time
	timer.one_shot = true
	timer.timeout.connect(spawn_enemy)
	add_child(timer)
	timer.start()

func spawn_enemy():
	if not enemy_scene:
		print("Enemy scene is not assigned!")
		return
		
	var enemy_instance = enemy_scene.instantiate()
	add_child(enemy_instance)
	
	_schedule_next_spawn()
