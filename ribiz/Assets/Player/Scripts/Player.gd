extends KinematicBody2D

const LAMP_RADIUS_MIN: float = 200.0
const LAMP_ENERGY_GAME_OVER: float = 0.1

var walking_speed: float = 100
var running_speed: float = 3 * walking_speed
var tree: SceneTree
var player_animated_sprite: AnimatedSprite
var lamp_light: Light2D
var lamp_time_left: float = 60
var game_over: bool = false
var game_over_hud = preload("res://Assets/HUD/GameOver.tscn").instance()

func _ready():
	tree = get_tree()
	player_animated_sprite = get_node("Player")
	lamp_light = player_animated_sprite.get_node("LampSprite/LampLight")
	
func _physics_process(delta):
	if not game_over:
		update_player(delta)
		update_lamp(delta)
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
	
func update_lamp(delta):
	lamp_time_left = max(lamp_time_left - delta, 0)
	var lamp_light_scale = lamp_time_left / 60
	var lamp_light_size = min(lamp_light.texture.get_width() * lamp_light.scale.x, lamp_light.texture.get_height() * lamp_light.scale.y)
	if lamp_light_size > LAMP_RADIUS_MIN:
		lamp_light.scale.x = lamp_light_scale
		lamp_light.scale.y = lamp_light_scale
	lamp_light.energy = sqrt(lamp_time_left / 60)

func update_game_over():
	if not game_over and lamp_light.energy <= LAMP_ENERGY_GAME_OVER:
		game_over = true
		tree.get_root().get_node("/root/Level").add_child(game_over_hud)
