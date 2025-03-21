extends Sprite2D

signal collected

var is_collectable : bool = false

func collect() : 
	emit_signal("collected")
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player") and is_collectable : 
		collect()
