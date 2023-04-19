class_name Player
extends KinematicBody2D

signal lantern_health_changed(lantern_health)
signal lantern_extinguished

const LANTERN_RADIUS_MIN: float = 200.0
const LANTERN_ENERGY_GAME_OVER: float = 0.1
const LANTERN_OIL_MAX: float = 100.0
const LANTERN_OIL_PER_SECOND: float = 1.0

var walking_speed: float = 100
var running_speed: float = 2 * walking_speed
var lantern_oil = LANTERN_OIL_MAX
var lantern_extinguished: bool = false

onready var lantern_light: Light2D = $Player/LanternSprite/LanternLight

func add_lantern_oil(amount: float):
	lantern_oil = min(lantern_oil + amount, LANTERN_OIL_MAX)

func _physics_process(delta):
	if not lantern_extinguished:
		_update_player(delta)
		_update_lantern(delta)
		_update_game_over()
	
func _update_player(delta):
	var running = Input.is_key_pressed(KEY_SHIFT)
	var speed = (running_speed if running else walking_speed)

	var velocity = Vector2()

	if Input.is_action_pressed("walk_right"):
		velocity.x = speed
		$Player.scale.x = abs($Player.scale.x)
	elif Input.is_action_pressed("walk_left"):
		velocity.x = -speed
		$Player.scale.x = -abs($Player.scale.x)

	if Input.is_action_pressed("walk_down"):
		velocity.y = speed
	elif Input.is_action_pressed("walk_up"):
		velocity.y = -speed

	if velocity.length_squared() > 0: 
		$Player.play("walk" if not running else "run")
	else: 
		$Player.play("idle")
		
	move_and_slide(velocity)
	
func _update_lantern(delta):
	lantern_oil = max(lantern_oil - LANTERN_OIL_PER_SECOND * delta, 0)
	var lantern_health = lantern_oil / LANTERN_OIL_MAX
	var lantern_light_size = min(lantern_light.texture.get_width() * lantern_light.scale.x, lantern_light.texture.get_height() * lantern_light.scale.y)
	if lantern_light_size > LANTERN_RADIUS_MIN:
		lantern_light.scale.x = lantern_health
		lantern_light.scale.y = lantern_health
	lantern_light.energy = sqrt(lantern_health)
	emit_signal("lantern_health_changed", lantern_health)

func _update_game_over():
	if not lantern_extinguished and lantern_light.energy <= LANTERN_ENERGY_GAME_OVER:
		lantern_extinguished = true
		emit_signal("lantern_extinguished")
