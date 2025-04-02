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

@export_group("Coyote time")
@export var jump_catch_frames = 5
@export var jump_watch_frames = 5

@export_group("Attack Variables")
@export var attack_cooldown : float = 2.0


# Scene Refrences
@onready var dash_timer: Timer = $timers/dash_timer
@onready var dash_reset_timer: Timer = $timers/dash_reset_timer
@onready var label: Label = $label
@onready var sprite: AnimatedSprite2D = $sprite
@onready var attack_cooldown_timer: Timer = $timers/attack_cooldown_timer
@onready var weapon: AnimatedSprite2D = $weapon
@onready var hurtbox: Hurtbox = $hurtbox
@onready var player_ui: Control = $player_ui

var current_projectile: Node

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
			player_ui.set_charge_max(true)
			temp_jump_power = charge_jump_max_strength
		else : 
			player_ui.set_charge_max(false)
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

# Coyote time variables 
var frames_since_jump = 0 

# attack variables
var attack_ready : bool = true : 
	set (new_val) : 
		player_ui.set_attack_ready(new_val)
		attack_ready = new_val

var aiming: bool = false
const AIM_LINE_LENGTH: float = 1000.0
  
# ready function to be called on instance 
func _ready() -> void:
	# set paremeters of child nodes 
	dash_reset_timer.wait_time = dash_cooldown
	dash_timer.wait_time = dash_duration
	#attack_cooldown_timer.wait_time = attack_cooldown
	
	#calculate jump variables
	gravity = (2 * (max_jump_height * tile_scale)) / (time_to_peak * time_to_peak) 
	jump_strength = -gravity * time_to_peak
	charge_jump_max_strength =  -1 * (((charge_jump_max_height * 128) / time_to_peak ) + (0.5 * gravity * time_to_peak))
	charge_jump_max_strength -= jump_strength
	jump_charge_per_second = (charge_jump_max_strength )  / charge_jump_max_time
	
	#calculate walk variables
	walk_speed = walk_speed_tiles  * tile_scale
	var time_down = sqrt( 2 * (max_jump_height * tile_scale) / ( (gravity) +   (gravity * fall_speed_boost)) )
	jump_walk_speed = (horizontal_jump_dist * tile_scale) / (time_to_peak + time_down)
	
	# calculate dash variables
	dash_per_second = (dash_distance * tile_scale) / dash_duration
	
	# enable player to take damage
	$hitbox.monitoring = true
	
	# create projectile
	current_projectile = preload("res://Scenes/Player/projectile.tscn").instantiate()
	current_projectile.position = position


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
	player_ui.set_dash_ready(false)
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
		if velocity.x < 0:
			sprite.flip_h = true
			weapon.flip_h  = true
			weapon.position.x = -256
			hurtbox.position.x = -256
		elif velocity.x > 0:
			sprite.flip_h = false
			weapon.flip_h = false
			weapon.position.x = 256
			hurtbox.position.x = 256
	
	

func jump_walk (delta) : 
	var x_direction = Input.get_action_strength("Walk_Right") - Input.get_action_strength("Walk_Left")
	velocity.x = x_direction * jump_walk_speed 
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false
	
	


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


func attack () : 
	#overhaul attack 
	if attack_ready : 
		attack_ready = false
		weapon.visible = true
		hurtbox.enabled = true
		weapon.play("swing")
		attack_cooldown_timer.start()
	else : 
		pass


func hit (damage: int) : 
	self.health -= damage
	player_ui.set_health(health)
	if self.health <= 0:
		die()
	pass

## Knockback
## Sets the player's velocity to be pointing away from the "hit_origin" vector
## set when the player enters a hit state.
func knockback (knockback) : 
	prints("player knock backed from", hit_origin)
	var new_velocity: Vector2 = Vector2(10, -10) * knockback
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
	player_ui.set_dash_ready(true)


func player () :
	pass

func _on_hitbox_hit(origin: Vector2, damage: int, knockback: float) -> void:
	print("player hit with: origin: ", origin, " damage: ", damage, " knockback: ", knockback)
	hit_origin = origin
	hit(damage)
	knockback(knockback)
	hit_stun = true
	$timers/hit_stun_timer.start()

func _on_hit_stun_timer_timeout() -> void:
	hit_stun = false

func _on_attack_cooldown_timer_timeout() -> void:
	attack_ready = true


func _on_weapon_animation_finished() -> void:
	weapon.visible = false
	hurtbox.enabled = false


# Wrappers to set UI

func set_score (new_score)  :
	player_ui.set_score(new_score)

func set_fragments (new_fragments) : 
	player_ui.set_fragments(new_fragments)

func set_time (new_time) : 
	pass

func set_level (new_level) : 
	pass

var aim_line: Line2D = Line2D.new()
var curr_aim_angle: float = 0.0:
	set(v):
		if v < -PI/2:
			v = -PI/2
		if v > PI/2:
			v = PI/2
		curr_aim_angle = v
const ANGULAR_VELOCITY: float = 2.0

func toggle_aiming() -> void:
	if aiming:
		clear_aim_line()
	else:
		init_aim_line()
	aiming = not aiming

func init_aim_line() -> void:
	aim_line.add_point(Vector2.ZERO)
	aim_line.add_point(Vector2(1000.0, 0))
	aim_line.default_color = Color.MEDIUM_PURPLE
	add_child(aim_line)


func aim(delta: float) -> void:
	# move camera?
	
	var curr_mouse_pos = get_global_mouse_position()
	var to_player = curr_mouse_pos - global_position
	
	var angle = to_player.angle()
	
	aim_line.points[1] = Vector2(cos(angle), sin(angle)) * AIM_LINE_LENGTH
	
	if Input.is_action_just_pressed("Attack") and not current_projectile.active:
		current_projectile.reset()
		current_projectile.position = position
		current_projectile.direction = Vector2(cos(angle), sin(angle))
		current_projectile.active = true
		get_parent().add_child(current_projectile)


func clear_aim_line() -> void:
	aim_line.clear_points()
	remove_child(aim_line)


func _on_sprite_animation_finished() -> void:
	if !$hitbox.monitoring:
		get_tree().change_scene_to_file("res://Scenes/Levels/Menu.tscn")
