extends Node2D
@onready var player: CharacterBody2D = $player

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0,0,0,1))
