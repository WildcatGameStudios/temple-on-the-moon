extends RigidBody2D

## Enemy class:
## this class will be the base class and base scene for all future enemies in the
## game. extend from this class in order to start implementing your custom enemy.
##
## Nodes in order:
## enemy_collider: the collider that interracts with the physics engine
## hitbox: the hitbox for this enemy (for when the player/environment hits it)
## hurtbox: the hurtbox that damages the player
## raycast: a general-purpose raycast to use for pathfinding, AI, etc
## animation: an abstract element that must be implemented by child classes
## noisemaker: a node to use for grouping your AudioStreamPlayers together

class_name Enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# we can't hurt ourselves!
	$hitbox.add_blacklist($hurtbox)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
