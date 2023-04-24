extends Control

func _ready():
	$VBoxContainer/StartGameStoryButton.grab_focus()

func _on_StartGameStoryButton_pressed():
	get_tree().change_scene("res://Scenes/Game.tscn")

func _on_ExitGameButton_pressed():
	get_tree().quit()
