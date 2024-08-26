extends CharacterBody3D


# Get references to nodes
# Removes get_node call each time the node is referenced 
@onready var combo_timer_ref  = $ComboCooldownTimer
@onready var mesh_pivot_ref   = $MeshPivot
@onready var camera_pivot_ref = $CameraPivot

@onready var input_handler_ref : InputHandler = $InputHandler

signal idling
signal walking
signal running
signal dashing(dash_time: float)
signal attack_light(weapon: Weapon, current_combo_value: float)

@export_group("Movement Properties")
@export var applied_speed : float = 0.0
@export var walk_speed    : float = 3.3

@export var run_speed     : float = 18.0
@export var is_running    : bool  = false
@export var run_is_toggle : bool  = false

@export var dash_speed : float = 32.0
@export var dash_time  : float = 0.2
@export var is_dashing : bool  = false

@export var fall_acceleration : float = 75.0

var target_velocity : Vector3 = Vector3.ZERO
var direction       : Vector3 = Vector3.ZERO

@export_group("Rotation Properties")
@export var smooth_speed : float = 2.0

@export_group("Combat Properties")
@export var current_combo_value : int  = 0
@export var is_attacking        : bool = false
@export var can_attack_move     : bool = true

#var weapon: Weapon
#@onready var weapon : Weapon = $MeshPivot/LowPolyCharacter/rig/Skeleton3D/BoneAttachment3D/Sword

func _ready():
	#weapon = $MeshPivot/Viking_Female/CharacterArmature/Skeleton3D/BoneAttachment3D.get_child(0)
	pass


func set_is_running():
	if not is_dashing and not is_attacking:
		if run_is_toggle:
			if Input.is_action_just_pressed("player_run"):
				if applied_speed != run_speed:
					is_running = true
				else:
					is_running = false
		else:
			if (Input.is_action_pressed("player_run")):
				is_running = true
			else:
				is_running = false


func set_speed():
	if is_running:
		applied_speed = run_speed
	else:
		applied_speed = walk_speed


func reset_combo():
#	if current_combo_value >= weapon.light_attack_animations.size():
		current_combo_value = 0


func rotate_direction(direction_to_rotate : Vector3) -> Vector3:
	return direction_to_rotate.rotated(Vector3.UP, camera_pivot_ref.global_transform.basis.get_euler().y).normalized()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	reset_combo()
	set_is_running()


func _physics_process(delta : float) -> void:
	set_speed()
	
	if is_attacking && !can_attack_move:
		direction = Vector3.ZERO
	else:
		direction = input_handler_ref.get_player_direction_this_frame()
	
	if direction != Vector3.ZERO:
		if not is_dashing:
			if applied_speed >= run_speed:
				running.emit()
			else:
				walking.emit()
			
		# Rotates direction of movement around UP axis in relation to camera and then normalizes it
		direction = rotate_direction(direction)
		# Smoothly rotate character Mesh3D to face direction of movement
		mesh_pivot_ref.rotation.y = lerp_angle(mesh_pivot_ref.rotation.y, atan2(-direction.x, -direction.z), delta * smooth_speed)
	
	elif not is_attacking:
		idling.emit()
	
	target_velocity.x = direction.x * applied_speed
	target_velocity.z = direction.z * applied_speed
	
	# Something is making player bump
	# Disabling gravity makes it work
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	else:
		target_velocity.y = 0.0
	
	velocity = target_velocity
	move_and_slide()


func _on_animation_handler_dash_ended():
	is_dashing = false

func _on_animation_handler_attack_ended():
	is_attacking = false
#	combo_timer_ref.start(weapon.combo_wait_time)

func _on_input_handler_light_attack_performed():
	if not is_dashing:
		combo_timer_ref.stop()
#		attack_light.emit(weapon, current_combo_value)
		current_combo_value += 1
		is_attacking = true
		can_attack_move = true
		

func _on_input_handler_dash_performed():
	if not is_dashing and not direction == Vector3.ZERO:
		is_dashing = true
		applied_speed = dash_speed
		dashing.emit(dash_time)

func _on_combo_cooldown_timer_timeout():
	current_combo_value = 0


func _on_animation_handler_can_combo() -> void:
	can_attack_move = false
