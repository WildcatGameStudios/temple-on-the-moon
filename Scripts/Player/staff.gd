extends CharacterBody2D


# Export var 
@export var swing_damage : int = 1
@export var swing_duration : float = 0.5
@export var projectile_strength : float = 15

# Scene variables 
@onready var attack_duration: Timer = $Timers/attack_duration
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var swing_sprite: AnimatedSprite2D = $swing_sprite
@onready var color: Sprite2D = $color
@onready var lineart: Sprite2D = $lineart

var projectile_velocity : float
var tile_scale : int = 128


# Variable for keeping track of the flip 

func _ready() -> void: 
	await get_tree().create_timer(0.001)
	
	attack_duration.wait_time = swing_duration
	hurtbox.hurt_damage = swing_damage
	
	projectile_velocity = projectile_strength * tile_scale
	
	

func swing () : 
	# Enable hurt box , set timer 
	hurtbox.enabled = true
	attack_duration.start()
	
	
	# Play the animation and set visible
	swing_sprite.visible = true
	swing_sprite.play("swing")
	

func shoot () : 
	print("Shooting staff")
	var unit_vector = find_shoot_vector()
	print(unit_vector)
	
	var velocity_vector = unit_vector * projectile_velocity
	
	var projectile = GameManager.PROJECTILE.instantiate()
	
	projectile.set_projectile_velocity(velocity_vector)


# Use mouse position to find unit vector for direction of projectile 
func find_shoot_vector () -> Vector2 : 
	
	var unit_vector : Vector2
	# Get parent to get origin
	var parent_position : Vector2 = get_parent().global_position
	
	# Get mouse position
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	
	var distance_vector : Vector2 = Vector2(mouse_pos.x - parent_position.x, mouse_pos.y - parent_position.y)
	
	var magnitude : float = sqrt(pow((mouse_pos.x - parent_position.x), 2) + pow((mouse_pos.y - parent_position.y),2))
	
	unit_vector = distance_vector / magnitude
	
	
	return unit_vector


func flip (is_left : bool) : 
	if is_left : 
		hurtbox.transform.x = Vector2(-394,0)
		is_left = true
	else : 
		hurtbox.transform.x = Vector2(90,0)
		is_left = false



func _on_attack_duration_timeout() -> void:
	hurtbox.enabled = false


func _on_swing_sprite_animation_finished() -> void:
	swing_sprite.visible = false
