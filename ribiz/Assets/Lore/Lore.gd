extends Control

func _input(event):
	if event is InputEventKey and event.pressed:
			get_tree().change_scene("res://Scenes/Game.tscn")
