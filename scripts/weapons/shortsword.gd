extends Weapon

func _ready():
	type = "shortsword"
	# up_attack_time = 1.5
	attack_animations[AnimationHandler.AnimationState.ATTACK_UP] = "attack_up_shortsword"

	preferred_attack_stream.append_array([
		PreferredNextAttack.new(AnimationHandler.AnimationState.ATTACK_UP, AnimationHandler.AnimationState.ATTACK_DOWN),
		PreferredNextAttack.new(AnimationHandler.AnimationState.ATTACK_UP, AnimationHandler.AnimationState.ATTACK_LEFT),
		PreferredNextAttack.new(AnimationHandler.AnimationState.ATTACK_UP, AnimationHandler.AnimationState.ATTACK_RIGHT),
		PreferredNextAttack.new(AnimationHandler.AnimationState.ATTACK_DOWN, AnimationHandler.AnimationState.ATTACK_UP),
		PreferredNextAttack.new(AnimationHandler.AnimationState.ATTACK_DOWN, AnimationHandler.AnimationState.ATTACK_LEFT),
		PreferredNextAttack.new(AnimationHandler.AnimationState.ATTACK_DOWN, AnimationHandler.AnimationState.ATTACK_RIGHT),
		PreferredNextAttack.new(AnimationHandler.AnimationState.ATTACK_LEFT, AnimationHandler.AnimationState.ATTACK_UP),
		PreferredNextAttack.new(AnimationHandler.AnimationState.ATTACK_LEFT, AnimationHandler.AnimationState.ATTACK_DOWN),
		PreferredNextAttack.new(AnimationHandler.AnimationState.ATTACK_LEFT, AnimationHandler.AnimationState.ATTACK_RIGHT),
		PreferredNextAttack.new(AnimationHandler.AnimationState.ATTACK_RIGHT, AnimationHandler.AnimationState.ATTACK_UP),
		PreferredNextAttack.new(AnimationHandler.AnimationState.ATTACK_RIGHT, AnimationHandler.AnimationState.ATTACK_DOWN),
		PreferredNextAttack.new(AnimationHandler.AnimationState.ATTACK_RIGHT, AnimationHandler.AnimationState.ATTACK_RIGHT),
	])

	pass;

func is_preferred_attack(current_attack : AnimationHandler.AnimationState, next_attack : AnimationHandler.AnimationState) -> bool:
	for preference in preferred_attack_stream:
		if preference.this_attack == current_attack and preference.preferred_next == next_attack:
			return true
	return false
