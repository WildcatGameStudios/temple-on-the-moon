extends Enemy

# Scene References
@onready var detection_area: Area2D = $detection_area
@onready var animation: AnimatedSprite2D = $animation 
@onready var ground_check: RayCast2D = $ground_check # Checks the distance from the ground

var player_detected_position: Vector2 = Vector2.ZERO  # Stores player's position when detected
var gravity: float = 0  # Gravity for falling (Enemy floats normally)
var is_falling: bool = false # flag for falling

# ready function called on instance
func _ready() -> void:
	position.y = get_ground_position()
	detection_area.body_entered.connect(_on_body_entered)
	asleep("sleep")

# function that applies gravity
func apply_gravity(delta: float) -> void:
	velocity.y += gravity * delta  # Apply gravity

# function to measure/fix height of enemy
func get_ground_position() -> float:
	if ground_check.is_colliding():
		return ground_check.get_collision_point().y - 400
	return position.y

# function that detects the player entering the view of the enemy
func _on_body_entered(body):
	if body == self:
		print("Ignoring self-detection")
		return  
	if body.is_in_group("player"):
		print("Player detected! Enemy will wake up.")
		alert()

# function to apply physics to enemy
func _physics_process(delta: float) -> void:
	if is_falling:                                                 # After alert() is called the enemy is falling
		print("enemy is falling. Velocity = ", velocity.y)
		gravity = 500
		apply_gravity(delta)                                       # Gravity value above is applied
		print("gravity was applied. Velocity = ", velocity.y)  
		move_and_slide()                                           # Allow movement. Enemy begins to fall
		if ground_check.is_colliding():                            # If enemy lands
			print("Enemy landed! Now dying.")
			is_falling = false                                     # Stops falling
			velocity.y = 0  
			kill()                                                 # Kill enemy on impact

# normal state of the enemy
func asleep(anim_name: String) -> void:
	animation.play(anim_name)

# state the enemy enters when the player enters its view
func alert() -> void:
	print("Alert: Enemy waking up!")
	animation.play("rumble")                                       # This animation should be changed. (The enemy should start "rumbling" before falling.
	await animation.animation_finished
	print("Rumble finished, enemy falling!")
	is_falling = true  

# state enemy enters after alert. Final state.
func kill() -> void:
	print("Enemy dying on impact!")
	animation.play("die")
	await animation.animation_finished  # Wait for the death animation to finish
	queue_free()# Remove enemy
