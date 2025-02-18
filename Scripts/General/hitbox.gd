extends Area2D

class_name Hitbox

var blacklist: Array[Hurtbox]
var collisions: Array[Hurtbox]

var cooling_down: bool = false

@export var cooldown: float = 1.0

## hit signal
## This signal is emitted when the hitbox detects hurtboxes within itself while
## not cooling down from a previous hit. See Hitbox._process for its usage.
## The origin of the collision is the vector mean of the positions of each
## colliding hurtbox.
signal hit(origin: Vector2)

## cooldown_timeout
## This signal is emitted when the hitbox can be triggered again.
signal cooldown_timeout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$cooldown.wait_time = cooldown

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not self.collisions.is_empty() and not cooling_down:
		var origin: Vector2 = Vector2.ZERO
		for c in collisions:
			origin += c.global_position
		origin /= collisions.size()
		emit_signal("hit", origin)
		cooling_down = true
		$cooldown.start()

## add_blacklist
## This function adds a Hurtbox to the current blacklisted hurtboxes. A
## blacklisted hurtbox won't cause this hitbox to emit a signal upon contact.
func add_blacklist(target: Hurtbox) -> void:
	if not self.blacklist.has(target):
		self.blacklist.append(target)

## remove_blacklist
## This function removes a Hurtbox tofrom the blacklisted hurtboxes list. A
## blacklisted hurtbox won't cause this hitbox to register it upon contact.
func remove_blacklist(target: Hurtbox):
	if self.blacklist.has(target):
		self.blacklist.erase(target)

func _on_area_entered(area: Area2D) -> void:
	if is_instance_of(area, Hurtbox):
		if not self.collisions.has(area) and not self.blacklist.has(area):
			self.collisions.append(area)

## TODO: what happens if a hurtbox despawns while inside a hitbox??
func _on_area_exited(area: Area2D) -> void:
	if is_instance_of(area, Hurtbox):
		if self.collisions.has(area):
			self.collisions.erase(area)


func _on_cooldown_timeout() -> void:
	cooling_down = false
	emit_signal("cooldown_timeout")
