extends Node2D

# Scene refrences 
@onready var player: CharacterBody2D = $player
@onready var level_timer: Timer = $level_timer
@onready var fragment: Sprite2D = $fragments/fragment 
@onready var player_ui: Control = $player/player_ui



# Level variables 
var fragments_collected : int = 0 : 
	set (new_value) : 
		if new_value >= 3 : 
			fragment.is_collectable = true
		
		fragments_collected = new_value


var score : int = 0


func _process(delta: float) -> void: 
	if ScoreKeeper.temp_loaded : 
		score += ScoreKeeper.temp_score
		player.set_score(score)
		ScoreKeeper.temp_score = 0
		ScoreKeeper.temp_loaded = false


func _on_fragment_key_collected() -> void:
	fragments_collected += 1
	player.set_fragments(fragments_collected)


func _on_fragment_key_2_collected() -> void:
	fragments_collected += 1
	player.set_fragments(fragments_collected)


func _on_fragment_key_3_collected() -> void:
	fragments_collected += 1
	player.set_fragments(fragments_collected)
