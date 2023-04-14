extends AnimatedSprite


var walking_speed = 100;
var running_speed = 3 * walking_speed;

func _ready():
	pass

func _process(delta):
	var velocity = Vector2()
	if Input.is_action_pressed("walk_right"):
		velocity.x = (walking_speed if not Input.is_key_pressed(KEY_SHIFT) else running_speed)
		scale.x = abs(scale.x)
	elif Input.is_action_pressed("walk_left"):
		velocity.x = -(walking_speed if not Input.is_key_pressed(KEY_SHIFT) else running_speed)
		scale.x = -abs(scale.x)

	if Input.is_action_pressed("walk_down"):
		velocity.y = (walking_speed if not Input.is_key_pressed(KEY_SHIFT) else running_speed)
	elif Input.is_action_pressed("walk_up"):
		velocity.y = -(walking_speed if not Input.is_key_pressed(KEY_SHIFT) else running_speed)

	if velocity.length() > 0: play("walk" if not Input.is_key_pressed(KEY_SHIFT) else "run")
	else: play("idle")

	position += velocity * delta
