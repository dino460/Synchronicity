extends Weapon

func _ready():
	type = "dragon_breath"
	# up_attack_time = 1.5
	attack_animations[AnimationHandler.AnimationState.ATTACK_UP] = "attack"
	attack_animations[AnimationHandler.AnimationState.ATTACK_DOWN] = "attack"
	attack_animations[AnimationHandler.AnimationState.ATTACK_LEFT] = "attack"
	attack_animations[AnimationHandler.AnimationState.ATTACK_RIGHT] = "attack"

	stamina_cost_per_attack = {
		AnimationHandler.AnimationState.ATTACK_UP: 5,
		AnimationHandler.AnimationState.ATTACK_DOWN: 5,
		AnimationHandler.AnimationState.ATTACK_LEFT: 5,
		AnimationHandler.AnimationState.ATTACK_RIGHT: 5
	}

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
