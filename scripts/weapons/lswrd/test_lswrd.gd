extends Weapon

class_name TestLongsword

func _init() -> void:
	type = WeaponType.LSWRD
	# weapon_hand_transform = Transform3D(Vector3(0.288, -0.132, -0.949), Vector3(-0.957, 0.002, -0.291), Vector3(0.041, 0.991, -0.126), Vector3(0.319, 0.598, -1.647))

	weapon_hand_transform = Transform3D(Vector3(0.288, -0.957, 0.041), Vector3(-0.132, 0.002, 0.991), Vector3(-0.949, -0.291, -0.126), Vector3(0.319, 0.598, -1.647))
	weapon_sheathe_transform = Transform3D(Vector3(0.59, 0.806, -0.053), Vector3(0.08, -0.123, -0.989), Vector3(-0.803, 0.579, -0.137), Vector3(0.806, 0.246, 3.613))
	stamina_cost_per_stance = {
		AnimationHandler.AttackStances.PLOW: 50.0,
		AnimationHandler.AttackStances.TWOHORN: 40.0,
		AnimationHandler.AttackStances.FOOL: 60.0,
		AnimationHandler.AttackStances.ROOF: 70.0,
	}

# sheathe => [X: (0.589915, 0.805749, -0.052619), Y: (0.080181, -0.123297, -0.989125), Z: (-0.803474, 0.579281, -0.13734), O: (0.806, 0.246, 3.613)]
# hand    => [X: (0.288, -0.957, 0.041), Y: (-0.132, 0.002, 0.991), Z: (-0.949, -0.291, -0.126), O: (0.319, 0.598, -1.647)]
