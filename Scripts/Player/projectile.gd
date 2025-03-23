extends CharacterBody2D

var direction: Vector2 # must be set by player
var speed: float = 512 # TODO: will do fancy acceleration stuff
const DEFAULT_SPEED: float = 512
var exploding: bool = false
var explode_timer: float = 1.0

func reset() -> void:
	speed = DEFAULT_SPEED
	exploding = false
	explode_timer = 1.0
	modulate = Color.WHITE

func set_projectile_velocity(new_velocity: Vector2):
	velocity = new_velocity

func _physics_process(delta: float) -> void:
	if explode_timer < 0.0:
		explode()
		return
	elif exploding:
		explode_timer -= delta
		# temporary demonstration of magic explosions; will be animated by artist soon
		modulate = Color.hex(0xffffff00 + 0xff * explode_timer)
		return
	
	velocity = direction * speed
	move_and_slide()

func explode():
	pass
	#queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	var n = body.find_child("magic_activator")
	if n == null: return
	if n.is_in_group("magic_activated"):
		exploding = true
		n.emit_signal("triggered")
