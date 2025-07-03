extends CharacterBody3D

@onready var left_track_animation: AnimationPlayer = %LeftTrackAnimation
@onready var right_track_animation: AnimationPlayer = %RightTrackAnimation
@onready var fire_animation: AnimationPlayer = %FireAnimation
@onready var explision_lite: Node3D = %ExplisionLite
@onready var dust: GPUParticles3D = %Dust
@onready var reload: Timer = %Reload

@onready var camera_pivot: Node3D = %CameraPivotX
@onready var camera_pivot_y: Node3D = %CameraPivotY
@onready var head: Node3D = %Head
@onready var gun: Node3D = %Gun
@onready var fire_position: Marker3D = %FirePosition

@onready var check_ground_ray = %CheckGroundRay

@onready var fp_camera: Camera3D = %FPCamera
@onready var tp_camera: Camera3D = %TPCamera

@onready var crosshair = %Crosshair
@onready var ui_information = %UIInformation
@onready var tank_soul = %TankSoul

@export var sens: float = 0.05
# true: mouse false: keybord
@export var control_mode: bool = true
@export var cannon_ball_scene: PackedScene
@export var tank_doll: PackedScene

@onready var visual = %Visual

var xform: Transform3D

var direction: Vector3 = Vector3.FORWARD

var current_speed := 0.0
var current_turn_speed := 0.0

const MAX_SPEED: int = 12
const MAX_TURN_SPEED: float = 1
const ACCELERATION: int = 10
const DEACCELERATION: int = 4

var cannon_ready_flag: bool = true
var die_flag: bool = false


func _enter_tree():
	set_multiplayer_authority(name.to_int())


func _ready():
	die(true)
	
	left_track_animation.play("forward")
	right_track_animation.play("forward")
	left_track_animation.pause()
	right_track_animation.pause()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	reload.timeout.connect(on_cannon_reload_ready)


func _input(event):
	if not is_multiplayer_authority():
		return
	
	if event.is_action_pressed("exit"):
		get_tree().quit()
	
	if control_mode:
		if event is InputEventMouseMotion:
			head.rotate_y(deg_to_rad(-event.relative.x * sens))
			camera_pivot_y.rotate_y(deg_to_rad(-event.relative.x * sens))
			
			camera_pivot.rotate_x(deg_to_rad(event.relative.y * sens))
			camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-30), deg_to_rad(20))
			gun.rotate_x(deg_to_rad(event.relative.y * sens))
			gun.rotation.x = clamp(gun.rotation.x, deg_to_rad(-30), deg_to_rad(20))
	
	if die_flag:
		if event.is_action_pressed("fire"):
			reset()
		
		return
	
	if event.is_action_pressed("aim"):
		if not control_mode or 1:
			crosshair.visible = not crosshair.visible
			fp_camera.current = crosshair.visible
			tp_camera.current = not crosshair.visible
			ui_information.change_direction_visible(crosshair.visible)
		else:
			fp_camera.make_current()
			crosshair.visible = true
			ui_information.change_direction_visible(true)
	
	if event.is_action_released("aim"):
		if not control_mode or 1:
			return
		else:
			tp_camera.make_current()
			crosshair.visible = false
			ui_information.change_direction_visible(false)
	
	if event.is_action_pressed("fire"):
		if cannon_ready_flag:
			add_cannon_ball()


func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	if die_flag:
		soul_move()
		return
	
	if not control_mode:
		head.rotation.y -= deg_to_rad((Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * 1)
		camera_pivot_y .rotation.y -= deg_to_rad((Input.get_action_strength("look_right") - Input.get_action_strength("look_left")) * 1)
		
		camera_pivot.rotation.x += deg_to_rad((Input.get_action_strength("look_down") - Input.get_action_strength("look_up")) * 0.5)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-30), deg_to_rad(20))
		gun.rotation.x += deg_to_rad((Input.get_action_strength("look_down") - Input.get_action_strength("look_up")) * 0.5)
		gun.rotation.x = clamp(gun.rotation.x, deg_to_rad(-30), deg_to_rad(20))
	else:
		head.rotation.y -= current_turn_speed * delta
		camera_pivot_y.rotation.y -= current_turn_speed * delta
	
	if is_on_floor():
		align_with_floor(check_ground_ray.get_collision_normal())
		if current_speed != 0 or current_turn_speed != 0:
			dust.emitting = true
		else:
			dust.emitting = false
	else:
		align_with_floor(Vector3.UP)
		dust.emitting = false
	
	visual.global_transform = visual.global_transform.interpolate_with(xform, .1)
	
	move(delta)
	play_track_and_camera_animation()


