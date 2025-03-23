extends AnimatedSprite2D

@onready var player: CharacterBody2D = $"../player"
@onready var text: ColorRect = $text_background
@onready var hint: Sprite2D = $popup_hint

@export_range(1, 10) var activation_radius: float = 1.0

var hint_tween: float = 0.0:
	set(v):
		hint_tween = clamp(v, 0.0, 1.0)
var hint_start_y: float
const HINT_BOB: float = 25.0
const HINT_BOB_RATE: float = 2.0

var display_text: bool = false
var text_tween: float = 0.0:
	set(v):
		text_tween = clamp(v, 0.0, 1.0)
var text_start_y: float
const TEXT_GLIDE: float = 25.0

func _ready() -> void:
	hint_start_y = hint.position.y
	text_start_y = text.position.y
	text.visible = true

func _process(delta: float) -> void:
	if player.position.distance_to(self.position) < activation_radius * 128:
		hint_tween = hint_tween + delta
		if Input.is_action_pressed("ui_accept"):
			display_text = true
	else:
		hint_tween = hint_tween - delta
		display_text = false
	
	if display_text:
		text_tween = text_tween + delta
	else:
		text_tween = text_tween - delta
	
	hint.modulate.a = (hint_tween - text_tween)
	hint.position.y = hint_start_y + HINT_BOB * sin(HINT_BOB_RATE * Time.get_unix_time_from_system()) # a bit dubious for a simple node
	
	text.modulate.a = text_tween
	text.position.y = text_start_y - TEXT_GLIDE * (1.0-text_tween)
