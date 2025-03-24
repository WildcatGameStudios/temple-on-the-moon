extends Enemy

func rescale(node: Node2D, orig_trans: Transform2D, scale_h: float, scale_v: float) -> void:
	node.transform = orig_trans.scaled(Vector2(scale_h, scale_v))

func redo_scales() -> void:
	rescale(e_coll, e_trans, 1.0, squish)
	rescale(hit_coll, hit_trans, 1.0, squish)
	rescale(hurt_coll, hurt_trans, 1.0, squish)

@onready var e_coll: CollisionShape2D = $enemy_collider
@onready var hit_coll: CollisionShape2D = $hitbox/hitbox_collider
@onready var hurt_coll: CollisionShape2D = $hurtbox/hurtbox_collider

# this has to do with popping out of the ground
var e_trans: Transform2D
var hit_trans: Transform2D
var hurt_trans: Transform2D

@onready var player: CharacterBody2D = $"../player"
@onready var animation: AnimatedSprite2D = $animation

# how much one multiplies the height of the enemy_collider
var squish: float = 0.2
const NUM_EMERGE_FRAMES: float = 13
var finished_emerging: bool = true

@export var activation_distance: float = 400.0

var homing_pos: Vector2
var homing_target: Node2D
var target_detected: bool
var retarget_timer = 0.5
const REGARTET_TIME = 0.5
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var entered_enemy: bool = false
var exited_enemy: bool = false

func _ready() -> void:
	e_trans = e_coll.transform
	hit_trans = hit_coll.transform
	hurt_trans = hurt_coll.transform
	redo_scales()

func _physics_process(delta: float) -> void:
	# velocity.y += ENEMY_GRAVITY * delta
	move_and_slide()

func close_to_player() -> bool:
	return player.position.distance_to(position) < activation_distance

func emerge() -> void:
	animation.play("emerge")
	finished_emerging = false

func is_emerged() -> bool:
	return finished_emerging

## This function sets the initial roam target for the recently-emerged oil creature.
func set_initial_roam():
	homing_pos = self.position - Vector2(0.0, 1.0) * 128
	target_detected = false
	pass

func roam(delta: float) -> void:
	if not target_detected:
		retarget_timer -= delta
		if retarget_timer < 0:
			retarget_timer = REGARTET_TIME
			#homing_pos = self.position + (-1.0 * self.velocity).normalized() * 256 + Vector2(rng.randf() - 0.5, rng.randf() - 0.5) * 128
			self.velocity += Vector2(rng.randf() - 0.5, rng.randf() - 0.5) * 256
			search_oil_activator()
	self.velocity += 2560 * (homing_pos - self.position).normalized() * delta
	# drag
	self.velocity -= self.velocity * 0.02

func search_oil_activator() -> void:
	var activators = get_tree().get_nodes_in_group("oil_activated")
	if activators.size() > 0:
		for a: Node2D in activators:
			if a.global_position.distance_to(self.global_position) < 5 * 128:
				target_detected = true
				homing_pos = a.global_position
				homing_target = a
				homing_target.get_parent().find_child("hitbox").area_entered.connect(_on_target_entered)
				return

func has_entered() -> bool:
	return entered_enemy

func is_exiting() -> bool:
	return exited_enemy

func _on_target_entered(area: Area2D) -> void:
	if area == $hitbox:
		homing_target.set_activated(self)
		entered_enemy = true
		homing_target.released.connect(_on_target_released)

func _on_target_released() -> void:
	entered_enemy = false
	exited_enemy = true
	homing_target.get_parent().find_child("hitbox").set_monitoring(false)
	homing_target = null
	homing_pos.y -= 200.0
	target_detected = false

func _on_animation_finished() -> void:
	if animation.animation == "emerge":
		finished_emerging = true

func _on_frame_changed():
	if animation.animation == "emerge":
		squish = 0.2 + 0.8 * (animation.frame / NUM_EMERGE_FRAMES)
		redo_scales()

func _on_hitbox_hit(_origin, damage: float, _knockback) -> void:
	if not entered_enemy:
		health -= damage
