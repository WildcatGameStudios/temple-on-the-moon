extends CharacterBody2D

# Refrences to nodes in scene 
@onready var body: AnimatedSprite2D = $body
@onready var raycast_l: RayCast2D = $raycast/raycast_left
@onready var raycast_r: RayCast2D = $raycast/raycast_right
@onready var raycast_right_down: RayCast2D = $raycast/raycast_right_down
@onready var raycast_left_down: RayCast2D = $raycast/raycast_left_down


# export variables for rock 
@export var health : int = 1 : 
	set (new_val) : 
		if health - new_val <= 0 : 
			die ()
		else : 
			health = new_val
@export var walk_speed : int = 3
@export var gravity_multiplyer : int = 5
@export var damage : int = 1
@export_enum("Left", "Right") var initial_direction = "Left"


# variables 
var gravity : float 
var tile_scale : int = 128
var direction : String
var move_speed : int
var is_dead : bool = false


func _ready() -> void:
	
	# Calculate variables based on desing input 
	move_speed = tile_scale * walk_speed
	gravity = gravity_multiplyer * 980
	direction = initial_direction
	
	



func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Kill") : 
		health -= health
	
	# Check if not dead
	
	if !is_dead : 
		check_raycast()
		move(delta)



func move (delta) -> void: 
	
	# Check direction to determine sprite facing / direction 
	if direction == "Left" : 
		velocity.x = move_speed * -1
		body.flip_h = false
	elif direction == "Right" : 
		velocity.x = move_speed 
		body.flip_h = true
	else : 
		print("error no direction!")
	
	#Check if gravity needs to be applied 
	if !is_on_floor() : 
		print("falling")
		print(transform)
		apply_gravity()
	
	# Move the charectar body 
	move_and_slide()


func check_raycast () -> void : 
	
	
	# Offset the raycast properly to the parent positions
	#raycast_l.transform.x = self.transform.x - Vector2(30,0)
	#raycast_l.transform.y = self.transform.y
	#raycast_r.transform.x = self.transform.x + Vector2(30,0)
	#raycast_r.transform.y = self.transform.y
	
	# then update raycast 
	raycast_l.force_raycast_update()
	raycast_r.force_raycast_update()
	raycast_left_down.force_raycast_update()
	raycast_right_down.force_raycast_update()
	
	
	# then check if either is colliding, and adjust direction accordingly 
	if raycast_l.is_colliding() : 
		#print("Setting direction right")
		direction = "Right"
	elif raycast_r.is_colliding() : 
		#print("Setting direction left")
		direction = "Left"
	
	# Extra check to see if there is ground to walk on next 
	if direction == "Left" and !raycast_left_down.is_colliding() and is_on_floor(): 
		direction = "Right"
	elif direction == "Right" and !raycast_right_down.is_colliding() and is_on_floor(): 
		direction = "Left"


func apply_gravity () -> void: 
	velocity.y += gravity


# function to die 
func die () -> void: 
	is_dead = true
	body.play("die")
	



# On hit 
func _on_hitbox_hit(origin: Vector2, damage: int, knockback: float) -> void:
	health -= damage




func _on_body_animation_finished() -> void:
	if is_dead : 
		queue_free()
