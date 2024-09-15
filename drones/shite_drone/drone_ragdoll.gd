extends RigidBody3D


signal has_been_shot(collision_point, collision_normal)

var player: CharacterBody3D

@export var bullet_hit_audio: AudioStreamPlayer3D
@export var bullet_hit_particles: GPUParticles3D



func _ready() -> void:
	has_been_shot.connect(deal_damage)

func deal_damage(collision_point, _collision_normal):
	bullet_hit_audio.play()
	var hit_vector:Vector3 = (player.global_position-collision_point).normalized() * 1.5
	bullet_hit_particles.global_position = collision_point
	bullet_hit_particles.process_material.direction = Vector3(hit_vector.x, 2, hit_vector.z)
	bullet_hit_particles.restart()
