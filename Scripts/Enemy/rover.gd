extends Enemy

## Player Scope Radius
## The radius in tiles a player must be within in order for a roaming Rover to
## begin scoping the player.
@export var player_scope_radius: float = 12

var spawn_point: Vector2
var player: CharacterBody2D
var nozzle_angle: float

# all units of distance are measured in tiles

var roam_radius: float = 12.0
var reroam_cooldown: float = 2.0
var roam_time: float = 0.0
var roam_to_left: bool
const ROAM_SPEED: float = 1.5

var strafe_timer: float = 3.0
const STRAFE_TIME: float = 3.0
const STRAFE_SPEED: float = 2.0
const STRAFE_DISTANCE: float = 8.0
var strafe_finished: bool = false
@onready var dp: RayCast2D = $raycast/detect_player

var charge_timer: float = 0.0
var charge_finished: bool = false
var CHARGE_TIMEOUT: float = 0.75

var fire_timer: float = 0.0
var FIRE_TIMEOUT: float = 0.816
var fire_finished: bool
var laser_line: Line2D = Line2D.new()
var laser_hurtbox: Hurtbox = Hurtbox.new()
var laser_hurtbox_collider: CollisionShape2D = CollisionShape2D.new()

var dead: bool = false
var die_timer: float = 0.0
const DIE_TIMEOUT: float = 0.3

func _ready() -> void:
	spawn_point = global_position
	player = $"../player"
	laser_hurtbox.add_child(laser_hurtbox_collider)
	laser_hurtbox.hurt_damage = 2
	laser_hurtbox.knockback = 150
	
func move(delta: float) -> void:
	velocity.y += ENEMY_GRAVITY * delta
	move_and_slide()

func nozzle_scope_player(delta: float) -> void:
	var player_pos = player.global_position
	var curr_pos = global_position
	var dpos = player_pos - curr_pos
	var angle = dpos.angle_to(Vector2(1.0, 0.0))
	# constrain so that we only have angles above the rover
	if angle < -PI / 2:
		angle = PI
	elif angle < 0:
		angle = 0
	
	const ANGULAR_VELOCITY = 1.0
	
	var dangle = sign(angle - nozzle_angle) * ANGULAR_VELOCITY
	nozzle_angle += dangle * delta
	$nozzle/hurtbox.rotation = -nozzle_angle

func update_raycasts(_delta: float) -> void:
	dp.target_position = player.global_position - global_position
	dp.force_raycast_update()

# TODO: make TILE_SIZE a global variable (currently a raw 128 number won't suffice)
func player_in_radius() -> bool:
	if dp.get_collider() != player:
		return false
	return player.global_position.distance_to(global_position) <= player_scope_radius * 128

func roam(delta: float) -> void:
	velocity.x = 0
	if reroam_cooldown > 0:
		reroam_cooldown -= delta
		roam_time = 6.0
		roam_to_left = not roam_to_left
		return
	if roam_time > 0:
		roam_time -= delta
		var vel_mult = -1 if roam_to_left else 1
		velocity.x = ROAM_SPEED * vel_mult * 128
	else:
		reroam_cooldown = 2.0

func strafe(delta: float) -> void:
	if strafe_timer < 0:
		strafe_finished = true
		velocity.x = 0
		return
		
	var strafe_dir = 1.0
	var dist = player.global_position.distance_to(global_position)
	var dir = sign(global_position.x - player.global_position.x)
	if dir < 0.0:
		strafe_dir *= -1.0
	if abs(dist) > STRAFE_DISTANCE * 128:
		strafe_dir *= -1.0
	
	const STRAFE_TOLERANCE = 0.2
	if dist < (STRAFE_DISTANCE - STRAFE_TOLERANCE) * 128 or dist > (STRAFE_DISTANCE + STRAFE_TOLERANCE) * 128:
		velocity.x = STRAFE_SPEED * strafe_dir * 128
	else:
		velocity.x = 0.0
	strafe_timer -= delta

func init_laser() -> void:
	laser_line.add_point($nozzle.position)
	laser_line.add_point($nozzle.position + Vector2(cos(nozzle_angle), -sin(nozzle_angle)) * 10000.0)
	add_child(laser_line)

func charge(delta: float) -> void:
	if charge_timer >= CHARGE_TIMEOUT:
		charge_finished = true
		return
	charge_timer += delta
	laser_line.modulate = Color.hex(0xff000000 + 0xff * (charge_timer));
	
	# below we'd do extra audio-visual effects as the rover charged.

func init_laser_hurtbox() -> void:
	var collider_shape: SegmentShape2D = SegmentShape2D.new()
	collider_shape.a = laser_line.points[0]
	collider_shape.b = laser_line.points[1]
	laser_hurtbox_collider.shape = collider_shape
	add_child(laser_hurtbox)

func fire(delta: float) -> void:
	laser_line.modulate = Color.hex(0xffffff00 + 0xff * (1-fire_timer));
	fire_timer += delta
	if fire_timer > FIRE_TIMEOUT:
		fire_finished = true
		laser_line.clear_points()
		remove_child(laser_line)
		remove_child(laser_hurtbox)
		
func die(delta: float) -> void:
	if delta >= DIE_TIMEOUT:
		return
	modulate = Color.hex(0xffffffff * (0.8-die_timer))
	die_timer += delta
