extends Control


var current_score : int = 0
var current_fragments : int = 0
var red : Color = Color(1.0, 0.1529, 0.4078)
var green : Color = Color(0, 0.6666, 0.4039)


@onready var score_label: Label = $VBoxContainer/HBoxContainer/score_label
@onready var fragments_label: Label = $VBoxContainer/HBoxContainer/fragments_label
@onready var health_text_label: Label = $VBoxContainer/HBoxContainer/health_text_label
@onready var charge_jump_label: Label = $VBoxContainer/HBoxContainer/charge_jump_label
@onready var dash_label: Label = $VBoxContainer/HBoxContainer/dash_label
@onready var attack_label: Label = $VBoxContainer/HBoxContainer/attack_label


func _ready () : 
	current_score = 0
	current_fragments = 0
	

func set_dash_ready (ready : bool) : 
	if ready : 
		dash_label.modulate = green
	else : 
		dash_label.modulate = red


func set_charge_max (ready : bool) : 
	if ready : 
		charge_jump_label.modulate = green
	else : 
		charge_jump_label.modulate = red

func set_attack_ready (ready : bool) : 
	if ready : 
		attack_label.modulate = green
	else : 
		attack_label.modulate  = red


func set_health (new_health : int) : 
	health_text_label.text = "Health : %d/4" % [new_health]


func set_score(new_score : int) : 
	current_score = new_score
	score_label.text = "Score : %06d" % [current_score]


func set_fragments(new_fragments : int) : 
	current_fragments = new_fragments
	fragments_label.text = " : %01d / 3" % [current_fragments]
