extends Control


var current_score : int = 0
var current_fragments : int = 0

@onready var score_label: Label = $information/score_label
@onready var fragments_label: Label = $information/fragments_label



func _ready () : 
	current_score = 0
	current_fragments = 0
	


func set_score(new_score : int) : 
	current_score = new_score
	score_label.text = "Score : %06d" % [current_score]

func set_fragments(new_fragments : int) : 
	current_fragments = new_fragments
	fragments_label.text = " : %01d / 3" % [current_fragments]
