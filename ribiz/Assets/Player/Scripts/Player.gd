extends KinematicBody2D


var walking_speed = 100;
var running_speed = 3 * walking_speed;
var player_animated_sprite;

func _ready():
	player_animated_sprite = get_node("Player")
	
func _physics_process(delta):
	
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
	
