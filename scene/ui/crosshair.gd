extends CanvasLayer

@onready var reload_label: Label = %Reload


func show_reload():
	var tween = get_tree().create_tween().chain()
	tween.tween_property(reload_label, "modulate", Color(1, 1, 1, 1), 0.5)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(reload_label, "modulate", Color(1, 1, 1, 0), 0.5)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(reload_label, "modulate", Color(1, 1, 1, 1), 0.5)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(reload_label, "modulate", Color(1, 1, 1, 0), 0.5)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(reload_label, "modulate", Color(1, 1, 1, 1), 0.5)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(reload_label, "modulate", Color(1, 1, 1, 0), 0.5)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(reload_label, "modulate", Color(1, 1, 1, 1), 0.5)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(reload_label, "modulate", Color(1, 1, 1, 0), 0.5)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
