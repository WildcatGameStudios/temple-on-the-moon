extends Node2D

class_name platform

signal activated 
signal deactivated

# if platform is activated 
var is_activated : bool = false : 
	set(new) : 
		
		if new and !is_activated: 
			activate()
		elif !new and is_activated: 
			deactivate()
		
		is_activated = new

# function to be called on activation
func activate () -> void : 
	pass

# function to be called on deactivation
func deactivate () -> void : 
	pass

# function to be called on physics process
func action (delta) -> void : 
	pass
