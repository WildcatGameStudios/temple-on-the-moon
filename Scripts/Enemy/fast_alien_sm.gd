extends "res://Scripts/General/StateMachine.gd"

@onready var label: Label = $"../Label"


func _ready () : 
	
	# Initialize the states 
	add_state("Idle")
	add_state("Move")
	add_state("Charge")
	add_state("Alert")
	add_state("Stunned")
	add_state("Dead")
	
	
	await get_tree().create_timer(0.01).timeout
	set_state(states.Idle)
	
	


func _physics_process(delta: float) -> void:
	
	
	# First check if we have a transition
	var transition = get_transition(delta)
	#Update label 
	
	if transition != null :
		set_state(transition)
	# Perform state logic 
	state_logic(delta)
	
	



func state_logic(delta) : 
	match state : 
		states.Idle :
			pass
		states.Move : 
			pass
		states.Charge : 
			pass
		states.Alert : 
			pass
		states.Stunned : 
			pass
		states.Dead : 
			pass



func get_transition(delta) : 
	match state : 
		states.Idle :
			pass
		states.Move : 
			pass
		states.Charge : 
			pass
		states.Alert : 
			pass
		states.Stunned : 
			pass
		states.Dead : 
			pass
	return null



func enter_state(new_state, old_state) : 
	match state : 
		states.Idle :
			pass
		states.Move : 
			pass
		states.Charge : 
			pass
		states.Alert : 
			pass
		states.Stunned : 
			pass
		states.Dead : 
			pass



func exit_state(old_state, new_state) : 
	match state : 
		states.Idle :
			pass
		states.Move : 
			pass
		states.Charge : 
			pass
		states.Alert : 
			pass
		states.Stunned : 
			pass
		states.Dead : 
			pass
