extends Enemy

@onready var player: CharacterBody2D 
@onready var ray_cast_l: RayCast2D = $raycast/rayCastL
@onready var ray_cast_r: RayCast2D = $raycast/rayCastR
@onready var ray_cast_dl: RayCast2D = $raycast/rayCastDL
@onready var ray_cast_dr: RayCast2D = $raycast/rayCastDR
@onready var ray_cast_at_player: RayCast2D = $raycast/rayCastAtPlayer
@onready var sprite: AnimatedSprite2D = $sprite
@onready var smoke: AnimatedSprite2D = $smoke


var tileScale = 128
@export var strafeSpeed = 3 # walk state speed in tiles per second
@export var rollSpeed = 6 # roll state speed in tiles per second
@export var minXRollDistance = 10
@export var minYRollDistance = 2 # if player is within x and y tiles, it will charge
@export var pullInTime = 1 # time (s) it spends pulling in before roll
@export var direction = 1 # set starting direction, -1 for left, 1 for right
var timer
var state = "walk"


var tile_scale : int = 128

func _ready() -> void: 
	
	# convert speeds to pixles for units
	rollSpeed *= tile_scale
	minXRollDistance *= tile_scale
	minYRollDistance *= tile_scale
	strafeSpeed *= tile_scale
	
	# get player ndoe 
	var scene_root = get_tree().current_scene
	
	var children = scene_root.get_children()
	
	for i in children : 
		if i.has_method("player") : 
			player = i


func _physics_process(delta: float) -> void:
	if health <= 0:
		queue_free()
	
	if !is_on_floor():
		velocity.y += ENEMY_GRAVITY * 1.25 * tileScale * delta
	else:
		velocity.y = 0
	
	if state == "walk":
		walk(delta)
	elif state == "pullIn":
		pullIn(delta)
	elif state == "roll":
		roll(delta)
	move_and_slide()

func walk(delta: float) -> void:
	position.x += strafeSpeed * direction * delta
	
	if direction == -1 and (ray_cast_l.is_colliding() or !ray_cast_dl.is_colliding()):
		direction = 1
		sprite.flip_h = true
	elif direction == 1 and (ray_cast_r.is_colliding() or !ray_cast_dr.is_colliding()):
		direction = -1
		sprite.flip_h = false
	
	ray_cast_at_player.target_position = player.global_position - global_position
	
	if ray_cast_at_player.get_collider() == player and player.is_on_floor() and abs(player.global_position.x - global_position.x) < minXRollDistance and abs(player.global_position.y - global_position.y) < minYRollDistance:
		state = "pullIn"
		if player.global_position.x < global_position.x:
			direction = -1
			sprite.flip_h = false
		else:
			direction = 1
			sprite.flip_h = true
		timer = pullInTime

func pullIn(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		state = "roll"

func roll(delta: float) -> void:
	position.x += rollSpeed * direction * delta
	if (direction == -1 and (ray_cast_l.is_colliding() or !ray_cast_dl.is_colliding())) or (direction == 1 and (ray_cast_r.is_colliding() or !ray_cast_dr.is_colliding())):
		state = "walk"
