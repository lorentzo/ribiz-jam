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
var return_scent_last_position: Vector2 = Vector2.ZERO
var return_scent_trail = []

onready var ScentScene = preload("res://Assets/Player/Scent.tscn")
onready var parent = get_parent()
onready var ray: RayCast2D = $RayCast2D
onready var return_scent_timer = $ReturnScentTimer


# NOTE: A monster will follow a specified path if there is a Path2D child node
func _ready():
	add_to_group("monster")
	return_scent_timer.connect("timeout", self, "_add_return_scent")
	call_deferred("_set_up_path")

func _add_return_scent(scent_position = null):
	var scent = ScentScene.instance()
	scent.disable_expiration()
	scent.position = self.position if scent_position == null else scent_position
	return_scent_last_position = scent.position

	get_parent().add_child(scent)
	return_scent_trail.push_front(scent)

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
			var return_direction = Vector2.ZERO
			for i in range(return_scent_trail.size() - 1, -1, -1):
				var scent = return_scent_trail[i]
				ray.cast_to = scent.position - position
				ray.force_raycast_update()
				var collider = ray.get_collider()
				if collider == scent:
					return_direction = position.direction_to(scent.position)
					for j in range(i):
						return_scent_trail[j].queue_free()
					return_scent_trail = return_scent_trail.slice(i, return_scent_trail.size() - 1)
					break

			if return_direction == Vector2.ZERO and return_scent_trail.size() == 1:
				return_scent_trail[0].queue_free()
				return_scent_trail.clear()
				self.patrol()
			else:
				move_and_slide(return_direction * speed)

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
	return_scent_timer.start()
	
	if follow == null:
		if was_in_patrol:
			_add_return_scent(chase_start_position)
		return
	
	self.position = start_position
	follow.remove_child(self)
	parent.add_child(self)
	
	if was_in_patrol:
		_add_return_scent(chase_start_position)
	
	follow.set_process(false)

func patrol():
	if state == MonsterState.PATROL:
		return
	
	state = MonsterState.PATROL
	return_scent_timer.stop()
	
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
	return_scent_timer.stop()

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
