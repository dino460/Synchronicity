extends Node

class_name NPCBrain

enum State { DOING_STUFF, MOVING_ABOUT, SLEEPING, DEAD, FIGHTING }
var current_state : State = State.DOING_STUFF

@export var npc : NPC
@export var combat_brain : CombatBrain
@export var scheduled_brain : ScheduledBrain

func _ready() -> void:
	scheduled_brain.setup(npc)

func _physics_process(delta: float) -> void:
	combat_brain.handle_combat(delta, npc)
	print(scheduled_brain.choose_next_location(npc))
