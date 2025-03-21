extends Sprite2D

signal collected

var is_collected : bool = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func collect () : 
	emit_signal("collected")
	animated_sprite_2d.play("collect")
	is_collected = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player") : 
		collect() 


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_collected : 
		queue_free()
