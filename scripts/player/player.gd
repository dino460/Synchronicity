extends Entity

class_name Player

# Get references to nodes
# Removes get_node call each time the node is referenced
@onready var characterbody_ref = $"."
@onready var combo_timer_ref  = $ComboCooldownTimer
@onready var mesh_pivot_ref   = $MeshPivot
@onready var camera_pivot_ref = $CameraPivot

@onready var input_handler_ref : InputHandler = $InputHandler

@onready var skeleton_ref : Skeleton3D = $"MeshPivot/Low-Poly-Base_blend/rig/Skeleton3D"

signal idling
signal walking
signal running
signal dashing(dash_time: float)
signal death
# signal attack(animation_direction: AnimationHandler.AnimationState, weapon: Weapon, is_attacking: bool)

var is_dead : bool = false

@export_group("Movement Properties")
@export var applied_speed : float = 0.0
@export var walk_speed    : float = 3.1

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
# var is_attacking                  : bool = false
# var should_attack_move            : bool = false
# var can_combo 					  : bool = false
var last_direction_normalized     : Vector3 = Vector3.UP
# var damaged_enemies_this_attack   : Array = []

@export_group("Rendering Properties")
@export var mat_ref : Material
@export var raycast_holder : Node3D

@export var debug_label : Label
@export var label_anchor : Node3D

@export var edge_shadow : MeshInstance3D
@export var mask_viewport : SubViewport


func _ready():
	#weapon = $MeshPivot/Viking_Female/CharacterArmature/Skeleton3D/BoneAttachment3D.get_child(0)
	get_node("AnimationHandler").connect("attack_ended", _on_animation_handler_attack_ended)
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
	edge_shadow.get_surface_override_material(0).set_shader_parameter("mask_texture", mask_viewport.get_texture())


func _physics_process(delta : float) -> void:
	if is_dead:
		return

	if debug_label != null:
		debug_label.text = str(stats.health)

	if is_attacking: # Collision check for attacking
		damage_enemies(weapon)

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
				stats.tick_exhaustion = true
			else:
				walking.emit()
				stats.tick_exhaustion = false

		# Rotates direction of movement around UP axis in relation to camera and then normalizes it
		direction = rotate_direction(direction)
		# Smoothly rotate character Mesh3D to face direction of movement
		mesh_pivot_ref.rotation.y = lerp_angle(mesh_pivot_ref.rotation.y, atan2(-direction.x, -direction.z), delta * smooth_speed)

	elif not is_attacking:
		idling.emit()
		stats.tick_exhaustion = false

	target_velocity.x = direction.x * applied_speed
	target_velocity.z = direction.z * applied_speed

	if not characterbody_ref.is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	else:
		target_velocity.y = 0.0

	characterbody_ref.velocity = target_velocity
	characterbody_ref.move_and_slide()

func _on_animation_handler_dash_ended():
	is_dashing = false

func _on_input_handler_up_attack_performed():
	if is_dashing:
		return
	do_attack(AnimationHandler.AnimationState.ATTACK_UP, weapon)

func _on_input_handler_down_attack_performed() -> void:
	if is_dashing:
		return
	do_attack(AnimationHandler.AnimationState.ATTACK_DOWN, weapon)

func _on_input_handler_left_attack_performed() -> void:
	if is_dashing:
		return
	do_attack(AnimationHandler.AnimationState.ATTACK_LEFT, weapon)

func _on_input_handler_right_attack_performed() -> void:
	if is_dashing:
		return
	do_attack(AnimationHandler.AnimationState.ATTACK_RIGHT, weapon)

func _on_input_handler_dash_performed():
	if not is_dashing and not direction == Vector3.ZERO:
		is_dashing = true
		applied_speed = dash_speed
		dashing.emit(dash_time)

func _on_animation_handler_enable_combo():
	can_combo = true


func _on_trigger_death() -> void:
	# print("Player died")
	# is_dead = true
	# death.emit()
	pass # Replace with function body.
