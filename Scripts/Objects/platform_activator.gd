extends Sprite2D
class_name platform_activator


# array to hold all platforms to be controlled by activator 
## All platforms that this activator controlls
@export var platforms : Array[platform]
## Defines what behaviour platforms are activated with.
## Switch toggles all platforms off and on.    
## Toggle switches between two defined subsets of platforms. 
## Cascading activates platforms in a order. 
@export_enum("Switch", "Toggle", "Cascading") var type = "Switch"
## Cooldown time for activator to be interacted with. If timed is toggled on for a mode, cooldown will
## be at a minimum of time. For example, cooldown will never be smaller then switch_time if switch_timed is true.
@export var cooldown : float = 1.0

@export_group("Switch Variables")
## If on then blocks begin already activated
@export var switch_on : bool = false  : 
	set (new) : 
		switch_on = new 
		# set all platforms to match toggle 
		for i in platforms : 
			i.is_activated = switch_on
## If true, at end of switch_time platform goes off 
@export var switch_timed : bool = false
@export var switch_time : float = 3.0

@export_group("Toggle Variables")
## Group one platforms
@export var group_1 : Array[platform]
## Group two platforms
@export var group_2 : Array[platform]
## Which group is activated initially. Bound to 1 and 2
@export_range(1,2) var active_group = 1
## If true, at end of toggle_time platform switches back to base state 
@export var toggle_timed : bool = false
@export var toggle_time : float = 3.0


@export_group("Cascading Variables")
## If on then platforms begin cascading
@export var cascading_on : bool = false
## Time in between finishing of animation "on" and start of next platform 
@export var wait_time : float = 1.0
## Order in which platforms are activated. Front reads first to back of platforms array, back reads 
## back to front. 
@export_enum ("Front", "Back") var mode = "Front"

# Scene refrences
@onready var switch_timer: Timer = $timers/switch_timer
@onready var toggle_timer: Timer = $timers/toggle_timer
@onready var cascade_timer: Timer = $timers/cascade_timer
@onready var cooldown_timer: Timer = $timers/cooldown_timer

var is_ready : bool = true

func _ready() -> void: 
	# manually toggle all platforms to begin 
	match type : 
		"Switch" : 
			# simple, just switch all groups 
			for i in platforms : 
				i.is_activated = !switch_on
				i.is_activated = switch_on
			if switch_timed : 
				if cooldown < switch_time : 
					cooldown = switch_time
		"Toggle" : 
			if active_group == 2 : 
				for i in group_1 : 
					i.is_activated = true
					i.is_activated = false
				for i in group_2 : 
					i.is_activated = false
					i.is_activated = true
			elif active_group == 1 : 
				for i in group_1 : 
					i.is_activated = false
					i.is_activated = true
				for i in group_2 : 
					i.is_activated = true
					i.is_activated = false
			if toggle_timed : 
				if cooldown < toggle_time : 
					cooldown = toggle_time
		"Cascading" : 
			pass
	
	# set timers
	switch_timer.wait_time = switch_time
	toggle_timer.wait_time = toggle_time
	cooldown_timer.wait_time = cooldown

# physics 
func _physics_process(delta: float) -> void:
	pass


func _on_magic_activator_triggered() -> void:
	# Based on type of activator, perform logic  
	if is_ready : 
		match type : 
			"Switch" : 
				# simple, just switch all groups 
				switch_on = !switch_on
				if switch_timed : 
					switch_timer.start()
				is_ready = false
				cooldown_timer.start()
			"Toggle" : 
				if active_group == 1 : 
					for i in group_1 : 
						i.is_activated = false
					for i in group_2 : 
						i.is_activated = true
					active_group = 2
				elif active_group == 2 : 
					for i in group_1 : 
						i.is_activated = true
					for i in group_2 : 
						i.is_activated = false
					active_group = 1
				if toggle_timed : 
					toggle_timer.start()
				is_ready = false
				cooldown_timer.start()
				
			"Cascading" : 
				pass


func _on_switch_timer_timeout() -> void:
	# if this is activated, then flip switch variable 
	switch_on = !switch_on


func _on_toggle_timer_timeout() -> void:
	
	if active_group == 1 : 
		for i in group_1 : 
				i.is_activated = false
		for i in group_2 : 
			i.is_activated = true
			active_group = 2
	elif active_group == 2 : 
		for i in group_1 : 
			i.is_activated = true
		for i in group_2 : 
			i.is_activated = false
		active_group = 1


func _on_cooldown_timer_timeout() -> void:
	is_ready = true
