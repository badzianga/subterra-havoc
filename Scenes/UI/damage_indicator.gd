# Label that indicates applied damage. Used by HealthComponent.
# When ready, it starts a short animation that moves itself by 16 pixels to up,
# then deletes itself.

extends Label


func _ready() -> void:
	var _tween := get_tree().create_tween()
	_tween.tween_property(self, "position", Vector2(0.0, -16.0), 1).as_relative() \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(queue_free)