func move(delta):
	var forward_input = Input.get_action_strength("forward") - Input.get_action_strength("back")
	var turn_input = Input.get_action_strength("left") - Input.get_action_strength("right")
	
	if abs(forward_input) > 0.01:
		
		current_speed = move_toward(current_speed, forward_input * MAX_SPEED, ACCELERATION * delta)
	else:
		current_speed = move_toward(current_speed, 0, DEACCELERATION * delta)
	
	if abs(turn_input) > 0.01:
		current_turn_speed = move_toward(current_turn_speed, turn_input * MAX_TURN_SPEED, ACCELERATION * 0.2 * delta)
	else:
		current_turn_speed = move_toward(current_turn_speed, 0, DEACCELERATION * 5 * delta)
	
	rotation.y += current_turn_speed * delta
	
	var forward_dir = transform.basis.z.normalized()
	ui_information.update_direction(global_transform.basis.z.normalized(), head.global_transform.basis.z.normalized())
	velocity = forward_dir * current_speed
	
	if not is_on_floor():
		velocity += get_gravity() * 2
	
	move_and_slide()


func soul_move():
	var input_dir = Vector3.ZERO
	input_dir.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	input_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		var cam_basis = tp_camera.global_transform.basis
		var move_dir = (cam_basis.x * input_dir.x + cam_basis.z * input_dir.z)
		move_dir.y = 0
		move_dir = move_dir.normalized()

		velocity = move_dir * MAX_SPEED * 2
	else:
		velocity = Vector3.ZERO

	move_and_slide()


func play_track_and_camera_animation():
	var left_speed = 0.0
	var right_speed = 0.0
	if abs(current_speed) > 0.01:
		var turn_weight = 0.5
		left_speed = clamp((current_speed / MAX_SPEED) - (current_turn_speed / MAX_TURN_SPEED) * turn_weight, -1.0, 1.0)
		right_speed = clamp((current_speed / MAX_SPEED) + (current_turn_speed / MAX_TURN_SPEED) * turn_weight, -1.0, 1.0)
	else:
		left_speed = clamp(-(current_turn_speed / MAX_TURN_SPEED), -1.0, 1.0)
		right_speed = clamp((current_turn_speed / MAX_TURN_SPEED), -1.0, 1.0)
	
	left_track_animation.speed_scale = left_speed
	right_track_animation.speed_scale = right_speed
	
	if abs(left_speed) > 0.01:
		left_track_animation.play()
	else:
		left_track_animation.pause()

	if abs(right_speed) > 0.01:
		right_track_animation.play()
	else:
		right_track_animation.pause()
	
	var base_fov = 45
	var max_fov = 50
	var base_position: Vector3 = Vector3(0, 0, 15)
	var max_position: Vector3 = Vector3(0, 5, 20)
	tp_camera.fov = lerp(base_fov, max_fov, abs(current_speed) / MAX_SPEED)
	tp_camera.position = lerp(base_position, max_position, abs(current_speed) / MAX_SPEED)


func align_with_floor(floor_normal: Vector3):
	xform = global_transform
	xform.basis.y = floor_normal
	xform.basis.x = -xform.basis.z.cross(floor_normal)
	xform.basis = xform.basis.orthonormalized()


func on_cannon_reload_ready():
	cannon_ready_flag = true
	ui_information.update_reload_statue(false)


func hurt(damage: float):
	ui_information.update_health(damage)


func add_cannon_ball():
		cannon_ready_flag = false
		reload.start()
		crosshair.show_reload()
		ui_information.update_reload_statue(true)
		
		fire_animation.play("fire")
		explision_lite.explode()
		
		var cannon_ball_instance = cannon_ball_scene.instantiate() as RigidBody3D
		get_tree().get_first_node_in_group("cannon_ball").add_child(cannon_ball_instance)
		cannon_ball_instance.hit_tank = self
		cannon_ball_instance.global_position = fire_position.global_position
		
		cannon_ball_instance.apply_impulse(fire_position.global_transform.basis.z * 1500)


func die(flag: bool = false):
	die_flag = true
	
	visual.visible = false
	crosshair.visible = false
	ui_information.visible = false
	dust.emitting = false
	tank_soul.visible = true
	
	tp_camera.make_current()
	tp_camera.fov = 75
	
	var tween = create_tween()
	tween.tween_property(self, "global_position" , Vector3(global_position.x, 20, global_position.z), 2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	if flag:
		return
	
	var tank_doll_instance = tank_doll.instantiate() as Node3D
	get_tree().get_first_node_in_group("wreck_tank").add_child(tank_doll_instance)
	tank_doll_instance.global_position = head.global_position


func reset():
	die_flag = false
	visual.visible = true
	ui_information.visible = true
	tank_soul.visible = false
	tp_camera.fov = 45
	
	ui_information.update_health(-1)
