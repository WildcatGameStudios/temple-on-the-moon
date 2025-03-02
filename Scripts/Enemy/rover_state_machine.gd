extends "res://Scripts/General/StateMachine.gd"


func _ready() -> void:
	add_state("Idle")
	add_state("Roam")
	add_state("Strafe")
	add_state("Charge")
	add_state("Fire")
	add_state("Die")
	
	#await get_tree().create_timer(0.01).timeout
	set_state(states.Roam)

func _physics_process(delta: float) -> void:
	var transition = get_transition(delta)
	if transition != null :
		set_state(transition)
	state_logic(delta)
	pass

func state_logic(delta) -> void:
	parent.update_raycasts(delta)
	if Input.is_action_just_pressed("Kill"): 
		parent.dead = true
		return
	match state:
		states.Idle:
			pass
		states.Roam:
			parent.roam(delta)
			parent.move(delta)
		states.Strafe:
			parent.nozzle_scope_player(delta)
			parent.strafe(delta)
			parent.move(delta)
		states.Charge:
			parent.charge(delta)
			parent.move(delta)
		states.Fire:
			parent.fire(delta)
			parent.move(delta)
		states.Die:
			pass
	
func get_transition(delta):
	match state:
		states.Idle:
			pass
		states.Roam:
			if parent.dead:
				return states.Die
			if parent.player_in_radius():
				return states.Strafe
		states.Strafe:
			if parent.dead:
				return states.Die
			if parent.strafe_finished:
				return states.Charge
			if not parent.player_in_radius():
				return states.Roam
			pass
		states.Charge:
			if parent.dead:
				return states.Die
			if parent.charge_finished:
				return states.Fire
			pass
		states.Fire:
			if parent.dead:
				return states.Die
			if parent.fire_finished:
				return states.Strafe
			pass
		states.Die:
			pass
	return null
	
func enter_state(new_state, old_state) : 
	match new_state:
		states.Strafe:
			parent.strafe_timer = parent.STRAFE_TIME
			parent.strafe_finished = false
		states.Charge:
			parent.velocity.x = 0
			parent.charge_timer = 0.0
			parent.charge_finished = false
			parent.init_laser()
		states.Fire:
			parent.fire_timer = 0.0
			parent.fire_finished = false
			parent.init_laser_hurtbox()
		states.Die:
			$"../hurtbox".enabled = false
			$"../nozzle/hurtbox".enabled = false
	print("rover now entering state: ", states.find_key(new_state))
	pass
	
func exit_state(old_state, new_state) : 
	pass
	
