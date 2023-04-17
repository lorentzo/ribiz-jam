extends AnimatedSprite


var walking_speed = 100;
var running_speed = 3 * walking_speed;

func _ready():
	pass

func _process(delta):
	var running = Input.is_key_pressed(KEY_SHIFT)
	var speed = (running_speed if running else walking_speed)

	var velocity = Vector2()

	if Input.is_action_pressed("walk_right"):
		velocity.x = speed
		scale.x = abs(scale.x)
	elif Input.is_action_pressed("walk_left"):
		velocity.x = -speed
		scale.x = -abs(scale.x)

	if Input.is_action_pressed("walk_down"):
		velocity.y = speed
	elif Input.is_action_pressed("walk_up"):
		velocity.y = -speed

	if velocity.length_squared() > 0: play("walk" if not running else "run")
	else: play("idle")

	position += velocity * delta
