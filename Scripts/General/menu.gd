extends Node2D

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(.3,.3,.3,1))

func _on_test_level_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Testing/test_scene.tscn")


func _on_temple_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Temple/temple_level_2.tscn")
