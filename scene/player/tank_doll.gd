extends Node3D

@onready var marker: Marker3D = %Marker
@onready var head: RigidBody3D = %Head
@onready var gun: RigidBody3D = %Gun
@onready var body: RigidBody3D = %Body
@onready var big_gear_left: RigidBody3D = %BigGearLeft
@onready var big_gear_right: RigidBody3D = %BigGearRight
@onready var small_gear_left: RigidBody3D = %SmallGearLeft
@onready var small_gear_right: RigidBody3D = %SmallGearRight
@onready var track_left: RigidBody3D = %TrackLeft
@onready var track_right: RigidBody3D = %TrackRight

var strength: int = 500

func _ready():
	var to_head: Vector3 = (head.global_transform.origin - marker.global_transform.origin).normalized()
	var to_gun: Vector3 = (gun.global_transform.origin - marker.global_transform.origin).normalized()
	var to_body: Vector3 = (body.global_transform.origin - marker.global_transform.origin).normalized()
	var to_big_gear_left: Vector3 = (big_gear_left.global_transform.origin - marker.global_transform.origin).normalized()
	var to_small_gear_left: Vector3 = (small_gear_left.global_transform.origin - marker.global_transform.origin).normalized()
	var to_big_gear_right: Vector3 = (big_gear_right.global_transform.origin - marker.global_transform.origin).normalized()
	var to_small_gear_right: Vector3 = (small_gear_right.global_transform.origin - marker.global_transform.origin).normalized()
	var to_track_left: Vector3 = (track_left.global_transform.origin - marker.global_transform.origin).normalized()
	var to_track_right: Vector3 = (track_right.global_transform.origin - marker.global_transform.origin).normalized()
	
	var impulse_head = (to_head) * strength
	var impulse_gun = (to_gun) * strength
	var impulse_body = (to_body) * strength
	var impulse_big_gear_left = (to_big_gear_left) * strength
	var impulse_small_gear_left = (to_small_gear_left) * strength
	var impulse_big_gear_right = (to_big_gear_right) * strength
	var impulse_small_gear_right = (to_small_gear_right) * strength
	var impulse_track_left = (to_track_left) * strength
	var impulse_track_right = (to_track_right) * strength
	
	head.apply_impulse(impulse_head)
	gun.apply_impulse(impulse_gun)
	body.apply_impulse(impulse_body)
	big_gear_left.apply_impulse(impulse_big_gear_left)
	big_gear_right.apply_impulse(impulse_big_gear_right)
	small_gear_left.apply_impulse(impulse_small_gear_left)
	small_gear_right.apply_impulse(impulse_small_gear_right)
	track_left.apply_impulse(impulse_track_left)
	track_right.apply_impulse(impulse_track_right)
