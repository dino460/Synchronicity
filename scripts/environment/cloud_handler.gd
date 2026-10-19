extends MeshInstance3D

@export var sun: DirectionalLight3D
@export var anchor: Node3D            # player or camera focus
@export var distance := 150.0         # free parameter, see below

var _off_x := 0.0
var _off_y := 0.0
var _last_anchor := Vector3.ZERO
var _started := false

func _ready() -> void:
	process_priority = 100             # run after the player and sun have moved

func _process(delta: float) -> void:
	var b := sun.global_basis.orthonormalized()
	var p := anchor.global_position
	if not _started:
		_last_anchor = p
		_started = true

	# Sheet faces the sun, centred on the anchor. Light travels along -Z, so +Z points at the sun.
	global_basis = b
	global_position = p + b.z * distance

	# World-anchoring: anchor movement + wind, projected on the current sheet axes.
	# Same sign convention as the old shader (coord = pos + scroll * t).
	# var scroll: Vector2 = RenderingServer.global_shader_parameter_get("cloud_scroll_speed")
	var scroll: Vector2 = GlobalSettings.cloud_scroll_speed
	var d := (p - _last_anchor) + Vector3(scroll.x, 0.0, scroll.y) * delta
	_last_anchor = p
	_off_x += d.dot(b.x)
	_off_y += d.dot(b.y)

	# Wrap by one noise period so the values stay small (needs a repeating texture).
	# var period := 1.0 / float(RenderingServer.global_shader_parameter_get("cloud_cover_scale"))
	var period := 1.0 / float(GlobalSettings.cloud_cover_scale)
	_off_x = fposmod(_off_x, period)
	_off_y = fposmod(_off_y, period)
	RenderingServer.global_shader_parameter_set("cloud_plane_offset", Vector2(_off_x, _off_y))
