extends CanvasLayer

var lamp_health_progress_bar: ProgressBar

func _ready():
	lamp_health_progress_bar = get_node("LampHealthProgressBar")

func set_health(health: float):
	lamp_health_progress_bar.value = health
