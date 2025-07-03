extends Node3D

@onready var fire = $Fire
@onready var smoke = $Smoke


func explode():
	fire.emitting = true
	smoke.emitting = true
