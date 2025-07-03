extends RigidBody3D

@onready var detect_player: Area3D = %DetectPlayer

var tank_body: CharacterBody3D
var active_flag: bool = false


func _ready():
	detect_player.body_entered.connect(on_body_entered)
	detect_player.body_exited.connect(on_body_exited)


func _physics_process(_delta):
	if active_flag:
		var force_direction: Vector3 = (self.global_transform.origin - tank_body.global_transform.origin).normalized()
		var force: Vector3 = 16000 * force_direction * ((abs(tank_body.current_speed) + abs(tank_body.current_turn_speed)) / 12)
		
		self.apply_force(force)


func on_body_entered(body: Node):
	if body is CharacterBody3D:
		tank_body = body
		active_flag = true


func on_body_exited(body: Node):
	if body == tank_body:
		active_flag = false 
