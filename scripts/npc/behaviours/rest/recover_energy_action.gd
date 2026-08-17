class_name RecoverEnergyAction
extends Action

var rest_duration : float
## How much energy increases while resting per second.
var energy_recovery : float

# This action shows how you can directly inject parameters.
func _init(p_energy_recovery : float) -> void:
	self.energy_recovery = p_energy_recovery
	rest_duration = 100.0 / energy_recovery


# Override
func get_validity_checks() -> Array[Precondition]:
	var checks: Array[Precondition] = super()
	checks.append(Precondition.agent_has_property("energy"))
	checks.append(Precondition.agent_property_less_than("energy", 100))
	return checks


# Override
func get_action_cost(
		agent_blackboard: GdPAIBlackboard,
		world_state: GdPAIBlackboard,
) -> float:
	var cost: float = super(agent_blackboard, world_state)
	if cost == INF:
		return INF

	# Including how long it takes to rest as a cost metric for demo purposes.
	return cost + rest_duration


# Override
func get_preconditions() -> Array[Precondition]:
	return []


# Override
func simulate_effect(
		agent_blackboard: GdPAIBlackboard,
		world_state: GdPAIBlackboard,
) -> void:
	super(agent_blackboard, world_state)
	var energy: float = agent_blackboard.get_property("energy")
	energy += energy_recovery
	agent_blackboard.set_property("energy", energy)


# Override
func reverse_simulate_effect(
		_agent_blackboard: GdPAIBlackboard,
		_world_state: GdPAIBlackboard,
) -> void:
	pass


# Override
func pre_perform_action(agent: GdPAIAgent) -> Action.Status:
	if super(agent) == Action.Status.FAILURE:
		return Action.Status.FAILURE

	var location_data: GdPAILocationData = agent.blackboard.get_first_object_in_group(
		"GdPAILocationData",
	)
	var entity: Node = agent.blackboard.get_property("entity")
	var nav_agent = GdPAIUTILS.get_child_of_type(entity, NavigationAgent3D)
	nav_agent.target_position = location_data.position
	agent.blackboard.set_property(uid_property("resting_duration"), 0)

	rest_duration = (100 - agent.blackboard.get_property("energy")) / energy_recovery

	return Action.Status.SUCCESS


# Override
func perform_action(
		agent: GdPAIAgent,
		delta: float,
) -> Action.Status:
	var parent_status: Action.Status = super(agent, delta)
	if parent_status == Action.Status.FAILURE:
		return Action.Status.FAILURE

	# Update how long we've been resting
	var resting_duration: float = agent.blackboard.get_property(uid_property("resting_duration"))
	resting_duration += delta
	agent.blackboard.set_property(uid_property("resting_duration"), resting_duration)

	# Update energy
	var energy: float = agent.blackboard.get_property("energy")
	agent.blackboard.set_property("energy", energy + energy_recovery * delta)

	if resting_duration > rest_duration:
		return Action.Status.SUCCESS

	return Action.Status.RUNNING


# Override
func post_perform_action(agent: GdPAIAgent) -> Action.Status:
	super(agent)
	agent.blackboard.erase_property(uid_property("resting_duration"))
	return Action.Status.SUCCESS


# Override
func get_title() -> String:
	return "Rest"


# Override
func get_description() -> String:
	return "Rest for a while."
