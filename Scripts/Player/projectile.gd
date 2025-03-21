extends CharacterBody2D


func set_projectile_velocity (new_velocity : Vector2) : 
	velocity = new_velocity

func _physics_process(delta: float) -> void:
	# move 
	move_and_slide()


func explode () : 
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	explode()
