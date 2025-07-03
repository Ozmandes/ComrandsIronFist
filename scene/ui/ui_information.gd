extends CanvasLayer

@onready var direction: MarginContainer = %Direction
@onready var reloading_text: RichTextLabel = %ReloadingText
@onready var health_progress: ProgressBar = %HealthProgress

var current_health: float = 0

func _ready():
	health_progress.value = current_health


func change_direction_visible(flag: bool):
	direction.visible = flag


func update_direction(body_forward: Vector3, head_forward: Vector3):
	# 去除垂直分量，只看水平夹角
	body_forward.y = 0
	head_forward.y = 0
	body_forward = body_forward.normalized()
	head_forward = head_forward.normalized()

	var factor = acos(body_forward.dot(head_forward)) / PI

	var cross = body_forward.cross(head_forward)
	if cross.y < 0:
		factor = -factor
	
	direction.position.x = factor * 1080


func update_reload_statue(flag: bool):
	if flag:
		var tween = create_tween().chain()
		tween.tween_property(reloading_text, "modulate", Color(1, 1, 1, 0), 0.2)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		
		reloading_text.text = "[wave amp=20 freq=20]Reloading"
		
		tween.tween_property(reloading_text, "modulate", Color(1, 1, 1, 1), 0.4)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	else:
		var tween = create_tween().chain()
		tween.tween_property(reloading_text, "modulate", Color(1, 1, 1, 0), 0.2)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		
		reloading_text.text = "Ready to fire"
		
		tween.tween_property(reloading_text, "modulate", Color(1, 1, 1, 1), 0.4)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)


func update_health(damage: float):
	var damage_value = current_health - damage
	if damage_value <= 0:
		current_health = 0
		get_tree().get_first_node_in_group("player").die()
	else:
		current_health = damage_value
	
	var tween = create_tween().chain()
	tween.tween_property(health_progress, "value", current_health, 0.4)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	
