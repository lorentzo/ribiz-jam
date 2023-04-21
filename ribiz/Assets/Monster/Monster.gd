class_name Monster
extends KinematicBody2D

const CHASE_THRESHOLD = 150

export var speed = 50
var chase_speed = 2 * speed

enum MonsterState {
	PATROL,
	CHASE,
	RETURN,
}

var state = MonsterState.PATROL
var follow: PathFollow2D = null
var player_position: Vector2
var is_path_set_up: bool = false

onready var initial_position = self.position
onready var parent = get_parent()

# NOTE: A monster will follow a specified path if there is a Path2D child node
func _ready():
	add_to_group("monster")
	call_deferred("_set_up_path")

func _physics_process(delta):
	if state == MonsterState.CHASE:
		move_and_slide((player_position - position).normalized() * chase_speed)
	elif state == MonsterState.PATROL:
		if is_path_set_up:
			var position = follow.get_parent().position + follow.position
			var player_distance = (player_position - position).length()
			if player_distance < CHASE_THRESHOLD:
				self.chase(position)

func update_player_position(position: Vector2):
	player_position = position

func chase(start_position: Vector2):
	if state == MonsterState.CHASE:
		return
	
	state = MonsterState.CHASE
	if follow == null:
		return
	
	self.position = start_position
	follow.remove_child(self)
	parent.add_child(self)

func patrol():
	if state == MonsterState.PATROL:
		return
	
	state = MonsterState.PATROL
	if follow == null:
		self.position = initial_position
		return
		
	parent.remove_child(self)
	follow.add_child(self)

func _set_up_path():
	is_path_set_up = true

	var route: Path2D = null

	for child in get_children():
		if child is Path2D:
			route = child
			break
			
	if route == null:
		return
		
	# Swap nodes
	# -> Path2D/PathFollow2D becomes the parent of Monster
	var route_position = self.position + route.position
	remove_child(route)
	parent.add_child(route)
	parent.remove_child(self)
	route.position = route_position
	
	follow = MonsterFollow.new(speed)
	follow.loop = true
	follow.rotate = false
	follow.add_child(self)
	route.add_child(follow)
	self.position = Vector2.ZERO
