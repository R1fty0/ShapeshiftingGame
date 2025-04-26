extends Node

# Reference to Small Body Character 
var small_body: CharacterBody3D
# Reference to Large Body Character 
var large_body: CharacterBody3D

# Keeps track of which body is the active one 
var active_body_dict: Dictionary = {
	# Small body is the active one by default 
	small_body: true,
	large_body: false
}

func get_active_body():
	# loop through dictionary to get active body and return that 
	pass 
