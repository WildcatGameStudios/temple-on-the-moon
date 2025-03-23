extends Node2D

var is_activated: bool

signal triggered()

func _ready() -> void:
	add_to_group("magic_activated")

func _process(_delta: float) -> void:
	pass
