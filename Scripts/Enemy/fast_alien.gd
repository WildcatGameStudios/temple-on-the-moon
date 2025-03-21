extends CharacterBody2D

# Scene variables 
@onready var sprite: Sprite2D = $sprite
@onready var stun_timer: Timer = $timers/stun_timer
@onready var alert_timer: Timer = $timers/alert_timer
@onready var idle_timer: Timer = $timers/idle_timer


# Exports 
@export_group("Movement")
@export var walk_speed : int = 3
@export var charge_speed : int = 10
@export var gravity_multiplyer : int = 5 

@export_group("Timers")
@export var stun_time : float
@export var alert_time : float
@export var idle_time : float



# Variables pre defined / only accessed in code
var is_dead : bool = false
var is_alert : bool = false
var is_stunned : bool = false
var gravity : float

var tile_scale = 128

func _ready () : 
	# calculate variables
	gravity = gravity_multiplyer * 980
	
	
	# Assign variables
	idle_timer.wait_time = idle_time
	alert_timer.wait_time = alert_time
	stun_timer.wait_time = stun_time
	
	



func _physics_process(delta: float) -> void: 
	
	# if not dead then move 
	if !is_dead : 
		move(delta)
	


func idle () : 
	# Make sure we move
	velocity.x = 0
	
	# To be uncommented later, play idle anim

func stun () : 
	pass

func alert () : 
	pass


func walk () : 
	pass

func apply_gravity () : 
	pass

func charge () : 
	pass



func move(delta) : 
	
	
	if !is_on_floor() : 
		apply_gravity()
	
	
	move_and_slide()


func die () : 
	pass



func _on_scan_right_body_entered(body: Node2D) -> void:
	if body.has_method("Player") : 
		is_alert = true
