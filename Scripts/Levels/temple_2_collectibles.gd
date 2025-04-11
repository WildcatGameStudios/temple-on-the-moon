extends Node2D

@onready var player: CharacterBody2D = $"../CanvasLayer/player"

var current_score = 0

func _on_child_exiting_tree(node: Node) -> void:
	current_score += 10
	player.set_score(current_score)
