extends CanvasLayer

onready var lamp_health_progress_bar: ProgressBar = $LampHealthProgressBar

func set_health(health: float):
	lamp_health_progress_bar.value = health
