class_name Finish
extends Area2D

signal level_finished

func _on_body_entered(body):
	if body is Player:
		print("level_finished")
		emit_signal("level_finished")
