extends platform

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# function to be called on activation
func activate () -> void : 
	animation_player.play("turn_on")

# function to be called on deactivation
func deactivate () -> void : 
	animation_player.play("turn_off")

# function to be called on physics process
func action (delta) -> void : 
	pass
