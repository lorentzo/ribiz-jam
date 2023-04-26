class_name MonsterFollow
extends PathFollow2D

var speed = 50

func _init(monster_speed: float):
	self.speed = monster_speed

func _process(delta):
	set_offset(get_offset() + self.speed * delta)
