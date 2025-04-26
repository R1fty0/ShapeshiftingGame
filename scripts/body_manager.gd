extends Node

@export var large_body: BodyController
@export var small_body: BodyController 


func _ready():
	# Sets the large body to be the active one by default 
	#large_body.is_active_body = true
	small_body.is_active_body = true
	pass

func _input(event: InputEvent):
	if event.is_action_pressed("switch_body"):
		# Switch between bodies 
		large_body.switch_body()
		small_body.switch_body()
