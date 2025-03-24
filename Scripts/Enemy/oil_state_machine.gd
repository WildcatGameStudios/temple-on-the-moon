extends "res://Scripts/General/StateMachine.gd"

func _ready() -> void:
	add_state("Idle")
	add_state("Emerge")
	add_state("Roam")
	add_state("Enter")
	add_state("Exit")
	add_state("Die")
	
	set_state(states.Idle)

func _physics_process(delta: float) -> void:
	var transition = get_transition(delta)
	if transition != null :
		set_state(transition)
	state_logic(delta)

func state_logic(delta) -> void:
	#parent.update_raycasts(delta)
	match state:
		states.Roam:
			parent.roam(delta)
		states.Die:
			parent.queue_free()

func get_transition(delta):
	match state:
		states.Idle:
			if parent.health <= 0:
				return states.Die
			if parent.close_to_player():
				return states.Emerge
		states.Emerge:
			if parent.health <= 0:
				return states.Die
			if parent.is_emerged():
				return states.Roam
		states.Roam:
			if parent.health <= 0:
				return states.Die
			if parent.has_entered():
				return states.Enter
		states.Enter:
			if parent.is_exiting():
				return states.Exit
		states.Exit:
			if parent.health <= 0:
				return states.Die
			return states.Roam
	return null
	
func enter_state(new_state, old_state) : 
	match new_state:
		states.Emerge:
			parent.emerge()
		states.Roam:
			parent.entered_enemy = false
			parent.exited_enemy = false
			parent.set_initial_roam()
	print("oil now entering state: ", states.find_key(new_state))
	
func exit_state(old_state, new_state) : 
	pass
	
