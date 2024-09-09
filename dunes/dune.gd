extends MeshInstance3D

@export var hmap:CompressedTexture2D
@onready var collider: CollisionShape3D = $StaticBody3D/CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var float_array: PackedFloat32Array
	var hmap_image: Image = hmap.get_image()
	if hmap_image.is_compressed():
		hmap_image.decompress()
	hmap_image.resize(mesh.size.x, mesh.size.y)
	var terrain_height = get_active_material(0).get("shader_parameter/height")
	
	var shape = HeightMapShape3D.new()
	collider.shape = shape
	collider.shape.map_width = mesh.size.x
	collider.shape.map_depth = mesh.size.y
	
	for y in hmap_image.get_height():
		for x in hmap_image.get_width():
			float_array.push_back(hmap_image.get_pixel(x, y).r * terrain_height)
	collider.shape.set_map_data(float_array.duplicate())
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
