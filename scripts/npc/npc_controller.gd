extends Entity

class_name NPCController

const base_move_speed     : float = 3.5
const base_run_multiplier : float = 2.67

signal idling
signal walking
signal death
signal running

var is_dead : bool = false
@onready var rigidbody_ref : RigidBody3D = $"."

@export var mesh : MeshInstance3D

@export var thoughts_label_template : PackedScene
var thoughts_label : Label
@export var label_anchor : Node3D

@export_group("NPC Identity")
@export var npc_name : String
@export var id       : int
var process_group    : int

@export_group("NPC Scheduling")
@export var scheduler : Scheduler

@export_group("NPC Characteristics")
@export var current_age        : int
@export var cycles_to_next_age : int
@export var personality        : Personality

var inventory : Array[Item]

@export_subgroup("Behaviour")
var is_next_to_desired_item : bool

@export_group("NPC Navigation")
@onready var navigation_agent : NavigationAgent3D = $NavigationAgent3D

@export_group("NPC Movement")
var is_running     : bool = false
var look_direction : Vector3 = Vector3.ZERO
var final_velocity : Vector3 = Vector3.ZERO

@export_group("NPC Rendering")
@onready var mesh_pivot_ref = $MeshPivot
@export var should_animate : bool = true
var viewport : Viewport


func mod_by_age() -> float:
	return minf(maxf((-sin(current_age / 31.85) * log(current_age / 100.0)) + 0.05, 0.5), 1.0)

func get_walk_speed() -> float:
	return base_move_speed * mod_by_age()

func get_run_speed() -> float:
	return get_walk_speed() * base_run_multiplier

func get_speed() -> float:
	return get_run_speed() if is_running else get_walk_speed()


func _ready() -> void:
	add_to_group("persist")

	get_node("AnimationHandler").caller_prefix = ""
	get_node("AnimationHandler").connect("attack_ended", _on_animation_handler_attack_ended)

	personality = get_node("Personality")
	scheduler = get_tree().get_root().get_node("Main/Scheduler")
	id = scheduler.request_id()
	process_group = scheduler.request_group()
	viewport = get_viewport()

	thoughts_label = thoughts_label_template.instantiate()
	print(	get_tree().root.get_child(1).get_child(2).get_child(0))
	get_tree().root.get_child(1).get_child(2).get_child(0).add_child.call_deferred(thoughts_label)

	should_animate = false
	should_attack_move = true
	navigation_agent.debug_enabled = true
	stats.is_npc = true


func _process(_delta: float) -> void:
	update_debug_label()

	# if self.stats.hunger < self.stats.max_hunger:

	pass

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if should_animate:
		if not Vector2(final_velocity.x, final_velocity.z).is_zero_approx():
			if is_running:
				running.emit()
			else:
				walking.emit()
		else:
			idling.emit()

	if navigation_agent.is_navigation_finished():
		pass
	elif not look_direction.is_zero_approx():
		mesh_pivot_ref.rotation.y = lerp_angle(mesh_pivot_ref.rotation.y, atan2(-look_direction.x, -look_direction.z), delta * 10.0)

	look_direction = final_velocity.normalized()

	var desired_velocity = global_position.direction_to(navigation_agent.get_next_path_position()) * get_speed()
	navigation_agent.velocity = desired_velocity

	global_position += final_velocity * delta


func move_to(target_position : Vector3):
	self.navigation_agent.target_position = target_position
	pass

func is_item_in_inventory(item : Item) -> bool:
	return inventory.has(item)

func pick_up_item(item : Item):
	if is_next_to_item(item):
		inventory.append(item)
		item.visible = false

func is_next_to_item(item : Item) -> bool:
	return self.position.distance_squared_to(item.position) < 10.0


func reset_pathfinding():
	navigation_agent.target_position = self.global_position
	final_velocity = Vector3.ZERO

func update_debug_label():
	thoughts_label.text = ""
	thoughts_label.text = "%.2f" % stats.hunger
	# for landmark in scheduled_brain.landmarks_attractions:
	# 	if landmark == null: continue
	# 	thoughts_label.text += landmark.name + " " + str(scheduled_brain.landmarks_attractions[landmark]) + "\n"

	# thoughts_label.text =  + "\n" + combat_brain.CombatState.keys().get(combat_commands.get("current_combat_state"))
	var new_label_position = viewport.get_camera_3d().unproject_position(label_anchor.global_transform.origin)
	new_label_position *= viewport.get_parent().stretch_shrink
	new_label_position = Vector2(new_label_position.x - (thoughts_label.size.x / 2.0), new_label_position.y - (thoughts_label.size.y / 2.0))
	thoughts_label.position = new_label_position


func _on_trigger_death() -> void:
	print("NPC died")
	# _current_state = State.DEAD
	is_dead = true
	death.emit()

func _on_navigation_finished() -> void:
	final_velocity = Vector3.ZERO

func _on_navigation_agent_3d_velocity_computed(safe_velocity:Vector3) -> void:
	final_velocity = safe_velocity
