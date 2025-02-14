extends "res://Scripts/General/StateMachine.gd"



func _ready() -> void: 
	# set all states 
	add_state("Idle")
	add_state("Walk")
	add_state("Jump")
	add_state("Fall")
	add_state("ChargeJump")
	add_state("FastFall")
	add_state("Dash")
	add_state("Hit")
	add_state("Die")
	
	await get_tree().create_timer(0.01).timeout
	set_state(states.Idle)
	



# Run on physics to update / carry out states 
func _physics_process(delta):
	
	
	# check input for certain events 
	if Input.is_action_pressed("Jump") : 
		parent.frames_since_jump_press += 1
	
	
	
	# First check if we have a transition
	var transition = get_transition(delta)
	if transition != null :
		set_state(transition)
	# Perform state logic 
	state_logic(delta)
	



func state_logic(delta) : 
	match state :
		states.Idle : 
			# do nothing 
			pass
		states.Walk : 
			# Walk handles the horizontal input, then move handles animation and move and slide 
			parent.walk(delta)
			parent.move(delta)
			
		states.Jump : 
			# same logic actually as walk state 
			parent.walk(delta)
			parent.move(delta)
		
		states.Fall : 
			parent.walk(delta)
			parent.fall()
			parent.move(delta)
			
		states.ChargeJump : 
			parent.charge_jump(delta)
		states.FastFall : 
			parent.walk(delta)
			parent.fall()
			parent.fast_fall(delta)
			parent.move(delta)
		states.Dash : 
			parent.move(delta)
		states.Hit :
			pass
		states.Die : 
			pass
			
		



func get_transition(delta) : 
	match state :
		states.Idle : 
			if parent.health <= 0 : 
				return states.Die
			if parent.was_hit() :
				return states.Hit
			if !parent.is_on_floor() : 
				return states.Fall
			if Input.is_action_just_pressed("Dash") and parent.can_dash : 
				return states.Dash
			if Input.is_action_just_released("Jump")  : 
				return states.Jump
			if Input.is_action_pressed("Jump") : 
				if parent.frames_since_jump_press > parent.charge_jump_frame_holds : 
					return states.ChargeJump
			if Input.get_axis("Walk_Left","Walk_Right") != 0 : 
				return states.Walk
			
			# If nothing
			return null
		states.Walk : 
			if parent.health <= 0 : 
				return states.Die
			if parent.was_hit() :
				return states.Hit
			if Input.is_action_just_pressed("Dash") and parent.can_dash: 
				return states.Dash
			if !parent.is_on_floor() : 
				return states.Fall
			if Input.is_action_just_released("Jump")  : 
				return states.Jump
			if Input.is_action_pressed("Jump") : 
				if parent.frames_since_jump_press > parent.charge_jump_frame_holds : 
					return states.ChargeJump
			if Input.get_axis("Walk_Left","Walk_Right") == 0 : 
				return states.Idle
			
			return null
			
		states.Jump : 
			if parent.health <= 0 : 
				return states.Die
			if parent.was_hit() :
				return states.Hit
			if Input.is_action_just_pressed("Dash") and parent.can_dash : 
				return states.Dash
			if Input.is_action_just_pressed("Fast_Fall") :
				return states.FastFall
			if parent.velocity.y > 0 : 
				return states.Fall
			if parent.is_on_floor() : 
				return states.Idle
			
			return null
			
		states.Fall : 
			if parent.health <= 0 : 
				return states.Die
			if parent.was_hit() :
				return states.Hit
			if Input.is_action_just_pressed("Dash") and parent.can_dash :
				return states.Dash
			if Input.is_action_just_pressed("Fast_Fall") or Input.is_action_pressed("Fast_Fall"): 
				return states.FastFall
			if parent.is_on_floor() : 
				return states.Idle
			
			return null
			
			
		states.ChargeJump : 
			if parent.health <= 0 : 
				return states.Die
			if parent.was_hit() :
				return states.Hit
			if !parent.is_on_floor() : 
				return states.Fall
			if Input.is_action_just_released("Jump") : 
				return states.Jump
			if Input.get_axis("Walk_Left", "Walk_Right") : 
				return states.Idle
			
			return null
		
		states.FastFall : 
			if parent.health <= 0 : 
				return states.Die
			if parent.was_hit() :
				return states.Hit
			if Input.is_action_just_pressed("Dash") and parent.can_dash : 
				return states.Dash
			if parent.is_on_floor() : 
				return states.Idle
			if !Input.is_action_pressed("Fast_Fall") : 
				return states.Fall
			
			return null
			
		states.Dash : 
			if !parent.in_dash : 
				if parent.health <= 0 : 
					return states.Die
				if parent.was_hit() :
					return states.Hit
				if !parent.is_on_floor() : 
					return states.Fall
				if Input.get_axis("Walk_Left", "Walk_Right") != 0 : 
					return states.Walk
				else : 
					return states.Idle
			else : 
				return null
		states.Hit :
			if parent.health <= 0 : 
				return states.Die
	
		states.Die : 
			pass
	
	# If nothing above then return null
	return null
	
func enter_state(new_state, old_state) : 
	match state :
		states.Idle : 
			# Check for resets
			if old_state == states.Fall or old_state == states.FastFall : 
				parent.reset_jump()
			if old_state == states.Dash : 
				parent.reset_dash()
			parent.play_anim("idle")
			print("Entering Idle")
		states.Walk : 
			if old_state == states.Dash : 
				parent.reset_dash()
			if old_state == states.Fall or old_state == states.FastFall : 
				parent.reset_jump()
			parent.play_anim("walk")
			print("Entering Walk")
		states.Jump : 
			parent.play_anim("jump")
			print("Entering Jump")
			parent.jump()
		states.Fall : 
			if old_state == states.Dash : 
				parent.reset_dash()
			parent.play_anim("fall")
			print("Entering Fall")
		states.ChargeJump : 
			parent.play_anim("charge_jump")
			print("Entering Charge Jump")
		states.FastFall : 
			parent.play_anim("fast_fall")
			print("Entering Fast fall")
		states.Dash : 
			parent.dash()
			if old_state == states.Fall or old_state == states.FastFall : 
				parent.reset_jump()
			parent.play_anim("dash")
			print("Entering dash")
		states.Hit :
			parent.play_anim("hit")
			print("Entering hit")
		states.Die : 
			parent.play_anim("die")
			print("Entering die")


func exit_state(old_state, new_state) : 
	match state :
		states.Idle : 
			pass
		states.Walk : 
			pass
		states.Jump : 
			pass
		states.Fall : 
			pass
		states.ChargeJump : 
			print(parent.frames_since_jump_press)
			parent.frames_since_jump_press = 0
		states.FastFall : 
			pass
		states.Dash : 
			pass
		states.Hit :
			pass
		states.Die : 
			pass
