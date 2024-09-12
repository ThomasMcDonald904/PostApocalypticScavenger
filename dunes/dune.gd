extends StaticBody3D

signal has_been_shot(collision_point, collision_normal)

@export var hmap:CompressedTexture2D
@onready var collider: CollisionShape3D = $CollisionShape3D
var sand_spray_particles_PS: PackedScene = load("res://dunes/shot_sand_particles.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	has_been_shot.connect(shot_sand)
	var float_array: PackedFloat32Array
	var hmap_image: Image = hmap.get_image()
	if hmap_image.is_compressed():
		hmap_image.decompress()
	hmap_image.resize($MeshInstance3D.mesh.size.x, $MeshInstance3D.mesh.size.y)
	var terrain_height = $MeshInstance3D.get_active_material(0).get("shader_parameter/height")
	
	var shape = HeightMapShape3D.new()
	collider.shape = shape
	collider.shape.map_width = $MeshInstance3D.mesh.size.x
	collider.shape.map_depth = $MeshInstance3D.mesh.size.y
	
	for y in hmap_image.get_height():
		for x in hmap_image.get_width():
			float_array.push_back(hmap_image.get_pixel(x, y).r * terrain_height)
	collider.shape.set_map_data(float_array.duplicate())
	


func shot_sand(collision_point: Vector3, collision_normal: Vector3):
	var sand_particles: GPUParticles3D = sand_spray_particles_PS.instantiate()
	get_parent().add_child(sand_particles)
	sand_particles.global_position = collision_point
	sand_particles.global_position.y += 0.5
	var shot_vector = sand_particles.global_position - get_viewport().get_camera_3d().global_position
	sand_particles.process_material.direction = collision_normal.normalized() + shot_vector.normalized()
	sand_particles.restart() 
	sand_particles.finished.connect(sand_particles.queue_free)
