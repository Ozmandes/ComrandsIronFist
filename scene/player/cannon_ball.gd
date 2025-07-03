extends RigidBody3D

@export var explosion_scene: PackedScene

@onready var mesh = %Mesh

@onready var explosion_range: Area3D = %ExplosionRange

var influenced_object_array: Array = []
var hit_tank: CharacterBody3D


func _ready():
	self.body_entered.connect(explode)
	explosion_range.body_entered.connect(add_influence_object)

func explode(_body: Node):
	mesh.visible = false
	self.freeze = true
	
	apply_force_to_influenced_object()
	
	var explosion_instance = explosion_scene.instantiate() as Node3D
	self.add_child(explosion_instance)
	explosion_instance.global_position = global_position


func add_influence_object(body: Node):
	if body is RigidBody3D:
		influenced_object_array.append(body)
	if body is CharacterBody3D:
		hit_tank = body


func apply_force_to_influenced_object():
	for object in influenced_object_array:
		var to_body = object.global_transform.origin - global_transform.origin
		var distance = to_body.length()
		
		if distance > 16:
			continue
		
		var direction = to_body.normalized()
		
		var attenuation = 1.2 - (distance / 16)
		var impulse = direction * (500 * attenuation)
		
		object.apply_impulse(impulse)
	
	influenced_object_array.clear()
	
	
	var to_tank = hit_tank.global_transform.origin - global_transform.origin
	var distance_tank = to_tank.length()
	
	if distance_tank > 16:
		return
		
	var damage = (1 - (distance_tank / 16))/3
	hit_tank.hurt(damage)
