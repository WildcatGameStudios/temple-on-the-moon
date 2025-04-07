extends Node2D


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/menu_screens/Menu.tscn")


func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Junkyard/level_1.tscn")
