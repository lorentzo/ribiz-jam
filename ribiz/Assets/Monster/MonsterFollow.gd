class_name MonsterFollow
extends PathFollow2D

var speed = 50

func _init(speed: float):
	self.speed = speed

func _process(delta):
	set_offset(get_offset() + self.speed * delta)
