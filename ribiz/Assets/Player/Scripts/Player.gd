extends KinematicBody2D

const LANTERN_RADIUS_MIN: float = 200.0
const LANTERN_ENERGY_GAME_OVER: float = 0.1
const LANTERN_OIL_MAX: float = 100.0
const LANTERN_OIL_PER_SECOND: float = 1.0

var walking_speed: float = 100
var running_speed: float = 2 * walking_speed
var tree: SceneTree
var player_animated_sprite: AnimatedSprite
var lantern_light: Light2D
var lantern_oil = LANTERN_OIL_MAX

var game_over: bool = false
var game_over_hud = preload("res://Assets/HUD/GameOver.tscn").instance()
var lantern_health_hud

func _ready():
	tree = get_tree()
	player_animated_sprite = get_node("Player")
	lantern_light = player_animated_sprite.get_node("LanternSprite/LanternLight")
	lantern_health_hud = tree.get_root().get_node("/root/Level/LanternHealthHUD")

func _physics_process(delta):
	if not game_over:
		update_player(delta)
		update_lantern(delta)
		update_game_over()
	else:
		yield(get_tree().create_timer(3.0), "timeout")
		tree.reload_current_scene()
	
func update_player(delta):
	var running = Input.is_key_pressed(KEY_SHIFT)
	var speed = (running_speed if running else walking_speed)

	var velocity = Vector2()

	if Input.is_action_pressed("walk_right"):
		velocity.x = speed
		player_animated_sprite.scale.x = abs(player_animated_sprite.scale.x)
	elif Input.is_action_pressed("walk_left"):
		velocity.x = -speed
		player_animated_sprite.scale.x = -abs(player_animated_sprite.scale.x)

	if Input.is_action_pressed("walk_down"):
		velocity.y = speed
	elif Input.is_action_pressed("walk_up"):
		velocity.y = -speed

	if velocity.length_squared() > 0: 
		player_animated_sprite.play("walk" if not running else "run")
	else: 
		player_animated_sprite.play("idle")
		
	move_and_slide(velocity)
	
func update_lantern(delta):
	lantern_oil = max(lantern_oil - LANTERN_OIL_PER_SECOND * delta, 0)
	var lantern_light_scale = lantern_oil / LANTERN_OIL_MAX
	var lantern_light_size = min(lantern_light.texture.get_width() * lantern_light.scale.x, lantern_light.texture.get_height() * lantern_light.scale.y)
	if lantern_light_size > LANTERN_RADIUS_MIN:
		lantern_light.scale.x = lantern_light_scale
		lantern_light.scale.y = lantern_light_scale
	lantern_light.energy = sqrt(lantern_oil / LANTERN_OIL_MAX)
	lantern_health_hud.set_health(lantern_oil / LANTERN_OIL_MAX * 100)

func update_game_over():
	if not game_over and lantern_light.energy <= LANTERN_ENERGY_GAME_OVER:
		game_over = true
		tree.get_root().get_node("/root/Level").add_child(game_over_hud)
