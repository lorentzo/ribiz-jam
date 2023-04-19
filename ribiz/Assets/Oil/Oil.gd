class_name Oil
extends Node2D

signal oil_collected(oil_amount)

var Player = preload("res://Assets/Player/Scripts/Player.gd")
export var amount: float = 20.0

onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	add_to_group("oil")
	animation_player.play("Bounce")

func _on_body_entered(body):
	if body is Player:
		emit_signal("oil_collected", self.amount)
		queue_free()
