extends RigidBody2D

class_name Enemy

# TODO: change player to custom class "player"
@onready var player: CharacterBody2D

func _ready() -> void:
	print("readying an enemy")
	for node in get_tree().root.get_children():
		if node.name == "player":
			player = node
			print("player found")
			break

func _process(delta: float) -> void:
	pass

func attack() -> void:
	pass

func knockback() -> void:
	pass

func die() -> void:
	pass
