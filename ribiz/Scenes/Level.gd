extends Node2D

onready var game_over_hud = preload("res://Assets/HUD/GameOver.tscn").instance()
onready var tree = get_tree()
var is_game_over: bool = false

func _ready():
	$Player.connect("lantern_health_changed", $LanternHealthHUD, "set_health")
	$Player.connect("lantern_extinguished", self, "_signal_game_over")

func _process(delta):
	if is_game_over:
		yield(tree.create_timer(3.0), "timeout")
		tree.reload_current_scene()

func _signal_game_over():
	self.add_child(game_over_hud)
	is_game_over = true
