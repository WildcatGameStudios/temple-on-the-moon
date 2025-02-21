extends CharacterBody2D

# Variables that can change movement 
@export_group ("Walk Variables")
@export var walk_speed_tiles : float = 5
@export var horizontal_jump_dist : int = 10

# Define the jump variables the devs can work with in editor
@export_group("Jump Variables")
@export var max_jump_height : float = 3 : 
	# add set protects to bar values to be valid
	set(new_value) : 
		if new_value <= 0 : 
			max_jump_height = 1
		else : 
			max_jump_height = new_value
@export var time_to_peak : float = 2 : 
	set(new_value) : 
		if new_value <= 0 : 
			time_to_peak = 1
		else : 
			time_to_peak = new_value
@export var charge_jump_max_time : float = 3.0
@export var charge_jump_max_height : int = 6
@export var charge_jump_frame_holds : int = 10

# Define fall variables devs can work with in editor
@export_group("Fall Variables")
@export var fall_speed_boost : float = 3.0
@export var fast_fall_speed_boost : float = 5.0

#Define dash variables devs can work with in editor 
@export_group("Dash Variables")
@export var dash_cooldown : float = 3.0
@export var dash_duration : float = 1.0
@export var dash_distance : float = 100

# Scene Refrences
@onready var dash_timer: Timer = $timers/dash_timer
@onready var dash_reset_timer: Timer = $timers/dash_reset_timer
@onready var label: Label = $label
@onready var sprite: AnimatedSprite2D = $sprite


#general variables 
var tile_scale : int = 128 # pixle width/height of our tiles 
var gravity : float  : 
	set(new_value) : 
		gravity = new_value


# Walk variables
var walk_speed : float 
var jump_walk_speed : float 

# Jump variables 
var jump_charge_per_second : float
var jump_strength : float 
var charge_jump_max_strength : float 
var temp_jump_power = 0  : 
	set (new_value) : 
		if new_value < charge_jump_max_strength : 
			print("Catching jump")
			temp_jump_power = charge_jump_max_strength
		else : 
			temp_jump_power = new_value
var temp_gravity_power = 0
var frames_since_jump_press : int = 0
var is_charge_hold : bool = false

# Dash variables
var current_dash_time : float = 0.0
var temp_dash : float
var dash_per_second : float 
var can_dash : bool = true
var in_dash : bool = true

# Hit variables
var hit_stun: bool = false
var hit_origin: Vector2 = Vector2.ZERO

var health : int = 4
  
# ready function to be called on instance 
func _ready() -> void:
	# set paremeters of child nodes 
	dash_reset_timer.wait_time = dash_cooldown
	dash_timer.wait_time = dash_duration
	
	#calculate walk variables
	walk_speed = walk_speed_tiles  * tile_scale
	var time_down = sqrt( (max_jump_height * tile_scale) / ( (0.5 * gravity) +   fall_speed_boost) )
	jump_walk_speed = (horizontal_jump_dist * tile_scale) / (time_to_peak + time_down)
	print(jump_walk_speed)
	
	#calculate jump variables 
	gravity = (2 * (max_jump_height * tile_scale)) / (time_to_peak * time_to_peak) 
	jump_strength = -gravity * time_to_peak
	charge_jump_max_strength =  -1 * (((charge_jump_max_height * 128) / time_to_peak ) + (0.5 * gravity * time_to_peak))
	charge_jump_max_strength -= jump_strength
	jump_charge_per_second = (charge_jump_max_strength )  / charge_jump_max_time
	
	
	# calculate dash variables
	dash_per_second = (dash_distance * tile_scale) / dash_duration
	
	# enable player to take damage
	$hitbox.monitoring = true

func play_anim (animation : String) -> void :
	sprite.play(animation)
	

# Apply gravity to charectar velocity 
func apply_gravity (delta) -> void : 
	velocity.y += (gravity + temp_gravity_power ) * delta


# Reset the jump bonus and gravity back to normal upon land on ground 
func reset_jump () : 
	temp_jump_power = 0
	temp_gravity_power = 0


# reset the dash varibles that need to be reset 
func reset_dash () : 
	current_dash_time = 0
	velocity.x -= temp_dash
	can_dash = false
	dash_reset_timer.start()


# Apply the logic for when the player moves 
func move (delta) : 
	# seems redundant but more will come in here later 
	label.text = "move"
	if !is_on_floor() : 
		apply_gravity(delta)
	
	move_and_slide()


# Function to move the player if they're walking horizontaly
func walk (delta) :
	if not hit_stun:
		var x_direction = Input.get_action_strength("Walk_Right") - Input.get_action_strength("Walk_Left")
		velocity.x = x_direction * walk_speed
	

func jump_walk (delta) : 
	var x_direction = Input.get_action_strength("Walk_Right") - Input.get_action_strength("Walk_Left")
	velocity.x = x_direction * jump_walk_speed 
	print(x_direction)
	print(jump_walk_speed)


# Apply logic for when player jumps 
func jump () -> void :
	# Jump force should be applied one time 
	frames_since_jump_press = 0
	velocity.y = jump_strength + temp_jump_power
	
	#set jump walk speed 


func charge_jump (delta) : 
	
	# add the charge per second multiplied by delta only if jump hasnet hit max 
	temp_jump_power += delta * jump_charge_per_second
	# increase frames since jump press
	frames_since_jump_press += 1
	


# Apply logic for when the player falls 
func fall () -> void : 
	#adjust gravity to be faster 
	temp_gravity_power = (gravity * fall_speed_boost)
	


func fast_fall (delta) : 
	velocity.y += (fast_fall_speed_boost * tile_scale) * delta


# Handle the dash movement
func dash () : 
	
	# we want to make sure the player is only dash as mcuch as desgined, so if delta is more then allowed
	# we check it and only add the remaining time needed for dash to be complete 
	# if all good then we add just speed * delta like normal 
	# get player direction if they are holding down a button 
	var x_direction = Input.get_action_strength("Walk_Right") - Input.get_action_strength("Walk_Left") 
	
	if x_direction == 0 : 
		x_direction = 1
	
	# adjust velocitys
	velocity.x += dash_per_second * x_direction
	
	temp_dash = dash_per_second * x_direction
	
	in_dash = true
	dash_timer.start()



func hit (damage: int) : 
	self.health -= damage
	if self.health <= 0:
		die()
	pass

## Knockback
## Sets the player's velocity to be pointing away from the "hit_origin" vector
## set when the player enters a hit state.
func knockback () : 
	prints("player knock backed from", hit_origin)
	var new_velocity: Vector2 = Vector2(1000, -1000)
	if position.x < hit_origin.x:
		new_velocity.x *= -1
	self.velocity = new_velocity


func die () : 
	print("player died")
	# prevent player from continuing to take damage after death
	$hitbox.monitoring = false
	

func return_health() -> int : 
	return health

func was_hit () -> bool : 
	return hit_stun


func _on_dash_timer_timeout() -> void:
	in_dash = false


func _on_dash_reset_timer_timeout() -> void:
	can_dash = true


func player () :
	pass

func _on_hitbox_hit(origin: Vector2, damage: int, knockback: float) -> void:
	print("player hit with: origin: ", origin, " damage: ", damage, " knockback: ", knockback)
	hit(damage)
	knockback()
	hit_stun = true
	$timers/hit_stun_timer.start()

func _on_hit_stun_timer_timeout() -> void:
	hit_stun = false
