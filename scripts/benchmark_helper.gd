extends Button


@export var tester_name : String = ""

var fps_data : Dictionary[int, float]
var current_data_point : int = 0
var gather_data : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if gather_data:
		fps_data[current_data_point] = Engine.get_frames_per_second()
		current_data_point += 1
	pass


## Writes data to following locations:
## 	Windows: %APPDATA%\[project_name]
## 	Linux: ~/.local/share/[project_name]
## 	macOS: ~/Library/Application Support/[project_name]
func write_data_to_file() -> bool:
	var file_name : String = tester_name + "_benchmark_" + Time.get_datetime_string_from_system()
	var file : FileAccess = FileAccess.open("user://" + file_name, FileAccess.WRITE)

	if file:
		for data in fps_data:
			var string : String = str("%d,%.f" % [data, fps_data[data]])
			file.store_line(string)
			print(data, " ", fps_data[data])
		file.close()

		return true
	else:
		return false


func _on_pressed() -> void:
	if gather_data:
		self.text = "Start Benchmark"
		write_data_to_file()
	else:
		self.text = "Stop Benchmark"

	gather_data = not gather_data
	current_data_point = 0
	fps_data.clear()
