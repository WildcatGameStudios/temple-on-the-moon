## Oil Activator:
## In order to use this node, give the object you wish to be activated with oil
## this node as a child, and the oil enemy will automatically seek it. Once it
## collides with the parent of this node (the parent needs a "Hitbox" child in
## order to work properly!) the oil creature enters the "Enter" state until the
## "set_released" signal is emitted. Afterwards, this node cannot be re-entered
## unless it's explicitly added using the `enable_activation` method.

extends Node2D

var captured_oil: Enemy

signal activated(enemy: Enemy)
signal released()

func _ready() -> void:
	add_to_group("oil_activated")

func _process(_delta: float) -> void:
	if captured_oil != null:
		captured_oil.position = global_position

func set_activated(enemy: Enemy) -> void:
	captured_oil = enemy
	emit_signal("activated", enemy)

func set_released() -> void:
	captured_oil = null
	emit_signal("released")
	remove_from_group("oil_activated")

func enable_activation() -> void:
	add_to_group("oil_activated")
