extends Node2D

const STORY_MODE_LEVELS = [
	"res://Scenes/Level1-Borna.tscn",
	"res://Scenes/Level2-Borna.tscn",
]

const THEME_DB_OFFSET: float = -10.0

onready var game_over_hud = preload("res://Assets/HUD/GameOver.tscn").instance()
onready var tree = get_tree()
onready var theme = $ThemePlayer
onready var game_over = $GameOverPlayer
var current_level_index = 0
var current_level

func _ready():
	_load_level()

func _load_level():
	var level_scenes = load(STORY_MODE_LEVELS[current_level_index])
	current_level = level_scenes.instance()
	var level_finish = current_level.get_node("Finish")
	level_finish.connect("level_finished", self, "_on_level_finished")
	var player_start: Node2D = current_level.get_node("Start")
	$Player.position = current_level.position + player_start.position
	$Player.set_lantern_oil($Player.LANTERN_OIL_MAX)
	self.add_child(current_level)
	self.move_child(current_level, 0)

	# Register signals
	$Player.connect("lantern_oil_changed", $LanternHealthHUD, "set_lantern_oil")
	$Player.connect("lantern_oil_changed", self, "_set_theme_volume")
	$Player.connect("lantern_extinguished", self, "_set_game_over")
	for lantern_oil in tree.get_nodes_in_group("lantern_oil"):
		lantern_oil.connect("lantern_oil_collected", $Player, "add_lantern_oil")

	for monster in tree.get_nodes_in_group("monster"):
		$Player.connect("player_position", monster, "update_player_position")
		$Player.connect("player_scent_trail", monster, "update_player_scent_trail")


func _on_level_finished():
	current_level.queue_free()
	
	if current_level_index == STORY_MODE_LEVELS.size() - 1:
		# Win!
		get_tree().change_scene("res://Scenes/Main.tscn")
		return
	
	current_level_index += 1
	_load_level()

func _set_theme_volume(volume_percentage: float):
	theme.volume_db = 10 * log(volume_percentage) / log(10) + THEME_DB_OFFSET

func _set_game_over():
	self.add_child(game_over_hud)
	theme.stop()
	game_over.play()
	yield(game_over, "finished")
	tree.reload_current_scene()
