extends Camera3D

@export var camera_switching_time: float = 0.5  

var mouse_captured : bool = false
var is_switching_bodies: bool = false 
var transition_time: float = 0.0 

func _ready():
	# Gets head position of active body (note: assumes head 
	# reference in script attached to body reference) 
	var global_position = GameManager.get_active_body().get_script().head.global_position 


func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
		
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		# send event.relative to active body look around function 
		pass 

func _physics_process(delta):
	# Smoothly move camera from one body to another 
	if is_switching_bodies: 
		transition_time += delta/camera_switching_time
	# global_position = lerp(start_body_position, end_body_position, transition_time)
	pass
	
func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
