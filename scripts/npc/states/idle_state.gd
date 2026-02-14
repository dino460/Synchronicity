extends NPCState

class_name IdleState

signal send_position(target_position : Vector3)
signal send_timer(wait_time : float)

var this_npc_id : int

var max_roaming_range : float = 20.0
var min_roaming_range : float = 2.0
var max_rotation_angle : float = PI

var max_wait_time : float = 10.0
var min_wait_time : float = 2.0
var timer : Timer

var landmarks_of_interest : Dictionary[Landmark, Vector3]
var closest_landmark : Landmark


func _ready() -> void:
	helper_thread = Thread.new()
	timer = Timer.new()
	add_child(timer)

func run(start_position : Vector3, forward : Vector3):
	# !!!EXTREMELY DANGEROUS!!!
	# Be warned of potential bad effects this may cause
	# Here it is used to be able to access data in a read-only manner from the landmarks_of_interest DIctionary
	# Without this code, the Landmark reference would not be passed
	# This is a simple, but not optimal way to do this
	# REMAKE THIS CODE AS SOON AS POSSIBLE SO THIS IS NOT NEEDED
	# DO NOT LEAVE THIS HERE UNLESS THERE IS NO OTHER CHOICE
	Thread.set_thread_safety_checks_enabled(false)

	if personality == null:
		printerr("No personality attached to this NPC")

	if randf() < personality.energy:
		var target_direction : Vector3 = forward
		var roaming_range : float = max_roaming_range * sqrt(personality.energy * personality.bravery)
		target_direction.z *= randf_range(min_roaming_range, max(min_roaming_range, roaming_range))

		var rotation_range : float = max_rotation_angle * personality.chaos
		var angle = randf_range(-rotation_range, rotation_range)
		target_direction = target_direction.rotated(Vector3.UP, angle)
		var target_position : Vector3 = start_position + target_direction

		var landmark_position : Vector3
		var landmark_direction : Vector3
		var landmark_attractor_direction : Vector3 = Vector3.ZERO

		for landmark in landmarks_of_interest:
			landmark_position = landmarks_of_interest.get(landmark)
			landmark_position.y = start_position.y
			landmark_direction = (landmark_position - start_position).normalized()

			var distance = landmark_position.distance_squared_to(start_position)
			if landmark != closest_landmark and distance < landmarks_of_interest.get(closest_landmark).distance_squared_to(start_position):
				closest_landmark = landmark

			landmark_direction *= landmark.get_attraction(distance / 10.0)
			landmark_direction *= landmark.get_npc_reputation(this_npc_id) * personality.loyalty * personality.energy

			landmark_attractor_direction += landmark_direction

		call_deferred("emit_signal", "send_position", target_position + landmark_attractor_direction)
	else:
		var wait_time = max_wait_time * (1.0 - personality.energy)

		call_deferred("emit_signal", "send_timer", randf_range(min_wait_time, max(min_wait_time, wait_time)))


func change_state(current_state : NPCState):
	pass


func _on_position_request(start_position : Vector3, forward : Vector3, speed : float):
	if not helper_thread.is_alive():
		helper_thread.start(run.bind(start_position, forward))
		call_deferred("wait_thread", helper_thread)

func _on_append_landmark(landmark : Landmark, landmark_position : Vector3):
	if closest_landmark == null:
		closest_landmark = landmark
	landmarks_of_interest.set(landmark, Vector3(landmark_position.x, 0.0, landmark_position.z))

func wait_thread(thread : Thread):
	thread.wait_to_finish()
