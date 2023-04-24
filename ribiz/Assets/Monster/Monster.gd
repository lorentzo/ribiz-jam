class_name Monster
extends KinematicBody2D

const CHASE_START_THRESHOLD = 150
const CHASE_STOP_THRESHOLD = 300

export var speed = 50
var chase_speed = 2.5 * speed

enum MonsterState {
	PATROL,
	CHASE,
	RETURN,
}

var state = MonsterState.PATROL
var follow: PathFollow2D = null
var player_position: Vector2
var player_scent_trail = []
var chase_start_position: Vector2

onready var parent = get_parent()
onready var ray: RayCast2D = $RayCast2D

# NOTE: A monster will follow a specified path if there is a Path2D child node
func _ready():
	add_to_group("monster")
	call_deferred("_set_up_path")

func _physics_process(delta):
	if state == MonsterState.CHASE:
		var player_offset = player_position - position
		var player_distance = player_offset.length()
		if player_distance > CHASE_STOP_THRESHOLD:
			self.return()
			return

		ray.cast_to = player_offset
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider()
			var chase_direction = Vector2.ZERO
			if collider is Player:
				chase_direction = position.direction_to(player_position)
			else:
				for scent in player_scent_trail:
					ray.cast_to = scent.position - position
					ray.force_raycast_update()
					collider = ray.get_collider()
					if collider is Scent:
						chase_direction = position.direction_to(scent.position)
						break
			move_and_slide(chase_direction * chase_speed)
	elif state == MonsterState.PATROL:
		var position = follow.get_parent().position + follow.position if follow != null else self.position
		var player_distance = (player_position - position).length()
		if player_distance < CHASE_START_THRESHOLD:
			self.chase(position)
	elif state == MonsterState.RETURN:
		var player_distance = (player_position - position).length()
		if player_distance < CHASE_START_THRESHOLD:
			self.chase(position)
		else:
			pass # TODO

func update_player_position(position: Vector2):
	player_position = position

func update_player_scent_trail(scent_trail):
	player_scent_trail = scent_trail

func chase(start_position: Vector2):
	if state == MonsterState.CHASE:
		return
	
	var was_in_patrol = (state == MonsterState.PATROL)
	if was_in_patrol:
		chase_start_position = start_position
	state = MonsterState.CHASE
	if follow == null:
		return
	
	self.position = start_position
	follow.remove_child(self)
	parent.add_child(self)
	
	follow.set_process(false)

func patrol():
	if state == MonsterState.PATROL:
		return
	
	state = MonsterState.PATROL
	if follow == null:
		return
		
	parent.remove_child(self)
	follow.add_child(self)
	follow.set_process(true)
	self.position = Vector2.ZERO

func return():
	if state == MonsterState.RETURN:
		return
	
	state = MonsterState.RETURN

func _set_up_path():
	var route: Path2D = null

	for child in get_children():
		if child is Path2D:
			route = child
			break
			
	if route == null:
		return
		
	# Swap nodes
	# -> Path2D/PathFollow2D becomes the parent of Monster
	remove_child(route)
	parent.add_child(route)
	parent.remove_child(self)
	route.position = self.position + route.position
	
	follow = MonsterFollow.new(speed)
	follow.loop = true
	follow.rotate = false
	follow.add_child(self)
	route.add_child(follow)
	self.position = Vector2.ZERO
