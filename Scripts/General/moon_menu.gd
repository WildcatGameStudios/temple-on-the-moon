extends Node2D


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/menu_screens/Menu.tscn")


func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Moon/level_1.tscn")


func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Moon/level_2.tscn")


func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Moon/level_3.tscn")


func _on_level_4_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Moon/level_4.tscn")
