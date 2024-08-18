extends Sprite2D


func _ready() -> void:
	var _tween := create_tween()
	_tween.tween_property(self, "modulate:a", 0, 0.5)
	_tween.set_trans(Tween.TRANS_QUART)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_callback(queue_free)
