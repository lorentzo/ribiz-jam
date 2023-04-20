extends CanvasLayer

onready var lamp_health_progress_bar: ProgressBar = $LampHealthProgressBar

func set_lantern_oil(lantern_oil: float):
	lamp_health_progress_bar.value = lantern_oil
