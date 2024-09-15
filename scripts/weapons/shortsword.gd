extends Weapon

func _ready():
	type = "shortsword"
	up_attack_time = 1.5
	up_attack_animations = ["up_attack_shortsword", "up_attack_shortsword_from_down"]

	preferred_attack_stream.append_array([
		PreferredNextAttack.new(AnimationHandler.State.ATTACK_UP, AnimationHandler.State.ATTACK_DOWN),
		PreferredNextAttack.new(AnimationHandler.State.ATTACK_UP, AnimationHandler.State.ATTACK_LEFT),
		PreferredNextAttack.new(AnimationHandler.State.ATTACK_UP, AnimationHandler.State.ATTACK_RIGHT),
		PreferredNextAttack.new(AnimationHandler.State.ATTACK_DOWN, AnimationHandler.State.ATTACK_UP),
		PreferredNextAttack.new(AnimationHandler.State.ATTACK_DOWN, AnimationHandler.State.ATTACK_LEFT),
		PreferredNextAttack.new(AnimationHandler.State.ATTACK_DOWN, AnimationHandler.State.ATTACK_RIGHT),
		PreferredNextAttack.new(AnimationHandler.State.ATTACK_LEFT, AnimationHandler.State.ATTACK_UP),
		PreferredNextAttack.new(AnimationHandler.State.ATTACK_LEFT, AnimationHandler.State.ATTACK_DOWN),
		PreferredNextAttack.new(AnimationHandler.State.ATTACK_LEFT, AnimationHandler.State.ATTACK_RIGHT),
		PreferredNextAttack.new(AnimationHandler.State.ATTACK_RIGHT, AnimationHandler.State.ATTACK_UP),
		PreferredNextAttack.new(AnimationHandler.State.ATTACK_RIGHT, AnimationHandler.State.ATTACK_DOWN),
		PreferredNextAttack.new(AnimationHandler.State.ATTACK_RIGHT, AnimationHandler.State.ATTACK_RIGHT),
	])

	pass;

func is_preferred_attack(current_attack : AnimationHandler.State, next_attack : AnimationHandler.State) -> bool:
	for preference in preferred_attack_stream:
		if preference.this_attack == current_attack and preference.preferred_next == next_attack:
			return true
	return false
