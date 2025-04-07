extends Node2D


func _on_level_1_pressed() -> void:
	# nothing until junkyard level one is being worked on
	pass # Replace with function body.


func _on_level_2_pressed() -> void:
	
	get_tree().change_scene_to_file("res://Scenes/Levels/Temple/temple_level_2.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/menu_screens/Menu.tscn")
