class_name RecoverEnergyBehaviorConfig
extends GdPAIBehaviorConfig
## Behavior configuration for agents that experience energy loss and resting.

@export var energy_recovery: float = 4.0


# Override
func _self_init() -> void:
	super()
	goals.append(RecoverEnergyGoal.new())
	self_actions.append(RecoverEnergyAction.new(energy_recovery))
