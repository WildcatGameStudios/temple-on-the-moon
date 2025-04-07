extends CharacterBody2D

var direction: Vector2 # must be set by player
var speed: float = 512
const DEFAULT_SPEED: float = 512
const ACCELERATION: float = 2048
var exploding: bool = false
var explode_timer: float = 0.5
var active: bool = false
var miss_timer: float = 0.5

func reset() -> void:
	speed = DEFAULT_SPEED
	exploding = false
	explode_timer = 0.5
	active = false
	miss_timer = 0.5

func set_projectile_velocity(new_velocity: Vector2):
	velocity = new_velocity

func _physics_process(delta: float) -> void:
	miss_timer -= delta
	if miss_timer <= 0.0:
		exploding = true
	speed += ACCELERATION * delta
	if explode_timer < 0.0:
		explode()
		exploding = false
		active = false
	elif exploding:
		explode_timer -= delta
		# temporary demonstration of magic explosions; will be animated by artist soon
		modulate = Color.hex(0xffffff00 + 0xff * explode_timer)
	
	velocity = direction * speed
	move_and_slide()

func explode():
	pass
	#queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	var n = body.find_child("magic_activator")
	if n == null: return
	if n.is_in_group("magic_activated"):
		print("Magic activator found")
		exploding = true
		n.emit_signal("triggered")


func _on_area_2d_area_entered(area: Area2D) -> void:
	var n = area.find_child("magic_activator")
	if n == null: return
	if n.is_in_group("magic_activated"):
		print("Magic activator found")
		exploding = true
		n.emit_signal("triggered")
