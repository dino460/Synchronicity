extends Node

var minimum_pixelation    : int = 3
var pixelation_correction : int = 3

# @export_enum("Off:0", "Potato:8000", "Ultra Low:24000", "Very Low:40000", "Low:80000", "Low/Medium:104000", "Medium:240000", "High:320000", "Very High:400000", "Ultra:640000")
# var level_of_detail : int = 80000
#
# @export_enum("Single:1", "Quarters:4", "Eights:16", "Many:64", "A Lot:256", "A Lot More:1024")
# var number_of_groups : int = 4

enum GrassDensity {
	OFF = 0,
	LOW = 10000,
	MEDIUM = 20000,
	HIGH = 80000,
	ULTRA = 320000,
	BENCHMARK_1M = 1000000,
	BENCHMARK_5M = 5000000,
	BENCHMARK_10M = 10000000,
}

@export var grass_density : GrassDensity = GrassDensity.HIGH

@export var cloud_scroll_speed : Vector2 = Vector2.ZERO:
	set(value):
		cloud_scroll_speed = value
		RenderingServer.global_shader_parameter_set("cloud_scroll_speed", value)

@export var cloud_cover_scale : float = 0.01:
	set(value):
		cloud_cover_scale = value
		RenderingServer.global_shader_parameter_set("cloud_cover_scale", value)

@export var cloud_cover_threshold : float = 0.5:
	set(value):
		cloud_cover_threshold = value
		RenderingServer.global_shader_parameter_set("cloud_cover_threshold", value)


func _ready() -> void:
	RenderingServer.global_shader_parameter_set("cloud_scroll_speed", cloud_scroll_speed)
	RenderingServer.global_shader_parameter_set("cloud_cover_scale", cloud_cover_scale)
	RenderingServer.global_shader_parameter_set("cloud_cover_threshold", cloud_cover_threshold)
