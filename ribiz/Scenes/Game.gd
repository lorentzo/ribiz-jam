extends Node2D

const GAME_OVER_TIMEOUT: float = 3.0
const THEME_DB_OFFSET: float = -5.0

onready var game_over_hud = preload("res://Assets/HUD/GameOver.tscn").instance()
onready var tree = get_tree()
onready var theme = $ThemePlayer
var is_game_over: bool = false

func _ready():
	$Player.connect("lantern_oil_changed", $LanternHealthHUD, "set_lantern_oil")
	$Player.connect("lantern_oil_changed", self, "_set_theme_volume")
	$Player.connect("lantern_extinguished", self, "_set_game_over")
	for lantern_oil in tree.get_nodes_in_group("lantern_oil"):
		lantern_oil.connect("lantern_oil_collected", $Player, "add_lantern_oil")

	for monster in tree.get_nodes_in_group("monster"):
		$Player.connect("player_position", monster, "update_player_position")
		$Player.connect("player_scent_trail", monster, "update_player_scent_trail")

func _process(delta):
	if is_game_over:
		yield(tree.create_timer(GAME_OVER_TIMEOUT), "timeout")
		tree.reload_current_scene()

func _set_theme_volume(volume_percentage: float):
	theme.volume_db = 10 * log(volume_percentage) / log(10) + THEME_DB_OFFSET

func _set_game_over():
	self.add_child(game_over_hud)
	theme.stop()
	is_game_over = true
