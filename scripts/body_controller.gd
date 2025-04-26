# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D
class_name BodyController 

@export var camera: Camera3D 

@export_group("Movement Abilites")
## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Body Specific Actions")
@export var can_crouch: bool = false
@export var can_destroy: bool = false
@export var can_trigger_pressure_plates: bool = false
@export var can_pull_levers: bool = false
@export var can_use_shield: bool = false
@export var can_lift_objects: bool = false
@export var can_press_buttons: bool = false
@export var can_crawl_through_pipes: bool = false


var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false
var is_active_body: bool = false 

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider

func _ready() -> void:
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

func _unhandled_input(event: InputEvent) -> void:
	if is_active_body:
		# Mouse capturing
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			capture_mouse()
		if Input.is_key_pressed(KEY_ESCAPE):
			release_mouse()
		
		# Look around
		if mouse_captured and event is InputEventMouseMotion:
			rotate_look(event.relative)
		
		# Toggle freefly mode
		if can_freefly and Input.is_action_just_pressed("freefly"):
			if not freeflying:
				enable_freefly()
			else:
				disable_freefly()

func _physics_process(delta: float) -> void:
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta
	
	# Apply desired movement to velocity
	if can_move:
		# Only allow player to modify velocity if this is the active body. 
		if is_active_body:
			var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
			var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if move_dir:
				velocity.x = move_dir.x * move_speed
				velocity.z = move_dir.z * move_speed
			else:
				velocity.x = move_toward(velocity.x, 0, move_speed)
				velocity.z = move_toward(velocity.z, 0, move_speed)
		else:
				velocity.x = move_toward(velocity.x, 0, move_speed)
				velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	if is_active_body:
		# If freeflying, handle freefly and nothing else
		if can_freefly and freeflying:
			var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
			var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			motion *= freefly_speed * delta
			move_and_collide(motion)
			return
		
		# Apply jumping
		if can_jump:
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = jump_velocity

		# Modify speed based on sprinting
		if can_sprint and Input.is_action_pressed("sprint"):
				move_speed = sprint_speed
		else:
			move_speed = base_speed

		
	
	# Use velocity to actually move
	move_and_slide()


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	if is_active_body:
		look_rotation.x -= rot_input.y * look_speed
		look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
		look_rotation.y -= rot_input.x * look_speed
		transform.basis = Basis()
		rotate_y(look_rotation.y)
		head.transform.basis = Basis()
		head.rotate_x(look_rotation.x)


func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
	
# Switches between bodies 
func switch_body():
	# Makes this body active if it was previously inactive, and vice-verisa 
	is_active_body =! is_active_body
	if is_active_body:
		# Enables the camera on the active body, disables the one on the inactive body 
		camera.make_current()
