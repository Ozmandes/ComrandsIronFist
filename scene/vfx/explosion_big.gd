extends Node3D

func _ready():
	$AnimationPlayer.animation_finished.connect(on_animation_finished)


func on_animation_finished(_anim_name: String):
	get_parent().queue_free()
