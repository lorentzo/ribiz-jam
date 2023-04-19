extends Node2D

var Player = preload("res://Assets/Player/Scripts/Player.gd")
onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

func _ready():
	animation_player.play("Bounce")


func _on_body_entered(body):
	if body is Player:
		# TODO Update the lantern's health
		queue_free()
