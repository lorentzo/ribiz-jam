extends Control

func _ready():
	$VBoxContainer/StartGameStoryButton.grab_focus()

func _on_StartGameStoryButton_pressed():
	#get_tree().change_scene("res://Scenes/Game.tscn")
	get_tree().change_scene("res://Scenes/Lore.tscn")

func _on_CreditsButton_pressed():
	get_tree().change_scene("res://Scenes/Credits.tscn")

func _on_ExitGameButton_pressed():
	get_tree().quit()
