extends Sprite2D

@onready var _animation_player := $AnimationPlayer


func attack() -> void:
	_animation_player.play("attack")
