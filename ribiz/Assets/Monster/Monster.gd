class_name Monster
extends KinematicBody2D

export var speed = 50

var route: Path2D = null

# NOTE: A monster will follow a specified path if there is a Path2D child node
func _ready():
	call_deferred("_set_up_path")

func _set_up_path():
	for child in get_children():
		if child is Path2D:
			route = child
			break
			
	if route == null:
		return
		
	# Swap Monster and Path2D nodes
	# -> Path2D becomes the parent of Monster
	var parent = get_parent()		
	remove_child(route)
	parent.add_child(route)
	parent.remove_child(self)
	
	var follow = MonsterFollow.new(speed)
	follow.loop = true
	follow.rotate = false
	follow.add_child(self)
	route.add_child(follow)
