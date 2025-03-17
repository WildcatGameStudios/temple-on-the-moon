extends Enemy

@onready var player: CharacterBody2D = $"../player"
@onready var ray_cast_l: RayCast2D = $raycast/rayCastL
@onready var ray_cast_r: RayCast2D = $raycast/rayCastR
@onready var ray_cast_dl: RayCast2D = $raycast/rayCastDL
@onready var ray_cast_dr: RayCast2D = $raycast/rayCastDR
@onready var ray_cast_at_player: RayCast2D = $raycast/rayCastAtPlayer

@export var strafeSpeed = 100 # walk state speed
@export var rollSpeed = 500 # roll state speed
@export var minXRollDistance = 750
@export var minYRollDistance = 100 # if player is within these x and y distances, it will charge
@export var pullInTime = 1 # time (s) it spends pulling in before roll
@export var direction = 1 # set starting direction, -1 for left, 1 for right
@export var printStateChange = true # will be removed, print state change in console
var timer
var state = "walk"

func _physics_process(delta: float) -> void:
	#if health <= 0:
		#queue_free()
	
	if !is_on_floor():
		velocity.y += ENEMY_GRAVITY * 80 * delta
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
	elif direction == 1 and (ray_cast_r.is_colliding() or !ray_cast_dr.is_colliding()):
		direction = -1
	
	ray_cast_at_player.target_position = player.global_position - global_position
	ray_cast_at_player.force_raycast_update()
	
	if ray_cast_at_player.get_collider() == player and player.is_on_floor() and abs(player.global_position.x - global_position.x) < minXRollDistance and abs(player.global_position.y - global_position.y) < minYRollDistance:
		state = "pullIn"
		if printStateChange:
			print("Rock alien now in pullIn")
		if player.global_position.x < global_position.x:
			direction = -1
		else:
			direction = 1
		timer = pullInTime
		
func pullIn(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		state = "roll"
		if printStateChange:
			print("Rock alien now in roll")

func roll(delta: float) -> void:
	position.x += rollSpeed * direction * delta
	if (direction == -1 and (ray_cast_l.is_colliding() or !ray_cast_dl.is_colliding())) or (direction == 1 and (ray_cast_r.is_colliding() or !ray_cast_dr.is_colliding())):
		state = "walk"
		if printStateChange:
			print("Rock alien now in walk")
