extends Area2D

class_name Hurtbox

@export var hurt_damage: int = 1
@export var knockback: float = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# TODO: hurtboxes should have extended functionality: cooldowns of their own,
# animations of their shape/functionality, etc.
