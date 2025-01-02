extends Node

var current_scene: PackedScene = null

func switch_scene(scene_path: String) -> void:
	var result = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		print("Failed to change scene: " + scene_path)
