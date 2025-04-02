extends "res://Scripts/General/StateMachine.gd"

func _ready() -> void: 
	# set all states 
	add_state("Walk")
	add_state("Curl")
	add_state("Roll")
	add_state("Uncurl")
	add_state("Die")
	
	set_state(states.Walk)

func _physics_process(delta: float) -> void:
	var transition = get_transition(delta)
	if transition != null:
		set_state(transition)
	state_logic(delta)
	
func state_logic(delta: float) -> void:
	match state:
		states.Walk:
			parent.walk(delta)
		states.Curl:
			parent.curl(delta)
		states.Roll:
			parent.roll(delta)
		states.Uncurl:
			parent.uncurl(delta)
		states.Die:
			parent.dying(delta)

func get_transition(delta):
	if parent.health <= 0 and state != states.Die:
		return states.Die
	match state:
		states.Walk:
			if parent.walk_to_curl():
				return states.Curl
		states.Curl:
			if parent.curl_to_roll():
				return states.Roll
		states.Roll:
			if parent.roll_to_uncurl():
				return states.Uncurl
		states.Uncurl:
			if parent.uncurl_to_walk():
				return states.Walk
	return null
	
func enter_state(new_state, old_state) : 
	match new_state:
		states.Walk:
			parent.init_walk()
		states.Curl:
			parent.init_curl()
		states.Roll:
			parent.init_roll()
		states.Uncurl:
			parent.init_uncurl()
		states.Die:
			parent.init_die()

func exit_state(old_state, new_state) : 
	pass
	
