extends Weapon

func _ready():
	type = "shortsword"
	light_attack_time = 1.5
#	light_attack_animations = ["rigAction_001", "light_attack_shortsword_B"]
	light_attack_animations = ["light_attack_shortsword_A", "light_attack_shortsword_B"]
	combo_wait_time = 1.0
	pass;
