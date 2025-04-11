extends Node2D

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(.3,.3,.3,1))

func _on_test_level_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Testing/test_scene.tscn")

func _on_junkyard_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/menu_screens/junkyard_menu.tscn")

func _on_moon_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/menu_screens/moon_menu.tscn")

func _on_temple_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/menu_screens/temple_menu.tscn")
