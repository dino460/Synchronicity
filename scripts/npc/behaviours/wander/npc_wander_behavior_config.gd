class_name NPCWanderBehaviorConfig
extends GdPAIBehaviorConfig
## Behavior configuration for agents that wander around the environment.

## Distance the agent will wander in each action.
@export var wander_distance: float = 20.0
@export var energy_decay: float = 20.0


# Override
func _self_init() -> void:
	super()
	goals.append(WanderGoal.new())
	self_actions.append(WanderAction.new(wander_distance, energy_decay))
