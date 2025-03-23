extends AnimatableBody2D

@export var activated_translate: Vector2

var activated: bool = false
# TO_JUICE: make this tween ease out on both deactivate and activate.
var tween: float = 0.0:
	set(v): tween = clamp(v, 0.0, 1.0)
var original_position: Vector2


func _ready() -> void:
	original_position = position

func _physics_process(delta: float) -> void:
	if $magic_activator.is_activated:
		modulate = Color.DARK_RED
	else:
		modulate = Color.WHITE
	pass
	move(delta)

func move(delta: float) -> void:
	tween += delta * (1 if activated else -1)
	position = original_position + tween * activated_translate


func _on_magic_activator_triggered() -> void:
	self.activated = not self.activated
	print("activated")
