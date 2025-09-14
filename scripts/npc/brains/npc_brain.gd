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

@export var thoughts_label : Label
@export var label_anchor : Node3D


func get_current_state() -> State:
	return current_state

func _ready() -> void:
	scheduler = get_tree().get_root().get_node("Main/Scheduler")
	scheduled_brain.setup(npc)
	viewport = get_viewport()
	thoughts_label = npc.thoughts_label
	label_anchor = npc.label_anchor

func _physics_process(delta: float) -> void:
	combat_commands = combat_brain.handle_combat(delta, npc)
	scheduled_brain.process_update_landmark_attraction(npc)
	schedule_commands = scheduled_brain.handle_schedule(npc, delta)

	if thoughts_label != null:
		thoughts_label.text = scheduled_brain.TaskState.keys().get(schedule_commands.get("current_task_state")) + "\n" + combat_brain.CombatState.keys().get(combat_commands.get("current_combat_state"))
		var new_label_position = viewport.get_camera_3d().unproject_position(label_anchor.global_transform.origin)
		new_label_position *= viewport.get_parent().stretch_shrink
		new_label_position = Vector2(new_label_position.x - (thoughts_label.size.x / 2.0), new_label_position.y - (thoughts_label.size.y / 2.0))
		thoughts_label.position = new_label_position

	match combat_commands.get("current_combat_state"):
		CombatBrain.CombatState.NONE:
			match schedule_commands.get("current_task_state"):
				ScheduledBrain.TaskState.MOVING:
					npc.handle_navigation(schedule_commands.get("landmark_target").position)
				# ScheduledBrain.TaskState.IDLING:
				# 	npc.handle_navigation(schedule_commands.get("landmark_target").position)

		CombatBrain.CombatState.LOOKING:
			pass

		CombatBrain.CombatState.SEARCHING:
			npc.handle_navigation(combat_commands.get("target_position"))

		CombatBrain.CombatState.CHASING:
			npc.handle_navigation(combat_commands.get("target_position"))

		CombatBrain.CombatState.CLOSE:
			pass

		CombatBrain.CombatState.ATTACKING:
			npc.do_attack(combat_commands.get("converted_animation_state"), combat_commands.get("weapon"))


func arrive_at_landmark_target():
	scheduled_brain.arrive_at_landmark_target()
