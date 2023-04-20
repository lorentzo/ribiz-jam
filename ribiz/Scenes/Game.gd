extends Node2D

const GAME_OVER_TIMEOUT: float = 3.0

onready var game_over_hud = preload("res://Assets/HUD/GameOver.tscn").instance()
onready var tree = get_tree()
var is_game_over: bool = false

func _ready():
	$Player.connect("lantern_oil_changed", $LanternHealthHUD, "set_lantern_oil")
	$Player.connect("lantern_extinguished", self, "_set_game_over")
	for lantern_oil in tree.get_nodes_in_group("lantern_oil"):
		lantern_oil.connect("lantern_oil_collected", $Player, "add_lantern_oil")

func _process(delta):
	if is_game_over:
		yield(tree.create_timer(GAME_OVER_TIMEOUT), "timeout")
		tree.reload_current_scene()

func _set_game_over():
	self.add_child(game_over_hud)
	is_game_over = true
