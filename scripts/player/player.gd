extends CharacterBody3D

# Get references to nodes
# Removes get_node call each time the node is referenced
@onready var combo_timer_ref  = $ComboCooldownTimer
@onready var mesh_pivot_ref   = $MeshPivot
@onready var camera_pivot_ref = $CameraPivot

@onready var input_handler_ref : InputHandler = $InputHandler

@onready var skeleton_ref : Skeleton3D = $"MeshPivot/Low-Poly-Base_blend/rig/Skeleton3D"

signal idling
signal walking
signal running
signal dashing(dash_time: float)
signal attack(animation_direction: AnimationHandler.AnimationState, weapon: Weapon, is_attacking: bool)

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
@export var attack_movement_speed : float = 10.0
@export var weapon                : Weapon
var weapon_collider               : Area3D
var is_attacking                  : bool = false
var should_attack_move            : bool = false
var can_combo 					  : bool = false
var last_direction_normalized     : Vector3 = Vector3.UP
var damaged_enemies_this_attack   : Array = []

func _ready():
	#weapon = $MeshPivot/Viking_Female/CharacterArmature/Skeleton3D/BoneAttachment3D.get_child(0)
	weapon_collider = weapon.get_child(0)
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
	if is_attacking:
		applied_speed = attack_movement_speed
	elif is_running:
		applied_speed = run_speed
	else:
		applied_speed = walk_speed


func rotate_direction(direction_to_rotate : Vector3) -> Vector3:
	return direction_to_rotate.rotated(Vector3.UP, camera_pivot_ref.global_transform.basis.get_euler().y).normalized()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	set_is_running()


func _physics_process(delta : float) -> void:
	if is_attacking: # Collision check for attacking
		var hit_enemies = weapon.get_child(0).get_overlapping_bodies()
		if not damaged_enemies_this_attack.has(hit_enemies): # Checks if new enemies are hit
			print(hit_enemies)
			damaged_enemies_this_attack.append(hit_enemies)
			for enemy in hit_enemies: #Applies damage to enemies
				if enemy.has_method("take_damage"):
					enemy.take_damage(weapon.attack_damage)
					print(weapon.attack_damage)
	elif damaged_enemies_this_attack.size() > 0:
		damaged_enemies_this_attack.clear() # Clears the list of damaged enemies if not attacking

	set_speed()

	if not is_attacking:
		direction = input_handler_ref.get_player_direction_this_frame()
		if direction != Vector3.ZERO:
			last_direction_normalized = direction.normalized()
	elif should_attack_move:
		direction = last_direction_normalized
	else:
		direction = Vector3.ZERO

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

	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	else:
		target_velocity.y = 0.0

	velocity = target_velocity
	move_and_slide()


func stop_attack_movement():
	should_attack_move = false

func _on_animation_handler_dash_ended():
	is_dashing = false

func _on_animation_handler_attack_ended():
	is_attacking = false
	can_combo = false
	should_attack_move = false
#	combo_timer_ref.start(weapon.combo_wait_time)

func do_attack(attack_state : AnimationHandler.AnimationState):
	if not is_dashing and ((not is_attacking) or can_combo):
		attack.emit(attack_state, weapon, is_attacking)
		is_attacking = true
		should_attack_move = true
		can_combo = false
		damaged_enemies_this_attack.clear()

func _on_input_handler_up_attack_performed():
	do_attack(AnimationHandler.AnimationState.ATTACK_UP)

func _on_input_handler_down_attack_performed() -> void:
	do_attack(AnimationHandler.AnimationState.ATTACK_DOWN)

func _on_input_handler_left_attack_performed() -> void:
	do_attack(AnimationHandler.AnimationState.ATTACK_LEFT)

func _on_input_handler_right_attack_performed() -> void:
	do_attack(AnimationHandler.AnimationState.ATTACK_RIGHT)

func _on_input_handler_dash_performed():
	if not is_dashing and not direction == Vector3.ZERO:
		is_dashing = true
		applied_speed = dash_speed
		dashing.emit(dash_time)

func _on_animation_handler_enable_combo():
	can_combo = true
