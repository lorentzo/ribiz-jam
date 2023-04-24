class_name Scent
extends Area2D
signal scent_expired

func _ready():
	$Timer.connect("timeout", self, "_signal_scent_expired")

func disable_expiration():
	$Timer.stop()

func _signal_scent_expired():
	emit_signal("scent_expired", self)
	queue_free()
