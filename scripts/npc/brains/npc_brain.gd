extends Node

class_name NPCBrain

enum State { DEAD, IN_TASK, FIGHTING }
var current_state : State = State.IN_TASK

var scheduler : Scheduler
var viewport : Viewport

@export var npc : NPC
@export var combat_brain : CombatBrain
@export var scheduled_brain : ScheduledBrain

var combat_commands : Dictionary
var schedule_commands : Dictionary

@export var thoughts_label_template : PackedScene
var thoughts_label : Label
@export var label_anchor : Node3D


func get_current_state() -> State:
	return current_state

func _ready() -> void:
	scheduler = get_tree().get_root().get_node("Main/Scheduler")
	scheduled_brain.setup(npc)
	viewport = get_viewport()
	thoughts_label = thoughts_label_template.instantiate()
	print(get_tree().root.get_children())
	get_tree().root.get_children()[1].get_children()[2].get_children()[0].add_child(thoughts_label)

func _physics_process(delta: float) -> void:
	if thoughts_label != null:
		thoughts_label.text = ""
		if schedule_commands.size() > 1:
			thoughts_label.text += scheduled_brain.TaskState.keys().get(schedule_commands.get("current_task_state"))
		if combat_commands.size() > 1:
			thoughts_label.text += "\n" + combat_brain.CombatState.keys().get(combat_commands.get("current_combat_state"))
		thoughts_label.text += "\n" + str(npc.stats.health)

		# thoughts_label.text =  + "\n" + combat_brain.CombatState.keys().get(combat_commands.get("current_combat_state"))
		var new_label_position = viewport.get_camera_3d().unproject_position(label_anchor.global_transform.origin)
		new_label_position *= viewport.get_parent().stretch_shrink
		new_label_position = Vector2(new_label_position.x - (thoughts_label.size.x / 2.0), new_label_position.y - (thoughts_label.size.y / 2.0))
		thoughts_label.position = new_label_position

	if npc.is_dead:
		return

	combat_commands = combat_brain.handle_combat(delta, npc)

	match combat_commands.get("current_combat_state"):
		CombatBrain.CombatState.NONE:
			current_state = State.IN_TASK
			scheduled_brain.process_update_landmark_attraction(npc)
			schedule_commands = scheduled_brain.handle_schedule(npc, delta)

			match schedule_commands.get("current_task_state"):
				ScheduledBrain.TaskState.MOVING:
					npc.handle_navigation(schedule_commands.get("landmark_target").position, false)
				# ScheduledBrain.TaskState.IDLING:
				# 	npc.handle_navigation(schedule_commands.get("landmark_target").position)

		CombatBrain.CombatState.LOOKING:
			current_state = State.FIGHTING
			pass

		CombatBrain.CombatState.SEARCHING:
			current_state = State.FIGHTING
			npc.handle_navigation(combat_commands.get("target_position"), combat_commands.get("run"))
			if npc.navigation_agent.distance_to_target() >= combat_brain.max_wandering_distance and not combat_brain.can_see_search_position():
				npc.disable_pathfinding()

		CombatBrain.CombatState.CHASING:
			current_state = State.FIGHTING
			npc.handle_navigation(combat_commands.get("target_position"), combat_commands.get("run"))

		CombatBrain.CombatState.ATTACKING:
			current_state = State.FIGHTING
			npc.handle_navigation(combat_commands.get("target_position"), combat_commands.get("run"))
			npc.do_attack(combat_commands.get("converted_animation_state"), combat_commands.get("weapon"))

		CombatBrain.CombatState.CLOSE:
			current_state = State.FIGHTING
			if npc.is_attacking:
				npc.damage_enemies(combat_commands.get("weapon"))
			elif npc.damaged_enemies_this_attack.size() > 0:
				npc.damaged_enemies_this_attack.clear() # Resets the list of damaged enemies if not attacking

func _on_trigger_death() -> void:
	print("NPC died")
	# _current_state = State.DEAD
	current_state = State.DEAD
	npc.is_dead = true
	npc.death.emit()

func arrive_at_landmark_target():
	scheduled_brain.arrive_at_landmark_target()
