extends Sprite2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var score_value : int = 10
var collected : bool  = false


func collect () : 
	ScoreKeeper.temp_score = score_value
	collected = true
	animated_sprite_2d.play("collect")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player") : 
		collect()


func _on_animated_sprite_2d_animation_finished() -> void:
	if collected : 
		queue_free()
