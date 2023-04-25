class_name LanternOil
extends Node2D

signal lantern_oil_collected(amount)

var Player = preload("res://Assets/Player/Scripts/Player.gd")
export var amount: float = 20.0

onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	add_to_group("lantern_oil")
	animation_player.play("Bounce")

func _on_body_entered(body):
	if body is Player:
		emit_signal("lantern_oil_collected", self.amount)
		self.hide()
		$AudioStreamPlayer2D.play()
		yield($AudioStreamPlayer2D, "finished")
		queue_free()
