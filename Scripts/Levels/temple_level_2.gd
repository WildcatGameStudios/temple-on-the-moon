extends Node2D

@onready var fragment: Sprite2D = $fragments/fragment
@onready var player: CharacterBody2D = $CanvasLayer/player
@onready var collectibles: Node2D = $collectibles

var fragments_collected = 0

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0,0,0,1))

func collect() -> void:
	fragments_collected += 1
	player.set_fragments(fragments_collected)
	if fragments_collected == 3:
		fragment.is_collectable = true

func _on_fragment_key_collected() -> void:
	collect()

func _on_fragment_key_2_collected() -> void:
	collect()

func _on_fragment_key_3_collected() -> void:
	collect()
