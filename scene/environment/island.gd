extends Node3D


@onready var border: Area3D = %Border


func _ready():
	border.body_entered.connect(on_body_enter_border)


func on_body_enter_border(body: Node3D):
	if body is CharacterBody3D:
		body.die()
		return
	
	body.queue_free()
