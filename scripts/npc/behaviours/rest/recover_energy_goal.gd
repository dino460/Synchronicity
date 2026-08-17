class_name RecoverEnergyGoal
extends Goal
## Simple GdPAI goal to rest and keep energy up.


func _init() -> void:
	priority = Goal.Priority.MEDIUM


# Override
func compute_reward(agent: GdPAIAgent) -> float:
	return 100.0 - agent.blackboard.get_property("energy", 100.0)


# Override
func get_desired_state(agent: GdPAIAgent) -> Array[Precondition]:
	var current_energy: float = agent.blackboard.get_property("energy")
	return [Precondition.agent_property_greater_than("energy", current_energy)]


# Override
func get_title() -> String:
	return "Recover Energy"


# Override
func get_description() -> String:
	return "Rest and keep energy up."
